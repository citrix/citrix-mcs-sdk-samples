<#
.SYNOPSIS
    Creates an image definition and the first image version.
.DESCRIPTION
    Create-ImageDefinitionAndVersion.ps1 creates a prepared image for MCS provisioning.
    The original version of this script is compatible with Citrix DaaS July 2025 Release (DDC 125).
.INPUTS
    1. DefinitionName: Name of the new image definition.
    2. ConnectionName: Name of the connection used.
    3. HostingUnitName: Name of the hosting unit used.
    4. MasterImage: Path to the master image.
    5. NetworkMapping: Specifies how the attached NICs are mapped to networks.
    6. ServiceOffering: The service offering used.
    7. MachineProfile: The machine profile used.
    8. Scope: One or more administrative scope names to assign to the image definition. Optional; defaults to none.
#>

# /*************************************************************************
# * Copyright © 2025. Cloud Software Group, Inc. All Rights Reserved.
# * This file is subject to the license terms contained
# * in the license file that is distributed with this file.
# *************************************************************************/

param(
    [string]$DefinitionName,
    [string]$ConnectionName,
    [string]$HostingUnitName,
    [string]$MasterImage,
    [hashtable]$NetworkMapping,
    [string]$MachineProfile,
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

Add-ProvImageDefinitionConnection -ImageDefinitionName $Definition.ImageDefinitionName -HypervisorConnectionName $ConnectionName

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

& New-ProvImageVersionSpec @NewSpecParams
