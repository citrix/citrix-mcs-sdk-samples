<#
.SYNOPSIS
    Edit the HostingUnit.
.DESCRIPTION
    Edit-HostingUnit.ps1 edits the following HostingUnit properties (when provided):
        * The hosting unit name via RenameHostingUnitName
        * The VPC/Subnet via UpdateVPC/UpdateSubnet. The Following properties must also be provided:
			* GcpProjectName
			* Region
			* ConnectionName
    The original version of this script is compatible with Citrix Virtual Apps and Desktops 7 2203 Long Term Service Release (LTSR).
#>

# /*************************************************************************
# * Copyright © 2024. Cloud Software Group, Inc. All Rights Reserved.
# * This file is subject to the license terms contained
# * in the license file that is distributed with this file.
# *************************************************************************/

# [User Input Required]
$HostingUnitName ="GcpHostingUnitName"
$ConnectionName = "GcpConnection"
$RenameHostingUnitName = "RenameGcpHostingUnitName"
$UpdateVPC = ""
$UpdateSubnet = ""
$Region = "region" # e.g . "us-central1"
$GcpProjectName = "GCP project name"

# Enable Citrix PowerShell Cmdlets
Add-PSSnapin -Name "Citrix.Host.Admin.V2","Citrix.MachineCreation.Admin.V2"

$HostingUnitPath = "XDHyp:\HostingUnits\" + $HostingUnitName

$HostingUnit = Get-Item -Path $HostingUnitPath
if($null -eq $HostingUnit)
{
    throw "Provided HostingUnitName is not valid. Please provide the correct HostingUnitName."
}

###########################################
# To update vpc and subnet in HostingUnit #
###########################################

if($UpdateVPC -ne "" -AND $UpdateSubnet -ne "")
{
	$ConnectionPath = "XDHyp:\Connections\$ConnectionName"
	$RootPath = "$ConnectionPath\$GcpProjectName.project\$Region.region"
	# For shared VPCs, replace '.virtualprivatecloud' in below line with '.sharedvirtualprivatecloud'
    $NetworkPath1 = $RootPath + "\$UpdateVPC.virtualprivatecloud\$UpdateSubnet.network"
	# For multi-network scenario, please add more subnet paths with the same format and create comma seperated list. e.g. $NetworkPath = @($NetworkPath1,$NetworkPath2)
	$NetworkPaths = @($NetworkPath1)
    Set-Item -NetworkPath $NetworkPaths -Path $HostingUnitPath
}

#############################
# To rename the HostingUnit #
#############################

if($RenameHostingUnitName -ne "")
{
    Rename-Item -NewName $RenameHostingUnitName -Path $HostingUnitPath
}