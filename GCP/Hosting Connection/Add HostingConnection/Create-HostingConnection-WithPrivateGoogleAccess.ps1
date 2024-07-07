<#
.SYNOPSIS
    Creates the HostingConnection.
.DESCRIPTION
    Create-HostingConnection-WithPrivateGoogleAccess.ps1 creates the HostingConnection with private Google access when ConnectionName, ZoneName, ServiceAccount_Email, zoneNames and UsePrivateWorkerPool are provided.
    The original version of this script is compatible with Citrix Virtual Apps and Desktops 7 2203 Long Term Service Release (LTSR).
#>

# /*************************************************************************
# * Copyright © 2024. Cloud Software Group, Inc. All Rights Reserved.
# * This file is subject to the license terms contained
# * in the license file that is distributed with this file.
# *************************************************************************/

# [User Input Required]
$ConnectionName = "GcpConnection-via-cloud-connector"
$ZoneName = "ZoneName"
$ServiceAccount_Email = "example@project.iam.gserviceaccount.com" # Use client_email field from JSON key for the service account. To create new key go to Gcp console -> Service Account -> Keys -> Add Key -> JSON
[bool] $UsePrivateWorkerPool = $false

# Enable Citrix PowerShell Cmdlets
Add-PSSnapin -Name "Citrix.Host.Admin.V2","Citrix.MachineCreation.Admin.V2","Citrix.Broker.Admin.V2"

$CustomProperties = '<CustomProperties xmlns="http://schemas.citrix.com/2014/xd/machinecreation" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">' `
					+ '<Property xsi:type="StringProperty" Name="ProxyHypervisorTrafficThroughConnector" Value="True"/>' `
					+ '<Property xsi:type="StringProperty" Name="UsePrivateWorkerPool" Value="' + $UsePrivateWorkerPool + '"/>' `
					+ '</CustomProperties>'

# Get private key
$PrivateKeyUserInput = Read-Host 'Please enter private key' -AsSecureString # Use private_key field from JSON key file
$EncryptedPrivateKey = ConvertFrom-SecureString -SecureString $PrivateKeyUserInput
$ServiceAccount_PrivateKey = ConvertTo-SecureString -String $EncryptedPrivateKey

##########################
# Step 1: Find Zone Uid. #
##########################

$zone = Get-ConfigZone -Name $ZoneName -ErrorAction 'SilentlyContinue'
$zoneUid = $zone.Uid
if($null -eq $zoneUid)
{
    throw "Could not find the zone (ZoneName): $($ZoneName). Verify the ZoneName exists."
}

#####################################################
# Step 3: Create the hosting connection. #
#####################################################

$connection = New-Item -Path @("XDHyp:\Connections\$($ConnectionName)") `
				-ConnectionType "Custom" `
				-CustomProperties $CustomProperties `
				-HypervisorAddress "http://cloud.google.com" `
				-Persist `
				-PluginId "GcpPluginFactory" `
				-Scope @() `
				-SecurePassword $ServiceAccount_PrivateKey `
				-UserName $ServiceAccount_Email `
				-ZoneUid $zoneUid

#####################################################
# Step 4: Create a broker hosting connection. #
#####################################################

New-BrokerHypervisorConnection -HypHypervisorConnectionUid $connection.HypervisorConnectionUid