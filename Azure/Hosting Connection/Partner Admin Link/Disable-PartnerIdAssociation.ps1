<#
.SYNOPSIS
    Disables automatic Citrix Partner ID association on an Azure hosting connection.
.DESCRIPTION
    Disable-PartnerIdAssociation.ps1 sets the DisablePartnerIdAssociation custom property to true on an Azure hosting connection.
    This prevents Citrix from automatically associating the Citrix Partner ID (353109) with the connection identity.
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

# Check if DisablePartnerIdAssociation already exists
$existingProperty = $customPropertiesXml.CustomProperties.Property | Where-Object { $_.Name -eq "DisablePartnerIdAssociation" }

if ($existingProperty -and $existingProperty.Value -eq "true") {
    Write-Output "`nDisablePartnerIdAssociation is already set to true."
    Write-Output "No changes needed."
    exit 0
}

if ($existingProperty) {
    # Update existing property
    $existingProperty.Value = "true"
    Write-Output "Updating existing DisablePartnerIdAssociation property to true"
} else {
    # Add new property
    $newProperty = $customPropertiesXml.CreateElement("Property", "http://schemas.citrix.com/2014/xd/machinecreation")
    $newProperty.SetAttribute("type", "http://www.w3.org/2001/XMLSchema-instance", "StringProperty")
    $newProperty.SetAttribute("Name", "DisablePartnerIdAssociation")
    $newProperty.SetAttribute("Value", "true")
    $customPropertiesXml.CustomProperties.AppendChild($newProperty) | Out-Null
    Write-Output "Adding DisablePartnerIdAssociation property"
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

    Write-Output "**** DisablePartnerIdAssociation has been set to true. Citrix will no longer automatically associate the Partner ID with this connection."
} catch {
    Write-Error "Failed to update the hosting connection: $_"
    exit 1
}