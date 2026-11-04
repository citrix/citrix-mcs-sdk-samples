<#
.SYNOPSIS
    Updates an existing prepared image version spec.
.DESCRIPTION
    Update-Image.ps1 updates the custom properties on an existing prepared image version spec.
    For Azure image management, Set-ProvImageVersionSpec currently supports updating
    SharedImageGalleryReplicaRatio and SharedImageGalleryReplicaMaximum.
    The image definition must use Azure Compute Gallery.
.INPUTS
    1. DefinitionName: Name of the image definition.
    2. ImageVersionNumber: The version number of the image.
    3. SharedImageGalleryReplicaRatio: Optional replica ratio for the prepared image.
    4. SharedImageGalleryReplicaMaximum: Optional maximum replica count for the prepared image.
    5. RunAsynchronously: Optional switch to return a task identifier before completion.
#>

# /*************************************************************************
# * Copyright © 2026. Cloud Software Group, Inc. All Rights Reserved.
# * This file is subject to the license terms contained
# * in the license file that is distributed with this file.
# *************************************************************************/

param(
    [string]$DefinitionName,
    [int]$ImageVersionNumber,
    [Parameter(Mandatory = $false)][int]$SharedImageGalleryReplicaRatio,
    [Parameter(Mandatory = $false)][int]$SharedImageGalleryReplicaMaximum,
    [switch]$RunAsynchronously
)

Add-PSSnapin -Name "Citrix.Host.Admin.V2", "Citrix.MachineCreation.Admin.V2"

if (-not $PSBoundParameters.ContainsKey("SharedImageGalleryReplicaRatio") -and -not $PSBoundParameters.ContainsKey("SharedImageGalleryReplicaMaximum")) {
    throw "Specify SharedImageGalleryReplicaRatio and/or SharedImageGalleryReplicaMaximum."
}

$preparedSpec = Get-ProvImageVersionSpec -ImageVersionNumber $ImageVersionNumber -ImageDefinitionName $DefinitionName | Where-Object IsPrepared -eq $True

if (-not $preparedSpec) {
    throw "No prepared image version spec was found for image definition '$DefinitionName' version '$ImageVersionNumber'."
}

$propertyLines = @()

if ($PSBoundParameters.ContainsKey("SharedImageGalleryReplicaRatio")) {
    $propertyLines += '<Property xsi:type="IntProperty" Name="SharedImageGalleryReplicaRatio" Value="{0}" />' -f $SharedImageGalleryReplicaRatio
}

if ($PSBoundParameters.ContainsKey("SharedImageGalleryReplicaMaximum")) {
    $propertyLines += '<Property xsi:type="IntProperty" Name="SharedImageGalleryReplicaMaximum" Value="{0}" />' -f $SharedImageGalleryReplicaMaximum
}

$customProperties = @"
<CustomProperties xmlns="http://schemas.citrix.com/2014/xd/machinecreation" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">
$($propertyLines -join [Environment]::NewLine)
</CustomProperties>
"@

$setParams = @{
    ImageVersionSpecUid = $preparedSpec.ImageVersionSpecUid
    CustomProperties    = $customProperties
}

if ($RunAsynchronously) {
    $setParams["RunAsynchronously"] = $true
}

& Set-ProvImageVersionSpec @setParams