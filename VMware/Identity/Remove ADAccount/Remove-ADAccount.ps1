<#
.SYNOPSIS
    Removal of AD computer accounts
.DESCRIPTION
    `Remove-ADAccount.ps1` is designed to aid in the removal of AD computer accounts.
    The original version of this script is compatible with Citrix Virtual Apps and Desktops 7 2203 Long Term Service Release (LTSR).
.INPUTS
    1. IdentityPoolName: Name of the identity pool from which AD computer accounts will be removed.
    2. ADAccountNames: Names of the specific accounts to be removed.
    3. RemoveAllAccounts: A flag to indicate whether all AD accounts within the specified identity pool should be removed.
    4. AdminAddress: The primary DDC address.
.OUTPUTS
    N/A
.NOTES
    Version      : 1.0.0
    Author       : Citrix Systems, Inc.
.EXAMPLE
    # Remove two AD accounts.
    .\Remove-ADAccount.ps1 `
        -IdentityPoolName "MyIdentityPool" `
        -ADAccountNames "MyDomain\MyVM001$","MyDomain\MyVM002$" `
        -AdminAddress "MyDDC.MyDomain.local"

    # Remove all AD accounts.
    .\Remove-ADAccount.ps1 `
        -IdentityPoolName "MyIdentityPool" `
        -RemoveAllAccounts `
        -AdminAddress "MyDDC.MyDomain.local"
#>

# /*************************************************************************
# * Copyright © 2024. Cloud Software Group, Inc. All Rights Reserved.
# * This file is subject to the license terms contained
# * in the license file that is distributed with this file.
# *************************************************************************/

param(
    [string] $IdentityPoolName,
    [string[]] $ADAccountNames,
    [switch] $RemoveAllAccounts = $False,
    [string] $AdminAddress = $null
)

# Enable Citrix PowerShell Cmdlets
Add-PSSnapin citrix*

##########################################################
# Step 1: Remove Active Directory (AD) Computer Accounts #
##########################################################
Write-Output "Step 1: Remove Active Directory (AD) Computer Accounts."

if ($RemoveAllAccounts) {
    # Get all Ad Accounts Names to remove if $RemoveAllAccounts is set to true.
    $ADAccountNames = Get-AcctADAccount -IdentityPoolName $IdentityPoolName | Select-Objet ADAccountName
}

# Configure the common parameters for Remove-AcctADAccount.
$removeAcctADAccountParameters = @{
    IdentityPoolName  = $IdentityPoolName
    ADAccountName = $ADAccountNames
}

# If operating in an On-Prem environment, configure the AdminAddress.
if ($AdminAddress) { $removeAcctADAccountParameters['AdminAddress'] = $AdminAddress }

# Remove Active Directory (AD) Computer Accounts
& Remove-AcctADAccount @removeAcctADAccountParameters
