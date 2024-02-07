<#
.SYNOPSIS
    Creates the HostingUnit.
.DESCRIPTION
    Create-HostingUnit.ps1 creates the HostingUnit when ConnectionName, HostingUnitName, HostGroup, HostName, NetworkName and StorageName are provided.
#>

# /*************************************************************************
# * Copyright © 2024. Cloud Software Group, Inc.
# * This file is subject to the license terms contained
# * in the license file that is distributed with this file.
# *************************************************************************/

# [User Input Required]
$ConnectionName = "SCVMMConnection"
$HostingUnitName ="SCVMMUnit"
$HostGroup = "HostGroup"
$HostName = "Host"
$NetworkName = "Network"
$StorageName = "Storage.storage" #Example: storage-name.domain-name.local.storage


# Enable Citrix PowerShell Cmdlets
Add-PSSnapin -Name "Citrix.Host.Admin.V2","Citrix.MachineCreation.Admin.V2"

$HostingUnitPath = "XDHyp:\HostingUnits\$HostingUnitName"
$RootPath = "XDHyp:\Connections\$ConnectionName\$HostGroup.hostgroup\$HostName.host"
$NetworkPath = "$RootPath\$NetworkName.network"
$StoragePath = "$RootPath\$StorageName"

####################################
# Step 1: Create the hosting unit. #
####################################

New-Item -HypervisorConnectionName  $ConnectionName `
	-NetworkPath @($NetworkPath) `
	-Path @($HostingUnitPath) `
	-PersonalvDiskStoragePath @() `
	-RootPath $RootPath `
	-StoragePath @($StoragePath)