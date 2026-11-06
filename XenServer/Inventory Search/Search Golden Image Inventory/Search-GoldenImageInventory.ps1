<#
.SYNOPSIS
    Searches for golden images (master images) on a XenServer hosting connection.
.DESCRIPTION
    The `Search-GoldenImageInventory.ps1` script searches the golden-image inventory of a
    XenServer hosting connection using server-side name/tag filtering and continuation-token
    pagination, via Search-HypGoldenImageInventory. On XenServer a golden image can be a
    template or a snapshot; this cmdlet returns both, and both are valid master images for
    catalog creation.

    Important XenServer behavior:
      * A root call (no -Subpath) returns TEMPLATES only. Snapshots are not listed at the root.
      * Snapshots are nested under a VM and are returned only when the search is scoped to that
        VM with -Subpath. A single -Subpath call returns only the FIRST level of that VM's
        snapshots; walk each snapshot's RelativePath back into -Subpath to reach deeper levels.
      * This cmdlet never returns VMs. The VM path used for -Subpath comes from
        Search-HypVirtualMachineInventory - carry its RelativePath through unchanged.

    This script is compatible with Citrix Virtual Apps and Desktops (CVAD) 2611 and Citrix DaaS 131.
.INPUTS
    1. ConnectionName: Name of the XenServer hosting connection to search (ByName parameter set).
    2. ConnectionUid: UID of the XenServer hosting connection to search (ById parameter set).
    3. NameContains: Optional case-insensitive substring matched against the image name.
    4. Tags: Optional tag list; case-insensitive, any-match. Honored for golden images.
    5. Subpath: Optional inventory subtree to scope to (e.g. a VM path, to list its snapshots).
    6. SortBy: Field to sort by - "Name" (default) or "Path".
    7. SortOrder: Sort direction - "Ascending" (default) or "Descending".
    8. PageSize: Number of items fetched per page (batch). Defaults to 50; server cap is 1000.
    9. IncludeProvisionedResources: Also include MCS-provisioned resources (excluded by default).
    10. CountOnly: Return only the total count of matching images, without any items.
    11. AdminAddress: The primary DDC address (on-prem CVAD).
.OUTPUTS
    Golden-image inventory items (Name, ItemType, RelativePath) across all matching pages, or the
    total count when -CountOnly is specified.
.NOTES
    Version      : 1.0.0
    Author       : Citrix Systems, Inc.

    -RequireHibernationSupport is accepted by the cmdlet but has no effect on XenServer, so it is
    not surfaced by this script.
.EXAMPLE
    # 1. ConnectionName (ByName) - root call returns TEMPLATES only.
    .\Search-GoldenImageInventory.ps1 -ConnectionName "XS-Pool-01"

.EXAMPLE
    # 2. ConnectionUid (ById) - select the connection by UID.
    .\Search-GoldenImageInventory.ps1 -ConnectionUid "9b7c1f3e-2a4d-4c6b-8e1f-0d5a6b7c8d9e"

.EXAMPLE
    # 3. NameContains - templates whose name contains "win11" (case-insensitive).
    .\Search-GoldenImageInventory.ps1 -ConnectionName "XS-Pool-01" -NameContains "win11"

.EXAMPLE
    # 4. Tags - only images tagged "gold" or "approved" (any-match, case-insensitive).
    .\Search-GoldenImageInventory.ps1 -ConnectionName "XS-Pool-01" -Tags "gold","approved"

.EXAMPLE
    # 5. Subpath - list the first level of snapshots under a VM (VM path from Search-HypVirtualMachineInventory).
    .\Search-GoldenImageInventory.ps1 -ConnectionName "XS-Pool-01" -Subpath "/win11-2507vda.vm"

.EXAMPLE
    # 6. SortBy / SortOrder - order templates by name, Z-to-A.
    .\Search-GoldenImageInventory.ps1 -ConnectionName "XS-Pool-01" -SortBy Name -SortOrder Descending

.EXAMPLE
    # 7. CountOnly - how many templates are tagged "gold", without fetching them.
    .\Search-GoldenImageInventory.ps1 -ConnectionName "XS-Pool-01" -Tags "gold" -CountOnly

.EXAMPLE
    # 8. Mixed - name + tag filtered, sorted, small pages.
    .\Search-GoldenImageInventory.ps1 -ConnectionName "XS-Pool-01" -NameContains "win" -Tags "approved" -SortBy Name -PageSize 2
#>

[CmdletBinding(DefaultParameterSetName = "ByName")]
param(
    [Parameter(Mandatory = $true, ParameterSetName = "ByName")] [string] $ConnectionName,
    [Parameter(Mandatory = $true, ParameterSetName = "ById")]   [guid]   $ConnectionUid,
    [string]   $NameContains = $null,
    [string[]] $Tags = $null,
    [string]   $Subpath = $null,
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
if ($Tags)         { $searchParams['Tags'] = $Tags }
if ($Subpath)      { $searchParams['Subpath'] = $Subpath }
if ($IncludeProvisionedResources) { $searchParams['IncludeProvisionedResources'] = $true }
if ($AdminAddress) { $searchParams['AdminAddress'] = $AdminAddress }

##################################################
# Count-only query: return TotalItems, no items. #
##################################################
if ($CountOnly) {
    $result = Search-HypGoldenImageInventory @searchParams -MaxRecordCount 0
    Write-Output "Total matching golden images: $($result.TotalItems)"
    return
}

#########################################################
# Walk every page forward using the continuation token. #
#########################################################
$token = $null
$page  = 0
do {
    $result = Search-HypGoldenImageInventory @searchParams -MaxRecordCount $PageSize -ContinuationToken $token
    $page++
    Write-Output "Page $page ($($result.Items.Count) of $($result.TotalItems) total):"
    $result.Items | Select-Object Name, ItemType, RelativePath
    $token = $result.ContinuationToken
} while ($token)
