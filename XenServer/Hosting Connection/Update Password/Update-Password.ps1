<#
.SYNOPSIS
    Update the password of an existing hosting connection.
.DESCRIPTION
    The `Update-Password.ps1` script is designed to update the password of an existing hosting connection.
    The original version of this script is compatible with Citrix Virtual Apps and Desktops 7 2203 Long Term Service Release (LTSR).
.INPUTS
    1. ConnectionName: The name of the hosting connection to update.
    2. UserName: The user name of the hypervisor connection.
    3. AdminAddress: The primary DDC address.
.OUTPUTS
    N/A
.NOTES
    Version      : 1.0.0
    Author       : Citrix Systems, Inc.
.EXAMPLE
    .\Update-Password.ps1 `
        -ConnectionName "MyConnection" `
        -UserName "MyUserName" `
        -AdminAddress "MyDDC.MyDomain.local"
#>

# /*************************************************************************
# * Copyright © 2024. Cloud Software Group, Inc. All Rights Reserved.
# * This file is subject to the license terms contained
# * in the license file that is distributed with this file.
# *************************************************************************/

param(
    [string] $ConnectionName,
    [string] $UserName,
    [string] $AdminAddress = $null
)

# Enable Citrix PowerShell Cmdlets
Add-PSSnapin citrix*

#########################################################
# Step 1: Update the Password of the Hosting Connection #
#########################################################
Write-Output "Step 1: Update the Password of the Hosting Connection."

# Configure the Literal Path of the connection
$literalPath = @("XDHyp:\Connections\" + $ConnectionName)

# Build the secure password
$SecurePasswordInput = Read-Host $"Please enter the password of $UserName to connect to the hypervisor" -AsSecureString
$EncryptedPasswordInput = $SecurePasswordInput | ConvertFrom-SecureString
$SecurePassword = ConvertTo-SecureString -String $EncryptedPasswordInput

# Configure the common parameters for Set-Item.
$setItemParameters = @{
    LiteralPath = $literalPath
    PassThru = $true
    SecurePassword = $SecurePassword
    UserName = $UserName
}

# If operating in an On-Prem environment, configure the AdminAddress.
if ($AdminAddress) { $setItemParameters['AdminAddress'] = $adminAddress }

# Create an item for the new hosting connection
try { & New-Item @setItemParameters }
catch { exit }
