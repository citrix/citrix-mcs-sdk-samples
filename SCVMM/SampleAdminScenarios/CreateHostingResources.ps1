<#
.SYNOPSIS
    Creates a hosting conection and hosting resources.
.DESCRIPTION
    CreateHostingResources creates hosting resources in SCVMM.
    This script is similar to the "Add Connection and Resources" button in Citrix Studio.
    The original version of this script is compatible with Citrix Virtual Apps and Desktops 7 2203 Long Term Service Release (LTSR).
#>

# /*************************************************************************
# * Copyright © 2024. Cloud Software Group, Inc. All Rights Reserved.
# * This file is subject to the license terms contained
# * in the license file that is distributed with this file.
# *************************************************************************/

# Add Citrix snap-ins
Add-PSSnapin -Name "Citrix.Host.Admin.V2","Citrix.MachineCreation.Admin.V2"

########################################
# Step 1: Create a Hosting Connection. #
########################################
# [User Input Required] Setup parameters for creating hosting connection
$HypervisorAddress = "HypervisorAddress" #Example: hypervisor-name.domain-name.local
$ConnectionName = "SCVMMConnection"
$UserName = "UserName" #Example: domain-name\user-name
$zoneName = "zoneName" #If unknown, use the default 'Primary'

$ConnectionType = "Custom"

$secureUserInput = Read-Host 'Please enter your domain password' -AsSecureString
$encryptedInput = ConvertFrom-SecureString -SecureString $secureUserInput
$SecureApplicationPassword = ConvertTo-SecureString -String $encryptedInput

$Metadata = @{
    "Citrix_Broker_MaxAbsoluteNewActionsPerMinute"="10";
    "Citrix_Broker_MaxPowerActionsPercentageOfDesktops"="10";
    "Citrix_Broker_MaxAbsolutePvDPowerActions"="50";
    "Citrix_Broker_MaxAbsoluteActiveActions"="50";
    "Citrix_Broker_MaxPvdPowerActionsPercentageOfDesktops"="25";
	"Citrix_Broker_ExtraSpinUpTime"="240"
}


##########################
# Step 1: Find Zone Uid. #
##########################

$zoneUid = $null
$zone = Get-ConfigZone -Name $zoneName -ErrorAction 'SilentlyContinue'
$zoneUid = $zone.Uid
if($null -eq $zoneUid)
{
    throw "Could not find the zone (zoneName): $zoneName. Verify the zoneName exists or try the default 'Primary.'"
}

#####################################################
# Step 2: Create the hosting connection. #
#####################################################

$connection = New-Item -ConnectionType $ConnectionType `
	-CustomProperties "" `
	-HypervisorAddress @($HypervisorAddress) `
	-Path @("XDHyp:\Connections\$ConnectionName") `
	-Metadata $Metadata `
	-Persist `
	-PluginId "MicrosoftPSFactory" `
	-Scope @() `
	-SecurePassword $SecureApplicationPassword `
	-UserName $UserName `
	-ZoneUid $zoneUid

#####################################################
# Step 3: Create a broker hosting connection. #
#####################################################

New-BrokerHypervisorConnection -HypHypervisorConnectionUid $connection.HypervisorConnectionUid

##################################
# Step 4: Create a Hosting Unit. #
##################################
# [User Input Required] Setup parameters for creating hosting unit
$HostingUnitName ="SCVMMUnit"
$HostGroup = "HostGroup"
$HostName = "Host"
$NetworkName = "Network"
$StorageName = "Storage.storage" #Example: storage-name.domain-name.local.storage
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