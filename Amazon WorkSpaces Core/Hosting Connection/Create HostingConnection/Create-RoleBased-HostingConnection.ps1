<#
.SYNOPSIS
    Creates a Role Based HostingConnection.
.DESCRIPTION
    Create-RoleBased-HostingConnection.ps1 creates the HostingConnection when connectionName, cloudRegion, SubscriptionId, apiKey, secretKey, and zoneUid are provided.
    apiKey and secretKey's value must be "role_based_auth"
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
$connectionName = "demo-rolebased"
$cloudRegion = "us-east-1"
$apiKey = "role_based_auth"
$zoneUid = "00000000-0000-0000-0000-000000000000"

$securePassword = ConvertTo-SecureString -String $apiKey -AsPlainText -Force
$connectionPath = "XDHyp:\Connections\" + $connectionName

########################################
# Step 1: Create a Hosting Connection. #
########################################

# Create Connection
$connection = New-Item -Path $connectionPath `
-ConnectionType "Custom" -PluginId "AmazonWorkSpacesCoreMachineManagerFactory" `
-HypervisorAddress "https://workspaces-instances.$($cloudRegion).api.aws" `
-Persist -Scope @()`
-UserName $apiKey -SecurePassword $securePassword `
-ZoneUid $zoneUid

New-BrokerHypervisorConnection -HypHypervisorConnectionUid $connection.HypervisorConnectionUid