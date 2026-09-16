<#
.SYNOPSIS
    Searches for virtual machines on a VMware (vCenter) hosting connection.
.DESCRIPTION
    The `Search-VMInventory.ps1` script searches the virtual-machine inventory of a VMware
    hosting connection using server-side name filtering and continuation-token pagination, via
    Search-HypVirtualMachineInventory. Unlike browsing the XDHyp:\ provider path, it accepts a
    hosting connection (by name or UID) directly and filters on the server, so large vCenter
    inventories no longer need to be loaded in full. This is useful when selecting power-managed
    machines during imported catalog creation.
    This script is compatible with Citrix Virtual Apps and Desktops (CVAD) 2611 and Citrix DaaS 131.
.INPUTS
    1. ConnectionName: Name of the VMware hosting connection to search (ByName parameter set).
    2. ConnectionUid: UID of the VMware hosting connection to search (ById parameter set).
    3. NameContains: Optional case-insensitive substring matched against the VM name.
    4. Subpath: Optional inventory subtree to restrict the search to. The search is recursive from
       this path down the datacenter/cluster tree.
    5. SortBy: Field to sort by - "Name" (default) or "Path".
    6. SortOrder: Sort direction - "Ascending" (default) or "Descending".
    7. PageSize: Number of items fetched per page (batch). Defaults to 50; server cap is 1000.
    8. RequireHibernationSupport: Return only VMs that have VMware Tools installed.
    9. IncludeProvisionedResources: Also include MCS-provisioned VMs (excluded by default).
    10. CountOnly: Return only the total count of matching VMs, without any items.
    11. AdminAddress: The primary DDC address (on-prem CVAD).
.OUTPUTS
    Virtual-machine inventory items (Name, Id, RelativePath) across all matching pages, or the
    total count when -CountOnly is specified.
.NOTES
    Version      : 1.0.0
    Author       : Citrix Systems, Inc.

    On VMware, -RequireHibernationSupport is a real filter: it keeps only VMs that report VMware
    Tools installed (the metadata MCS uses as the hibernation-capable proxy), so VMs with tools
    "not installed" are dropped.

    The cmdlet also accepts -Tags, but tag filtering is honored only by Search-HypGoldenImageInventory.
    VMware supports filtered VM inventory but not tag-based filtering, so passing -Tags to the VM search
    fails with FilteredInventoryTagsNotSupported; -Tags is therefore not surfaced by this script.
.EXAMPLE
    # 1. ConnectionName (ByName) - first page of every VM on the connection.
    .\Search-VMInventory.ps1 -ConnectionName "vCenter-Prod"

.EXAMPLE
    # 2. ConnectionUid (ById) - select the connection by UID instead of name.
    .\Search-VMInventory.ps1 -ConnectionUid "7d4e9a21-6c3b-4f8a-b2d1-3e5f9a0c1b2d"

.EXAMPLE
    # 3. NameContains - only VMs whose name contains "web" (case-insensitive).
    .\Search-VMInventory.ps1 -ConnectionName "vCenter-Prod" -NameContains "web"

.EXAMPLE
    # 4. SortBy / SortOrder - order by relative path, Z-to-A.
    .\Search-VMInventory.ps1 -ConnectionName "vCenter-Prod" -SortBy Path -SortOrder Descending

.EXAMPLE
    # 5. PageSize - page through the whole inventory two VMs at a time.
    .\Search-VMInventory.ps1 -ConnectionName "vCenter-Prod" -PageSize 2

.EXAMPLE
    # 6. Subpath - restrict the search to an inventory subtree (recursive from this path).
    .\Search-VMInventory.ps1 -ConnectionName "vCenter-Prod" -Subpath "/DC-East.datacenter/Production.cluster"

.EXAMPLE
    # 7. RequireHibernationSupport - only VMs with VMware Tools installed.
    .\Search-VMInventory.ps1 -ConnectionName "vCenter-Prod" -RequireHibernationSupport

.EXAMPLE
    # 8. IncludeProvisionedResources - also return MCS-provisioned VMs.
    .\Search-VMInventory.ps1 -ConnectionName "vCenter-Prod" -IncludeProvisionedResources

.EXAMPLE
    # 9. CountOnly - just the total number of matches, no items fetched.
    .\Search-VMInventory.ps1 -ConnectionName "vCenter-Prod" -NameContains "win11" -CountOnly

.EXAMPLE
    # 10. AdminAddress - target a specific on-prem Delivery Controller.
    .\Search-VMInventory.ps1 -ConnectionName "vCenter-Prod" -AdminAddress "ddc01.contoso.local"

.EXAMPLE
    # 11. Mixed - filtered + sorted + paged: page through the "web" VMs one at a time, descending relative-path order.
    .\Search-VMInventory.ps1 -ConnectionName "vCenter-Prod" -NameContains "web" -SortBy Path -SortOrder Descending -PageSize 1

.EXAMPLE
    # 12. Mixed - scoped, hibernation-capable lookup by connection UID.
    .\Search-VMInventory.ps1 -ConnectionUid "7d4e9a21-6c3b-4f8a-b2d1-3e5f9a0c1b2d" -Subpath "/DC-East.datacenter" -NameContains "app" -RequireHibernationSupport

.EXAMPLE
    # 13. Mixed - count-only on a filtered set: how many "sql" VMs match, without fetching them.
    .\Search-VMInventory.ps1 -ConnectionName "vCenter-Prod" -NameContains "sql" -CountOnly
#>

[CmdletBinding(DefaultParameterSetName = "ByName")]
param(
    [Parameter(Mandatory = $true, ParameterSetName = "ByName")] [string] $ConnectionName,
    [Parameter(Mandatory = $true, ParameterSetName = "ById")]   [guid]   $ConnectionUid,
    [string] $NameContains = $null,
    [string] $Subpath = $null,
    [ValidateSet("Name", "Path")] [string] $SortBy = "Name",
    [ValidateSet("Ascending", "Descending")] [string] $SortOrder = "Ascending",
    [ValidateRange(1, 1000)] [int] $PageSize = 50,
    [switch] $RequireHibernationSupport = $false,
    [switch] $IncludeProvisionedResources = $false,
    [switch] $CountOnly = $false,
    [string] $AdminAddress = $null
)

# /*************************************************************************
# * Copyright © 2026. Cloud Software Group, Inc. All Rights Reserved.
# * This file is subject to the license terms contained
# * in the license file that is distributed with this file.
# *************************************************************************/

# Enable Citrix PowerShell Cmdlets
Add-PSSnapin citrix*

# Build the parameters shared by every page request.
$searchParams = @{
    SortBy    = $SortBy
    SortOrder = $SortOrder
}

# Select the hosting connection by whichever parameter set was used.
if ($PSCmdlet.ParameterSetName -eq "ById") {
    $searchParams['HypervisorConnectionUid'] = $ConnectionUid
} else {
    $searchParams['HypervisorConnectionName'] = $ConnectionName
}

if ($NameContains) { $searchParams['NameContains'] = $NameContains }
if ($Subpath)      { $searchParams['Subpath'] = $Subpath }
if ($RequireHibernationSupport)   { $searchParams['RequireHibernationSupport'] = $true }
if ($IncludeProvisionedResources) { $searchParams['IncludeProvisionedResources'] = $true }
if ($AdminAddress) { $searchParams['AdminAddress'] = $AdminAddress }

##################################################
# Count-only query: return TotalItems, no items. #
##################################################
if ($CountOnly) {
    $result = Search-HypVirtualMachineInventory @searchParams -MaxRecordCount 0
    Write-Output "Total matching virtual machines: $($result.TotalItems)"
    return
}

#########################################################
# Walk every page forward using the continuation token. #
#########################################################
$token = $null
$page  = 0
do {
    # The cmdlet rejects a null/empty -ContinuationToken, so only supply it once page 1 hands one back.
    if ($token) { $searchParams['ContinuationToken'] = $token }
    $result = Search-HypVirtualMachineInventory @searchParams -MaxRecordCount $PageSize
    $page++
    Write-Output "Page $page ($($result.Items.Count) of $($result.TotalItems) total):"
    $result.Items | Select-Object Name, Id, RelativePath
    $token = $result.ContinuationToken
} while ($token)
