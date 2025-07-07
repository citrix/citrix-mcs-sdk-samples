<#
.SYNOPSIS
    Edit the HostingConnection.
.DESCRIPTION
    Edit-HostingConnection.ps1 edits the HostingConnection properties.
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
    Get-Item -LiteralPath $connectionPath -ErrorAction stop
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

####################################################
# Step 4: Take Connection out of MaintenanceMode   #
####################################################

$maintenanceMode = $false
Set-Item -LiteralPath $connectionPath -MaintenanceMode $maintenanceMode