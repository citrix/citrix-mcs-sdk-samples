<#
.SYNOPSIS
    Create a new AD accounts
.DESCRIPTION
    The Create-ADAccount.ps1 script creates an AD computer accounts.
    The original version of this script is compatible with Citrix Virtual Apps and Desktops 7 2402 Long Term Service Release (LTSR).
.INPUTS
    1. IdentityPoolName: The name of the identity pool to add AD computer accounts.
    2. Count: The number of accounts to be added.
    3. AdminAddress: The primary DDC address.
.OUTPUTS
    New AD Accounts
.EXAMPLE
    .\Create-ADAccount.ps1 `
        -IdentityPoolName "MyIdentityPool" `
        -UserName "myUser"
        -Count 1 `
        -AdminAddress "MyDDC.MyDomain.local"
#>
# /*************************************************************************
# * Copyright © 2025. Cloud Software Group, Inc. All Rights Reserved.
# * This file is subject to the license terms contained
# * in the license file that is distributed with this file.
# *************************************************************************/

param(
    [Parameter(mandatory=$true)] [string] $IdentityPoolName,
    [Parameter(mandatory=$true)] [string] $UserName,
    [int] $Count = 1,
    [string] $AdminAddress
)

# Enable Citrix PowerShell Cmdlets
Add-PSSnapin -Name "Citrix.Host.Admin.V2","Citrix.MachineCreation.Admin.V2"

$adUserName = "$Domain\$UserName"

# Build the secure password
$SecurePasswordInput = Read-Host $"Please enter the Active Directory password for the user $UserName" -AsSecureString
$EncryptedPasswordInput = $SecurePasswordInput | ConvertFrom-SecureString
$securedPassword = ConvertTo-SecureString -String $EncryptedPasswordInput

# Configure the common parameters for New-AcctIdentityPool.
$newAcctADAccountParameters = @{
    IdentityPoolName = $IdentityPoolName
    ADUserName      = $adUserName
    ADPassword      = $securedPassword
    Count           = $Count
}

# If operating in an On-Prem environment, configure the AdminAddress.
if ($AdminAddress)
{
    $newAcctADAccountParameters['AdminAddress'] = $AdminAddress
}
& New-AcctADAccount @newAcctADAccountParameters