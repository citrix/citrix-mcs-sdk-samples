<#
.SYNOPSIS
    Creates a HostingConnection with Bypass Connector.
.DESCRIPTION
    Creates the HostingConnection to bypass connector and allow traffic from DDC to go directly to AWS and not via NGS proxy.

    The original version of this script is compatible with Citrix DaaS 128.
#>

# /*************************************************************************
# * Copyright © 2026. Cloud Software Group, Inc. All Rights Reserved.
# * This file is subject to the license terms contained
# * in the license file that is distributed with this file.
# *************************************************************************/

################################
# Step 0: Setup the parameters #
################################
# Add Citrix snap-ins
Add-PSSnapin -Name "Citrix.Host.Admin.V2","Citrix.MachineCreation.Admin.V2","Citrix.Broker.Admin.V2"

# [User Input Required] Setup parameters for creating hosting connection
$connectionName = "demo-hostingconnection"
$cloudRegion = "us-east-1"
$apiKey = "aaaaaaaaaaaaaaaaaaaa"
$zoneUid = "00000000-0000-0000-0000-000000000000"

$securePassword = Read-Host 'Please enter your secret key' -AsSecureString
$connectionPath = "XDHyp:\Connections\" + $connectionName

$customProperties = @"
<CustomProperties xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns="http://schemas.citrix.com/2014/xd/machinecreation">
<Property xsi:type="StringProperty" Name="BypassConnectorForAwsApiRequests" Value="True" />
</CustomProperties>
"@

########################################
# Step 1: Create a Hosting Connection. #
########################################

$connection = New-Item -Path $connectionPath `
-ConnectionType "Custom" -PluginId "AmazonWorkSpacesCoreMachineManagerFactory" `
-HypervisorAddress "https://workspaces-instances.$($cloudRegion).api.aws" `
-CustomProperties $customProperties `
-Persist -Scope @()`
-UserName $apiKey -SecurePassword $securePassword `
-ZoneUid $zoneUid

New-BrokerHypervisorConnection -HypHypervisorConnectionUid $connection.HypervisorConnectionUid
