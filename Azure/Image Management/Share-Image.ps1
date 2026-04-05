<#
.SYNOPSIS
    Shares an image version to another hosting unit.
.DESCRIPTION
    Share-Image.ps1 shares a prepared image to another hosting unit.
    The original version of this script is compatible with Citrix Virtual Apps and Desktops 7 2411.
.INPUTS
    1. DefinitionName: Name of the image definition.
    2. ImageVersionNumber: The version number of the image.
    3. HostingUnitName: Name of the hosting unit to share image.
    4. CustomProperties: Custom properties for the image version spec hosting unit.
       Image version spec hosting unit level properties (when sharing to other hosting units):
       - PreparedImageStorageType: Storage type in the target hosting unit. Valid values: Standard_LRS, 
         Standard_ZRS, Premium_LRS. Default: Standard_LRS. 
         For extended zones, only Premium_LRS is supported.
       - DiskEncryptionSetId: Azure Disk Encryption Set ID for the target hosting unit. Must be a 
         valid Azure resource ID accessible by the target hosting unit.
#>

# /*************************************************************************
# * Copyright © 2024. Cloud Software Group, Inc. All Rights Reserved.
# * This file is subject to the license terms contained
# * in the license file that is distributed with this file.
# *************************************************************************/

param(
    [string]$DefinitionName,
    [int]$ImageVersionNumber,
    [string]$HostingUnitName,
    [Parameter(Mandatory = $false)][string]$CustomProperties
)

# Add Citrix snap-ins
Add-PSSnapin -Name "Citrix.Host.Admin.V2", "Citrix.MachineCreation.Admin.V2"

$prepedSpec = Get-ProvImageVersionSpec -ImageVersionNumber $ImageVersionNumber -ImageDefinitionName $DefinitionName | Where-Object IsPrepared -eq $True

$addParams = @{
    ImageVersionSpecUid = $prepedSpec.ImageVersionSpecUid
    HostingUnitName     = $HostingUnitName
}

# Image version spec hosting unit level custom properties (when sharing to other hosting units):
#   - PreparedImageStorageType: Storage type in the target hosting unit (Standard_LRS, Standard_ZRS, Premium_LRS)
#   - DiskEncryptionSetId: Azure Disk Encryption Set ID accessible by the target hosting unit (must be valid Azure resource ID)
if ($CustomProperties) {
    $addParams["CustomProperties"] = $CustomProperties
}

& Add-ProvImageVersionSpecHostingUnit @addParams
