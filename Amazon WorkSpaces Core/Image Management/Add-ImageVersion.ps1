<#
.SYNOPSIS
    Add an image version (include a master spec and a prepared spec) to the specified image definition.
.DESCRIPTION
    Add-ImageVersion.ps1 adds a image version, a master image, and a prepared image to the specified image definition.
    The original version of this script is compatible with Citrix DaaS July 2025 Release (DDC 125).
.INPUTS
    1. DefinitionName: Name of the image definition.
    2. HostingUnitName: Name of the hosting unit used.
    3. MasterImage: Path to the master image.
    4. NetworkMapping: Specifies how the attached NICs are mapped to networks.
    5. MachineProfile: The machine profile used.
    6. CustomProperties: Custom properties for the image version spec.
#>

# /*************************************************************************
# * Copyright © 2025. Cloud Software Group, Inc. All Rights Reserved.
# * This file is subject to the license terms contained
# * in the license file that is distributed with this file.
# *************************************************************************/

param(
    [string]$DefinitionName,
    [string]$HostingUnitName,
    [string]$MasterImage,
    [hashtable]$NetworkMapping,
    [string]$MachineProfile,
    [Parameter(Mandatory = $false)][string]$CustomProperties
)

Add-PSSnapin -Name "Citrix.Host.Admin.V2", "Citrix.MachineCreation.Admin.V2"

$Definition = Get-ProvImageDefinition -ImageDefinitionName $DefinitionName

$Version = New-ProvImageVersion -ImageDefinitionName $Definition.ImageDefinitionName

$SourceSpec = Add-ProvImageVersionSpec -MasterImagePath $MasterImage `
    -HostingUnitName $HostingUnitName `
    -ImageDefinitionName $DefinitionName `
    -ImageVersionNumber $Version.ImageVersionNumber

$NewSpecParams = @{
    NetworkMapping            = $NetworkMapping
    SourceImageVersionSpecUid = $SourceSpec.ImageVersionSpecUid
}

if ($MachineProfile) {
    $NewSpecParams["MachineProfile"] = $MachineProfile
}
if ($SpecCustomProperties) {
    $NewSpecParams["CustomProperties"] = $CustomProperties
}

& New-ProvImageVersionSpec @NewSpecParams
