<#
.SYNOPSIS
    Creates the HostingConnection.
.DESCRIPTION
    Create-HostingConnection.ps1 creates the HostingConnection when HypervisorAddress, ConnectionName, UserName, Password, and
    zoneNames are provided.
    The original version of this script is compatible with Citrix Virtual Apps and Desktops 7 2203 Long Term Service Release (LTSR).
#>

# /*************************************************************************
# * Copyright © 2024. Cloud Software Group, Inc.
# * This file is subject to the license terms contained
# * in the license file that is distributed with this file.
# *************************************************************************/

# [User Input Required]
$HypervisorAddress = "HypervisorAddress" #Example: hypervisor-name.domain-name.local
$ConnectionName = "SCVMMConnection"
$UserName = "UserName" #Example: domain-name\user-name
$zoneName = "zoneName" #If unknown, use the default 'Primary'

# Enable Citrix PowerShell Cmdlets
Add-PSSnapin -Name "Citrix.Host.Admin.V2","Citrix.MachineCreation.Admin.V2"

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