<#
.SYNOPSIS
    Creates the HostingConnection with ProxyHypervisorTrafficThroughConnector.
.DESCRIPTION
    Create-HostingConnection.ps1 creates the HostingConnection when ConnectionName, UserName, SubscriptionId, TenantId, Password, and
    zoneNames are provided. This script helps you create hosting connection with ProxyHypervisorTrafficThroughConnector property.
    The original version of this script is compatible with Citrix Virtual Apps and Desktops 7 2203 Long Term Service Release (LTSR).
#>

# /*************************************************************************
# * Copyright © 2024. Cloud Software Group, Inc. All Rights Reserved.
# * This file is subject to the license terms contained
# * in the license file that is distributed with this file.
# *************************************************************************/

# [User Input Required]
$ConnectionName = "AzureConnection"
$UserName = "AppId" #should be Guid
$SubscriptionId = "SubscriptionId"  #should be Guid
$TenantId ="TenantId"  #should be Guid
$zoneName = "zoneName"

# Enable Citrix PowerShell Cmdlets
Add-PSSnapin -Name "Citrix.Host.Admin.V2","Citrix.MachineCreation.Admin.V2","Citrix.Broker.Admin.V2"

$secureUserInput = Read-Host 'Please enter your application secret' -AsSecureString
$encryptedInput = ConvertFrom-SecureString -SecureString $secureUserInput
$SecureApplicationPassword = ConvertTo-SecureString -String $encryptedInput

$HypervisorAddress = "https://management.azure.com/"
$Metadata = @{
    "Citrix_Broker_MaxAbsoluteNewActionsPerMinute"="2000";
    "Citrix_Broker_MaxPowerActionsPercentageOfDesktops"="100";
    "Citrix_Broker_MaxAbsolutePvDPowerActions"="50";
    "Citrix_Broker_MaxAbsoluteActiveActions"="500";
    "Citrix_Broker_MaxPvdPowerActionsPercentageOfDesktops"="25";
	"Citrix_Broker_ExtraSpinUpTime"="240"
}
$CustomProperties = '<CustomProperties xmlns="http://schemas.citrix.com/2014/xd/machinecreation" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">' `
+ '<Property xsi:type="StringProperty" Name="SubscriptionId" Value="' + $SubscriptionId + '" />'`
+ '<Property xsi:type="StringProperty" Name="ManagementEndpoint" Value="https://management.azure.com/" />'`
+ '<Property xsi:type="StringProperty" Name="AuthenticationAuthority" Value="https://login.microsoftonline.com/" />'`
+ '<Property xsi:type="StringProperty" Name="StorageSuffix" Value="core.windows.net" />'`
+ '<Property xsi:type="StringProperty" Name="TenantId" Value="' + $TenantId + '" />'`
+ '<Property xsi:type="StringProperty" Name="ProxyHypervisorTrafficThroughConnector" Value="True" />'`
+ '</CustomProperties>'


##########################
# Step 1: Find Zone Uid. #
##########################

$zoneUid = $null
$zone = Get-ConfigZone -Name $zoneName -ErrorAction 'SilentlyContinue'
$zoneUid = $zone.Uid
if($null -eq $zoneUid)
{
    throw "Could not find the zone (zoneName): $($zoneName). Verify the zoneName exists or try the default 'Primary.'"
}

#####################################################
# Step 2: Create the hosting connection. #
#####################################################

$connection = New-Item -ConnectionType "Custom" `
	-CustomProperties $CustomProperties`
	-HypervisorAddress @($HypervisorAddress) `
	-Path @("XDHyp:\Connections\$($ConnectionName)") `
	-Metadata $Metadata `
	-Persist `
	-PluginId "AzureRmFactory" `
	-Scope @() `
	-SecurePassword $SecureApplicationPassword `
	-UserName $UserName `
	-ZoneUid $zoneUid

#####################################################
# Step 3: Create a broker hosting connection. #
#####################################################

New-BrokerHypervisorConnection -HypHypervisorConnectionUid $connection.HypervisorConnectionUid