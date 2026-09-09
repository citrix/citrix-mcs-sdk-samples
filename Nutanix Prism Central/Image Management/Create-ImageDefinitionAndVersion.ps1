<#
.SYNOPSIS
    Creates an image definition and the first image version.
.DESCRIPTION
    Create-ImageDefinitionAndVersion.ps1 creates an image definition and the first image version (a master spec and a prepared spec) for MCS provisioning.
    The original version of this script is compatible with Citrix Virtual Apps and Desktops 7 2411.
.INPUTS
    1. DefinitionName: Name of the new image definition.
    2. ConnectionName: Name of the connection used.
    3. HostingUnitName: Name of the hosting unit used.
    4. MasterImage: Path to the master image.
    5. NetworkMapping: Specifies how the attached NICs are mapped to networks.
    6. ServiceOffering: The service offering used.
    7. MachineProfile: The machine profile used.
    8. ConnCustomProperties: Custom properties for the connection. You need to specify the primary clusterId where the prepared image will be placed on. See Readme.md for how to get and specify the ClusterId in CustomProperties.
    9. SpecCustomProperties: Custom properties for the image version spec.
    10. AdditionalStorageIds: The cluster id where the prepared image will be replicated to. See Readme.md for how to get the ClusterId.
    11. Scope: One or more administrative scope names to assign to the image definition. Optional; defaults to none.
#>

# /*************************************************************************
# * Copyright © 2026. Cloud Software Group, Inc. All Rights Reserved.
# * This file is subject to the license terms contained
# * in the license file that is distributed with this file.
# *************************************************************************/

param(
    [string]$DefinitionName,
    [string]$ConnectionName,
    [string]$HostingUnitName,
    [string]$MasterImage,
    [hashtable]$NetworkMapping,
    [string]$ServiceOffering,
    [Parameter(Mandatory = $false)][string]$MachineProfile,
    [Parameter(Mandatory = $false)][string]$ConnCustomProperties,
    [Parameter(Mandatory = $false)][string]$SpecCustomProperties,
    [Parameter(Mandatory = $false)][string]$AdditionalStorageIds,
    [Parameter(Mandatory = $false)][string[]]$Scope = @()
)

# Enable Citrix PowerShell Cmdlets
Add-PSSnapin -Name "Citrix.Host.Admin.V2", "Citrix.MachineCreation.Admin.V2"

$NewDefinitionParams = @{
    ImageDefinitionName = $DefinitionName
    OsType              = "Windows"
    VDASessionSupport   = "MultiSession"
}

# The -Scope parameter requires Citrix DaaS DDC 129 or later. Only pass it when scopes are supplied.
if ($Scope) {
    $NewDefinitionParams["Scope"] = $Scope
}

$Definition = New-ProvImageDefinition @NewDefinitionParams

$Version = New-ProvImageVersion -ImageDefinitionName $Definition.ImageDefinitionName

Add-ProvImageDefinitionConnection -ImageDefinitionName $Definition.ImageDefinitionName -HypervisorConnectionName $ConnectionName -CustomProperties $ConnCustomProperties

$SourceSpec = Add-ProvImageVersionSpec -MasterImagePath $MasterImage `
    -HostingUnitName $HostingUnitName `
    -ImageDefinitionName $DefinitionName `
    -ImageVersionNumber $Version.ImageVersionNumber

$NewSpecParams = @{
    NetworkMapping            = $NetworkMapping
    SourceImageVersionSpecUid = $SourceSpec.ImageVersionSpecUid
    ServiceOffering           = $ServiceOffering
}

if ($MachineProfile) {
    $NewSpecParams["MachineProfile"] = $MachineProfile
}
if ($SpecCustomProperties) {
    $NewSpecParams["CustomProperties"] = $SpecCustomProperties
}
if ($AdditionalStorageIds) {
    $NewSpecParams["AdditionalStorageIds"] = $AdditionalStorageIds
}

& New-ProvImageVersionSpec @NewSpecParams
