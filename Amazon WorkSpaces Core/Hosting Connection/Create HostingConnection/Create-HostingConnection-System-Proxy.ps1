<#
.SYNOPSIS
    Creates a HostingConnection with System Proxy.
.DESCRIPTION
    Creates the HostingConnection when the Cloud Connector is configured to use a system proxy (WinHTTP Proxy).

    The original version of this script is compatible with Citrix DaaS July 2025 Release (DDC 125).
#>

# /*************************************************************************
# * Copyright © 2025. Cloud Software Group, Inc. All Rights Reserved.
# * This file is subject to the license terms contained
# * in the license file that is distributed with this file.
# *************************************************************************/

################################
# Step 0: Setup the parameters #
################################
# Add Citrix snap-ins
Add-PSSnapin -Name "Citrix.Host.Admin.V2","Citrix.MachineCreation.Admin.V2"

# [User Input Required] Setup parameters for creating hosting connection
$connectionName = "demo-hostingconnection"
$cloudRegion = "us-east-1"
$apiKey = "aaaaaaaaaaaaaaaaaaaa"
$zoneUid = "00000000-0000-0000-0000-000000000000"

$securePassword = Read-Host 'Please enter your secret key' -AsSecureString
$connectionPath = "XDHyp:\Connections\" + $connectionName

$customProperties = @"
<CustomProperties xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns="http://schemas.citrix.com/2014/xd/machinecreation">
<Property xsi:type="StringProperty" Name="UseSystemProxyForHypervisorTrafficOnConnectors" Value="True" />
</CustomProperties>
"@

########################################
# Step 1: Create a Hosting Connection. #
########################################

$connection = New-Item -Path $connectionPath `
-ConnectionType "Custom" -PluginId "AmazonWorkSpacesCoreMachineManagerFactory" `
-HypervisorAddress "https://workspaces-instances.$($cloudRegion).api.aws" `
-CustomProperties> $customProperties `
-Persist -Scope @()`
-UserName $apiKey -SecurePassword $securePassword `
-ZoneUid $zoneUid

New-BrokerHypervisorConnection -HypHypervisorConnectionUid $connection.HypervisorConnectionUid
