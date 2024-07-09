<#
.SYNOPSIS
    Edit the HostingConnection.
.DESCRIPTION
    Edit-HostingConnection.ps1 edits the HostingConnection properties.
    The original version of this script is compatible with Citrix Virtual Apps and Desktops 7 2203 Long Term Service Release (LTSR).
#>

# /*************************************************************************
# * Copyright © 2024. Cloud Software Group, Inc. All Rights Reserved.
# * This file is subject to the license terms contained
# * in the license file that is distributed with this file.
# *************************************************************************/

################################
# Step 0: Setup the parameters #
################################
# Add Citrix snap-ins
Add-PSSnapin -Name "Citrix.Host.Admin.V2","Citrix.MachineCreation.Admin.V2"

# [User Input Required] Setup parameters for editing the hosting connection
$connectionName = "demo-hostingconnection"
$renameConnection = "demo-renameconnection"
$maintenanceMode = $true
$apiKey = "aaaaaaaaaaaaaaaaaaaa"

$secureUserInput = Read-Host 'Please enter your secret key' -AsSecureString
$encryptedInput = ConvertFrom-SecureString -SecureString $secureUserInput
$securePassword = ConvertTo-SecureString -String $encryptedInput

$connectionPath = "XDHyp:\Connections\" + $connectionName

#########################################
# Step 1: Check if the connection exist #
#########################################
try
{
    $temp = Get-Item -LiteralPath $connectionPath -ErrorAction stop
}
catch
{
    throw "Connection does not exist"
}

####################################################
# Step 2: Change the Hosting Connection properties #
####################################################

Set-Item -LiteralPath $connectionPath -MaintenanceMode $maintenanceMode -UserName $apiKey -SecurePassword $securePassword

#########################################
# Step 3: Rename the Hosting Connection #
#########################################

Rename-Item -NewName $renameConnection -Path $connectionPath