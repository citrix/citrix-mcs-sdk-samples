<#
.SYNOPSIS
    Enables automatic Citrix Partner ID association on an Azure hosting connection.
.DESCRIPTION
    Enable-PartnerIdAssociation.ps1 sets the DisablePartnerIdAssociation custom property to false on an Azure hosting connection.
    This allows Citrix to automatically associate the Citrix Partner ID (353109) with the connection identity.
    The original version of this script is compatible with Citrix Virtual Apps and Desktops 7 2603.
#>

# /*************************************************************************
# * Copyright © 2026. Cloud Software Group, Inc. All Rights Reserved.
# * This file is subject to the license terms contained
# * in the license file that is distributed with this file.
# *************************************************************************/

# [User Input Required]
$ConnectionName = "AzureConnection"
$UserName = "AppId"
$secureUserInput = Read-Host 'Please enter your application secret' -AsSecureString
$encryptedInput = ConvertFrom-SecureString -SecureString $secureUserInput
$SecurePassword = ConvertTo-SecureString -String $encryptedInput

# Enable Citrix PowerShell Cmdlets
Add-PSSnapin -Name "Citrix.Host.Admin.V2"

##############################################################
# Step 1: Get the current custom properties                 #
##############################################################

$connectionPath = "XDHyp:\Connections\" + $ConnectionName

# Verify the connection exists
$connection = Get-Item -LiteralPath $connectionPath -ErrorAction SilentlyContinue
if ($null -eq $connection) {
    throw "Connection '$ConnectionName' not found. Please verify the connection name."
}

# Fetch current custom properties
$currentCustomProperties = $connection.CustomProperties
Write-Output "Current Custom Properties:"
Write-Output $currentCustomProperties

##############################################################
# Step 2: Construct new custom properties                   #
##############################################################

# Parse the existing custom properties XML
[xml]$customPropertiesXml = $currentCustomProperties

# Check if DisablePartnerIdAssociation exists
$existingProperty = $customPropertiesXml.CustomProperties.Property | Where-Object { $_.Name -eq "DisablePartnerIdAssociation" }

if ($existingProperty -and $existingProperty.Value -eq "false") {
    Write-Output "DisablePartnerIdAssociation is already set to false."
    Write-Output "Partner ID association is already enabled. No changes needed."
    exit 0
}

if ($existingProperty) {
    # Set the property to false to enable Partner ID association
    $existingProperty.Value = "false"
    Write-Output "Setting DisablePartnerIdAssociation property to false to enable Partner ID association"
} else {
    # Add the property set to false
    $newProperty = $customPropertiesXml.CreateElement("Property", "http://schemas.citrix.com/2014/xd/machinecreation")
    $newProperty.SetAttribute("type", "http://www.w3.org/2001/XMLSchema-instance", "StringProperty")
    $newProperty.SetAttribute("Name", "DisablePartnerIdAssociation")
    $newProperty.SetAttribute("Value", "false")
    $customPropertiesXml.CustomProperties.AppendChild($newProperty) | Out-Null
    Write-Output "Adding DisablePartnerIdAssociation property set to false"
}

$newCustomProperties = $customPropertiesXml.OuterXml

##############################################################
# Step 3: Update the hosting connection                     #
##############################################################

# Update the connection
try {
    Set-Item -LiteralPath $connectionPath `
        -CustomProperties $newCustomProperties `
        -UserName $UserName `
        -SecurePassword $SecurePassword `
        -ErrorAction Stop

    Write-Output "**** DisablePartnerIdAssociation has been set to false. Citrix will automatically associate the Partner ID (353109) with this connection once per day."
} catch {
    Write-Error "Failed to update the hosting connection: $_"
    exit 1
}