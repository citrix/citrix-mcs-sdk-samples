<#
.SYNOPSIS
    Remove an image definition and its versions.
.DESCRIPTION
    Remove-ImageDefinitionAndVersions.ps1 removes an image definition and its versions (include all master specs and prepared specs).
    The original version of this script is compatible with Citrix Virtual Apps and Desktops 7 2411.
.INPUTS
    1. DefinitionName: Name of the image definition.
#>

# /*************************************************************************
# * Copyright © 2024. Cloud Software Group, Inc. All Rights Reserved.
# * This file is subject to the license terms contained
# * in the license file that is distributed with this file.
# *************************************************************************/

param(
    [string]$DefinitionName
)

Add-PSSnapin -Name "Citrix.Host.Admin.V2", "Citrix.MachineCreation.Admin.V2"

$prepedSpecs = Get-ProvImageVersionSpec -ImageDefinitionName $DefinitionName | Where-Object IsPrepared -eq $True
if ($prepedSpecs) {
    if ($prepedSpecs.HostingUnits) {
        $prepedSpecs.HostingUnits | Where-Object { -not $_.IsPrimary } | ForEach-Object {
            & Remove-ProvImageVersionSpecHostingUnit -ImageVersionSpecUid $_.ImageVersionSpecUid -HostingUnitUid $_.HostingUnitUid
        }
    }
    $prepedSpecs | ForEach-Object {
        & Remove-ProvImageVersionSpec -ImageVersionSpecUid $_.ImageVersionSpecUid
    }
}

Get-ProvImageVersionSpec -ImageDefinitionName $DefinitionName | Remove-ProvImageVersionSpec

Get-ProvImageVersion -ImageDefinitionName $DefinitionName | Remove-ProvImageVersion

$imageDefinitions = Get-ProvImageDefinition -ImageDefinitionName $DefinitionName
if ($imageDefinitions) {
    if ($imageDefinitions.Connections) {
        $imageDefinitions.Connections | ForEach-Object {
            & Remove-ProvImageDefinitionConnection -ImageDefinitionUid $_.ImageDefinitionUid -HypervisorConnectionUid $_.HypervisorConnectionUid
        }
    }
    $imageDefinitions | ForEach-Object {
        Remove-ProvImageDefinition -ImageDefinitionName $_.ImageDefinitionName
    }
}
