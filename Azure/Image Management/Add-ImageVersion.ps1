<#
.SYNOPSIS
    Add an image version (include a master spec and a prepared spec) to the specified image definition.
.DESCRIPTION
    Add-ImageVersion.ps1 adds a image version, a master image, and a prepared image to the specified image definition.
    The original version of this script is compatible with Citrix Virtual Apps and Desktops 7 2411.
.INPUTS
    1. DefinitionName: Name of the image definition.
    2. HostingUnitName: Name of the hosting unit used.
    3. MasterImage: Path to the master image.
    4. NetworkMapping: Specifies how the attached NICs are mapped to networks.
    5. ServiceOffering: The service offering used.
    6. MachineProfile: The machine profile used.
    7. CustomProperties: Custom properties for the image version spec.
       Image version spec level properties:
       - PreparedImageStorageType: Storage type for the prepared image. Valid values: Standard_LRS, 
         Standard_ZRS, Premium_LRS, StandardSSD_LRS (for standard regions). Default: Standard_LRS. 
         For extended zones, only Premium_LRS and StandardSSD_LRS are supported.
       - DiskEncryptionSetId: Azure Disk Encryption Set ID for server-side encryption. Must be a 
         valid Azure resource ID. If not specified, platform-managed encryption is used. Cannot 
         be changed after the prepared image is created.
#>

# /*************************************************************************
# * Copyright © 2024. Cloud Software Group, Inc. All Rights Reserved.
# * This file is subject to the license terms contained
# * in the license file that is distributed with this file.
# *************************************************************************/

param(
    [string]$DefinitionName,
    [string]$HostingUnitName,
    [string]$MasterImage,
    [hashtable]$NetworkMapping,
    [string]$ServiceOffering,
    [Parameter(Mandatory = $false)][string]$MachineProfile,
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
    ServiceOffering           = $ServiceOffering
}

if ($MachineProfile) {
    $NewSpecParams["MachineProfile"] = $MachineProfile
}
if ($CustomProperties) {
    $NewSpecParams["CustomProperties"] = $CustomProperties
}

# Image version spec level custom properties:
#   - PreparedImageStorageType: Storage type (Standard_LRS, Standard_ZRS, Premium_LRS, StandardSSD_LRS). Default: Standard_LRS
#   - DiskEncryptionSetId: Azure Disk Encryption Set ID (must be valid Azure resource ID). Cannot be changed after creation
& New-ProvImageVersionSpec @NewSpecParams
