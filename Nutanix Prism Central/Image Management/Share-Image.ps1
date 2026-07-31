<#
.SYNOPSIS
    Shares a prepared image to a hosting unit in a different hosting connection.
.DESCRIPTION
    Share-Image.ps1 shares a prepared image to a hosting unit in a different hosting connection (different Prism Central).
    The original version of this script is compatible with Citrix Virtual Apps and Desktops 7 2603.
.INPUTS
    1. DefinitionName: Name of the image definition.
    2. ImageVersionNumber: The version number of the image.
    3. HostingUnitName: The name of the hosting unit in the target hosting connection.
    4. StorageId: The cluster Id where the prepared image will be replicated to. See Readme.md for how to get the ClusterId.
#>

# /*************************************************************************
# * Copyright © 2026. Cloud Software Group, Inc. All Rights Reserved.
# * This file is subject to the license terms contained
# * in the license file that is distributed with this file.
# *************************************************************************/

param(
    [string]$DefinitionName,
    [int]$ImageVersionNumber,
    [string]$HostingUnitName,
    [string]$StorageId
)

# Add Citrix snap-ins
Add-PSSnapin -Name "Citrix.Host.Admin.V2", "Citrix.MachineCreation.Admin.V2"

$prepedSpec = Get-ProvImageVersionSpec -ImageVersionNumber $ImageVersionNumber -ImageDefinitionName $DefinitionName | Where-Object IsPrepared -eq $True
if (-not $prepedSpec) { throw "No prepared image version spec found for image definition '$DefinitionName' and version $ImageVersionNumber." }

& Add-ProvImageVersionSpecHostingUnit `
    -ImageVersionSpecUid $prepedSpec.ImageVersionSpecUid `
    -HostingUnitName $HostingUnitName `
    -StorageId $StorageId
