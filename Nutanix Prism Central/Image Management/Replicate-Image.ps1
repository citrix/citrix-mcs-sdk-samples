<#
.SYNOPSIS
    Replicate a decoupling image to a cluster.
.DESCRIPTION
    Replicate-Image.ps1 replicates a prepared image to an additional cluster in the same Prism Central environment.
    The original version of this script is compatible with Citrix Virtual Apps and Desktops 7 2603.
.INPUTS
    1. DefinitionName: Name of the image definition.
    2. ImageVersionNumber: The version number of the image.
    3. StorageId: The cluster Id where the decoupling image will be replicated to. See Readme.md for how to get the ClusterId.
#>

# /*************************************************************************
# * Copyright © 2026. Cloud Software Group, Inc. All Rights Reserved.
# * This file is subject to the license terms contained
# * in the license file that is distributed with this file.
# *************************************************************************/

param(
    [string]$DefinitionName,
    [int]$ImageVersionNumber,
    [string]$StorageId
)

# Add Citrix snap-ins
Add-PSSnapin -Name "Citrix.Host.Admin.V2", "Citrix.MachineCreation.Admin.V2"

$prepedSpec = Get-ProvImageVersionSpec -ImageVersionNumber $ImageVersionNumber -ImageDefinitionName $DefinitionName | Where-Object IsPrepared -eq $True
if (-not $prepedSpec) { throw "No prepared image version spec found for image definition '$DefinitionName' and version $ImageVersionNumber." }

& Add-ProvImageVersionSpecInstance `
    -ImageVersionSpecUid $prepedSpec.ImageVersionSpecUid `
    -StorageId $StorageId
