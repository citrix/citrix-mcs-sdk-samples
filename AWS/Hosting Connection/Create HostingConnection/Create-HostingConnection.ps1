<#
.SYNOPSIS
    Creates the HostingConnection.
.DESCRIPTION
    Create-HostingConnection.ps1 creates the HostingConnection when connectionName, cloudRegion, SubscriptionId, apiKey, secretKey, and zoneUid are provided.
    The original version of this script is compatible with Citrix Virtual Apps and Desktops 7 2203 Long Term Service Release (LTSR).
#>

# /*************************************************************************
# * Copyright © 2024. Cloud Software Group, Inc.
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

$secureUserInput = Read-Host 'Please enter your secret key' -AsSecureString
$encryptedInput = ConvertFrom-SecureString -SecureString $secureUserInput
$securePassword = ConvertTo-SecureString -String $encryptedInput
$connectionPath = "XDHyp:\Connections\" + $connectionName

########################################
# Step 1: Create a Hosting Connection. #
########################################

$connection = New-Item -Path $connectionPath -ConnectionType "AWS" -HypervisorAddress "https://ec2.$($cloudRegion).amazonaws.com" -Persist -Scope @() -UserName $apiKey -SecurePassword $securePassword -ZoneUid $zoneUid

New-BrokerHypervisorConnection -HypHypervisorConnectionUid $connection.HypervisorConnectionUid