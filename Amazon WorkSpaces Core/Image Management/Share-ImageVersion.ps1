<#
.SYNOPSIS
    Share an image version with the specified Hosting Unit.
.DESCRIPTION
    Share-ImageVersion.ps1 shares a image version with the specified Hosting Unit.
    The original version of this script is compatible with Citrix DaaS September 2025 Release (DDC 126).
.INPUTS
    1. ImageVersionSpecUid: Uid of the given image version.
    2. HostingUnitName: Name of the hosting unit used.
    3. RunAsynchronously: optionally run the command as a background task
#>

# /*************************************************************************
# * Copyright © 2025. Cloud Software Group, Inc. All Rights Reserved.
# * This file is subject to the license terms contained
# * in the license file that is distributed with this file.
# *************************************************************************/

param(
    [string]$ImageVersionSpecUid,
    [string]$HostingUnitName,
    [boolean]$RunAsynchronously(Mandatory = $false)][boolean]$false
)

Add-PSSnapin -Name "Citrix.Host.Admin.V2", "Citrix.MachineCreation.Admin.V2"

Add-ProvImageVersionSpecHostingUnit -ImageVersionSpecUid $ImageVersionSpecUid -HostingUnitName $HostingUnitName
