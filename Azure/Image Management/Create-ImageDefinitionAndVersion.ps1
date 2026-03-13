<#
.SYNOPSIS
    Creates an image definition and the first image version.
.DESCRIPTION
    Create-Image.ps1 creates a prepared image for MCS provisioning.
    The original version of this script is compatible with Citrix Virtual Apps and Desktops 7 2411.
.INPUTS
    1. DefinitionName: Name of the new image definition.
    2. ConnectionName: Name of the connection used.
    3. HostingUnitName: Name of the hosting unit used.
    4. MasterImage: Path to the master image.
    5. NetworkMapping: Specifies how the attached NICs are mapped to networks.
    6. ServiceOffering: The service offering used.
    7. MachineProfile: The machine profile used.
    8. ConnCustomProperties: Custom properties for the image definition connection.
       Image definition connection level properties:
       - ResourceGroups: Resource groups used to contain prepared images. If not specified, 
         Citrix managed resource groups are created automatically.
       - UseSharedImageGallery: Use Azure Compute Gallery (Shared Image Gallery) for storing 
         prepared images. Set to True to use Compute Gallery, False or unspecified to use snapshots.
       - ImageGallery: Name of an existing Azure Compute Gallery. Only applicable when 
         UseSharedImageGallery is set to True. If not specified, a Citrix-managed gallery 
         will be created automatically.
    9. SpecCustomProperties: Custom properties for the image version spec.
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
    [string]$ConnectionName,
    [string]$HostingUnitName,
    [string]$MasterImage,
    [hashtable]$NetworkMapping,
    [string]$ServiceOffering,
    [Parameter(Mandatory = $false)][string]$MachineProfile,
    [Parameter(Mandatory = $false)][string]$ConnCustomProperties,
    [Parameter(Mandatory = $false)][string]$SpecCustomProperties
)

# Enable Citrix PowerShell Cmdlets
Add-PSSnapin -Name "Citrix.Host.Admin.V2", "Citrix.MachineCreation.Admin.V2"

$Definition = New-ProvImageDefinition -ImageDefinitionName $DefinitionName -OsType Windows -VDASessionSupport MultiSession

$Version = New-ProvImageVersion -ImageDefinitionName $Definition.ImageDefinitionName

# Image definition connection level custom properties:
#   - ResourceGroups: Resource groups used to contain prepared images (if not specified, Citrix managed resource groups are created)
#   - UseSharedImageGallery: Use Azure Compute Gallery for storing prepared images (set to True to use gallery, False/unspecified for snapshots)
#   - ImageGallery: Name of an existing Azure Compute Gallery (only applicable when UseSharedImageGallery=True)
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

# Image version spec level custom properties:
#   - PreparedImageStorageType: Storage type (Standard_LRS, Standard_ZRS, Premium_LRS, StandardSSD_LRS). Default: Standard_LRS
#   - DiskEncryptionSetId: Azure Disk Encryption Set ID (must be valid Azure resource ID). Cannot be changed after creation
if ($SpecCustomProperties) {
    $NewSpecParams["CustomProperties"] = $SpecCustomProperties
}

& New-ProvImageVersionSpec @NewSpecParams
