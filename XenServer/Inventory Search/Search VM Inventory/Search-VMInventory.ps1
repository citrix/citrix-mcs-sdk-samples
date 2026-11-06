<#
.SYNOPSIS
    Searches for virtual machines on a XenServer hosting connection.
.DESCRIPTION
    The `Search-VMInventory.ps1` script searches the virtual-machine inventory of a XenServer
    hosting connection using server-side name filtering and continuation-token pagination, via
    Search-HypVirtualMachineInventory. Unlike browsing the XDHyp:\ provider path, it accepts a
    hosting connection (by name or UID) directly and filters on the server, so large inventories
    no longer need to be loaded in full. This is useful when selecting power-managed machines
    during imported catalog creation.
    This script is compatible with Citrix Virtual Apps and Desktops (CVAD) 2611 and Citrix DaaS 131.
.INPUTS
    1. ConnectionName: Name of the XenServer hosting connection to search (ByName parameter set).
    2. ConnectionUid: UID of the XenServer hosting connection to search (ById parameter set).
    3. NameContains: Optional case-insensitive substring matched against the VM name.
    4. Subpath: Optional inventory subtree to restrict the search to.
    5. SortBy: Field to sort by - "Name" (default) or "Path".
    6. SortOrder: Sort direction - "Ascending" (default) or "Descending".
    7. PageSize: Number of items fetched per page (batch). Defaults to 50; server cap is 1000.
    8. IncludeProvisionedResources: Also include MCS-provisioned VMs (excluded by default).
    9. CountOnly: Return only the total count of matching VMs, without any items.
    10. AdminAddress: The primary DDC address (on-prem CVAD).
.OUTPUTS
    Virtual-machine inventory items (Name, Id, RelativePath) across all matching pages, or the
    total count when -CountOnly is specified.
.NOTES
    Version      : 1.0.0
    Author       : Citrix Systems, Inc.

    The cmdlet also accepts -Tags and -RequireHibernationSupport, but neither affects results on
    XenServer (tags are honored only by Search-HypGoldenImageInventory, and XenServer exposes no
    hibernation metadata). They are therefore not surfaced by this script.
.EXAMPLE
    # 1. ConnectionName (ByName) - first page of every VM on the connection.
    .\Search-VMInventory.ps1 -ConnectionName "XS-Pool-01"

.EXAMPLE
    # 2. ConnectionUid (ById) - select the connection by UID instead of name.
    .\Search-VMInventory.ps1 -ConnectionUid "9b7c1f3e-2a4d-4c6b-8e1f-0d5a6b7c8d9e"

.EXAMPLE
    # 3. NameContains - only VMs whose name contains "web" (case-insensitive).
    .\Search-VMInventory.ps1 -ConnectionName "XS-Pool-01" -NameContains "web"

.EXAMPLE
    # 4. SortBy / SortOrder - order by relative path, Z-to-A.
    .\Search-VMInventory.ps1 -ConnectionName "XS-Pool-01" -SortBy Path -SortOrder Descending

.EXAMPLE
    # 5. PageSize - page through the whole inventory two VMs at a time.
    .\Search-VMInventory.ps1 -ConnectionName "XS-Pool-01" -PageSize 2

.EXAMPLE
    # 6. Subpath - restrict the search to an inventory subtree.
    .\Search-VMInventory.ps1 -ConnectionName "XS-Pool-01" -Subpath "/Production.folder"

.EXAMPLE
    # 7. IncludeProvisionedResources - also return MCS-provisioned VMs.
    .\Search-VMInventory.ps1 -ConnectionName "XS-Pool-01" -IncludeProvisionedResources

.EXAMPLE
    # 8. CountOnly - just the total number of matches, no items fetched.
    .\Search-VMInventory.ps1 -ConnectionName "XS-Pool-01" -NameContains "win11" -CountOnly

.EXAMPLE
    # 9. AdminAddress - target a specific on-prem Delivery Controller.
    .\Search-VMInventory.ps1 -ConnectionName "XS-Pool-01" -AdminAddress "ddc01.contoso.local"

.EXAMPLE
    # 10. Mixed - filtered + sorted + paged: page through the "web" VMs one at a time, newest path first.
    .\Search-VMInventory.ps1 -ConnectionName "XS-Pool-01" -NameContains "web" -SortBy Path -SortOrder Descending -PageSize 1

.EXAMPLE
    # 11. Mixed - scoped, provisioned-inclusive lookup by connection UID.
    .\Search-VMInventory.ps1 -ConnectionUid "9b7c1f3e-2a4d-4c6b-8e1f-0d5a6b7c8d9e" -Subpath "/Production.folder" -NameContains "app" -IncludeProvisionedResources

.EXAMPLE
    # 12. Mixed - count-only on a filtered set: how many "sql" VMs match, without fetching them.
    .\Search-VMInventory.ps1 -ConnectionName "XS-Pool-01" -NameContains "sql" -CountOnly
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
    $result = Search-HypVirtualMachineInventory @searchParams -MaxRecordCount $PageSize -ContinuationToken $token
    $page++
    Write-Output "Page $page ($($result.Items.Count) of $($result.TotalItems) total):"
    $result.Items | Select-Object Name, Id, RelativePath
    $token = $result.ContinuationToken
} while ($token)
