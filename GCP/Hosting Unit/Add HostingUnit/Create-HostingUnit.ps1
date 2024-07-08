<#
.SYNOPSIS
    Creates the HostingUnit.
.DESCRIPTION
    Create-HostingUnit.ps1 creates the HostingUnit when ConnectionName, Region, VPC, Subnet, HostingUnitName and GcpProjectName are provided.
    The original version of this script is compatible with Citrix Virtual Apps and Desktops 7 2203 Long Term Service Release (LTSR).
#>

# /*************************************************************************
# * Copyright © 2024. Cloud Software Group, Inc. All Rights Reserved.
# * This file is subject to the license terms contained
# * in the license file that is distributed with this file.
# *************************************************************************/

# [User Input Required]
$ConnectionName = "GcpConnection"
$Region = "region" #e.g. us-central1
$VPC = "vpc-name"
$Subnet = "subnet-name"
$HostingUnitName = "GcpHostingUnitName"
$GcpProjectName = "GCP project name"

# Enable Citrix PowerShell Cmdlets
Add-PSSnapin -Name "Citrix.Host.Admin.V2","Citrix.MachineCreation.Admin.V2"

# Create path variables
$ConnectionPath = "XDHyp:\Connections\$connectionName"
$HostingUnitPath = "XDHyp:\HostingUnits\$HostingUnitName"
$RootPath = "$ConnectionPath\$GcpProjectName.project\$Region.region"

# Note - For shared VPC, replace '.virtualprivatecloud' in below line with '.sharedvirtualprivatecloud'
$NetworkPath = $RootPath + "\$VPC.virtualprivatecloud\$Subnet.network"
# For multi-network scenario, please add more subnet paths with the same format and create a comma seperated list. e.g. $NetworkPath = @($NetworkPath1,$NetworkPath2)

####################################
# Step 1: Create the hosting unit. #
####################################

New-Item -HypervisorConnectionName  $ConnectionName `
	-NetworkPath @($NetworkPath) `
	-Path @($HostingUnitPath) `
	-PersonalvDiskStoragePath @() `
	-RootPath $RootPath `
	-StoragePath @()