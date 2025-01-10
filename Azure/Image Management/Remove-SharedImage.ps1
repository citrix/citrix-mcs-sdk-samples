<#
.SYNOPSIS
    Remove shared image from the specified hosting unit.
.DESCRIPTION
    Remove-SharedImage.ps1 removes a prepared image from the specified hosting unit.
    The original version of this script is compatible with Citrix Virtual Apps and Desktops 7 2411.
.INPUTS
    1. DefinitionName: Name of the image definition.
    2. ImageVersionNumber: The version number of the image.
    3. HostingUnitName: Name of the hosting unit to delete shared image.
#>

# /*************************************************************************
# * Copyright © 2024. Cloud Software Group, Inc. All Rights Reserved.
# * This file is subject to the license terms contained
# * in the license file that is distributed with this file.
# *************************************************************************/

param(
    [string]$DefinitionName,
    [int]$ImageVersionNumber,
    [string]$HostingUnitName
)

# Add Citrix snap-ins
Add-PSSnapin -Name "Citrix.Host.Admin.V2","Citrix.MachineCreation.Admin.V2"

$prepedSpec = Get-ProvImageVersionSpec -ImageVersionNumber $ImageVersionNumber -ImageDefinitionName $DefinitionName | Where-Object IsPrepared -eq $True

& Remove-ProvImageVersionSpecHostingUnit `
    -ImageVersionSpecUid $prepedSpec.ImageVersionSpecUid `
    -HostingUnitName $HostingUnitName
