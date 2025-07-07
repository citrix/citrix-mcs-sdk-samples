<#
.SYNOPSIS
    Remove an image version.
.DESCRIPTION
    Remove-ImageVersion.ps1 removes the image version (include prepared image, master image) from the specified image definition.
    The original version of this script is compatible with Citrix Virtual Apps and Desktops 7 2402 Long Term Service Release (LTSR).
#>

# /*************************************************************************
# * Copyright © 2025. Cloud Software Group, Inc. All Rights Reserved.
# * This file is subject to the license terms contained
# * in the license file that is distributed with this file.
# *************************************************************************/

param(
    [string]$DefinitionName,
    [int]$ImageVersionNumber
)

Add-PSSnapin -Name "Citrix.Host.Admin.V2", "Citrix.MachineCreation.Admin.V2"

$prepedSpec = Get-ProvImageVersionSpec -ImageVersionNumber $ImageVersionNumber -ImageDefinitionName $DefinitionName | Where-Object IsPrepared -eq $True
if ($prepedSpec) {
    if ($prepedSpec.HostingUnits) {
        $prepedSpec.HostingUnits | Where-Object { -not $_.IsPrimary } | ForEach-Object {
            Remove-ProvImageVersionSpecHostingUnit -ImageVersionSpecUid $_.ImageVersionSpecUid -HostingUnitUid $_.HostingUnitUid
        }
    }
    $prepedSpec | Remove-ProvImageVersionSpec
}

Get-ProvImageVersionSpec -ImageVersionNumber $ImageVersionNumber -ImageDefinitionName $DefinitionName | Remove-ProvImageVersionSpec

Get-ProvImageVersion -ImageDefinitionName $DefinitionName -ImageVersionNumber $ImageVersionNumber | Remove-ProvImageVersion
