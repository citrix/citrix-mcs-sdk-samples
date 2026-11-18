<#
.SYNOPSIS
    Searches for machine-profile sources on a XenServer hosting connection.
.DESCRIPTION
    The `Search-MachineProfileInventory.ps1` script searches the machine-profile inventory of a
    XenServer hosting connection using server-side name filtering and continuation-token
    pagination, via Search-HypMachineProfileInventory. On XenServer, machine-profile sources are
    VMs, templates, and snapshots; the values captured from the chosen source are used as the
    hardware profile for provisioned machines.

    Important XenServer behavior:
      * A root call (no -Subpath) returns VMs and TEMPLATES only. Snapshots are not listed at
        the root - they are nested under a VM.
      * Snapshots are returned only when the search is scoped to a VM with -Subpath, and a single
        call returns only the FIRST level. Walk each snapshot's RelativePath back into -Subpath to
        reach deeper levels.

    This script is compatible with Citrix Virtual Apps and Desktops (CVAD) 2611 and Citrix DaaS 131.
.INPUTS
    1. ConnectionName: Name of the XenServer hosting connection to search (ByName parameter set).
    2. ConnectionUid: UID of the XenServer hosting connection to search (ById parameter set).
    3. NameContains: Optional case-insensitive substring matched against the source name.
    4. Subpath: Optional inventory subtree to scope to (e.g. a VM path, to list its snapshots).
    5. SortBy: Field to sort by - "Name" (default) or "Path".
    6. SortOrder: Sort direction - "Ascending" (default) or "Descending".
    7. PageSize: Number of items fetched per page (batch). Defaults to 50; server cap is 1000.
    8. IncludeProvisionedResources: Also include MCS-provisioned resources (excluded by default).
    9. CountOnly: Return only the total count of matching sources, without any items.
    10. AdminAddress: The primary DDC address (on-prem CVAD).
.OUTPUTS
    Machine-profile inventory items (Name, ItemType, RelativePath) across all matching pages, or
    the total count when -CountOnly is specified.
.NOTES
    Version      : 1.0.0
    Author       : Citrix Systems, Inc.

    The cmdlet also accepts -Tags and -RequireHibernationSupport, but neither affects results on
    XenServer (tags are honored only by Search-HypGoldenImageInventory, and XenServer exposes no
    hibernation metadata). They are therefore not surfaced by this script.
.EXAMPLE
    # 1. ConnectionName (ByName) - root call returns VMs and TEMPLATES.
    .\Search-MachineProfileInventory.ps1 -ConnectionName "XS-Pool-01"

.EXAMPLE
    # 2. ConnectionUid (ById) - select the connection by UID.
    .\Search-MachineProfileInventory.ps1 -ConnectionUid "9b7c1f3e-2a4d-4c6b-8e1f-0d5a6b7c8d9e"

.EXAMPLE
    # 3. NameContains - sources whose name contains "win11" (case-insensitive).
    .\Search-MachineProfileInventory.ps1 -ConnectionName "XS-Pool-01" -NameContains "win11"

.EXAMPLE
    # 4. Subpath - list the first level of snapshots under a VM (usable as machine-profile sources).
    .\Search-MachineProfileInventory.ps1 -ConnectionName "XS-Pool-01" -Subpath "/win11-2507vda.vm"

.EXAMPLE
    # 5. SortBy / SortOrder - order sources by name, Z-to-A.
    .\Search-MachineProfileInventory.ps1 -ConnectionName "XS-Pool-01" -SortBy Name -SortOrder Descending

.EXAMPLE
    # 6. CountOnly - how many sources match "win", without fetching them.
    .\Search-MachineProfileInventory.ps1 -ConnectionName "XS-Pool-01" -NameContains "win" -CountOnly

.EXAMPLE
    # 7. Mixed - name filtered, sorted, small pages.
    .\Search-MachineProfileInventory.ps1 -ConnectionName "XS-Pool-01" -NameContains "win" -SortBy Name -PageSize 2
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
    $result = Search-HypMachineProfileInventory @searchParams -MaxRecordCount 0
    Write-Output "Total matching machine-profile sources: $($result.TotalItems)"
    return
}

#########################################################
# Walk every page forward using the continuation token. #
#########################################################
$token = $null
$page  = 0
do {
    $result = Search-HypMachineProfileInventory @searchParams -MaxRecordCount $PageSize -ContinuationToken $token
    $page++
    Write-Output "Page $page ($($result.Items.Count) of $($result.TotalItems) total):"
    $result.Items | Select-Object Name, ItemType, RelativePath
    $token = $result.ContinuationToken
} while ($token)
