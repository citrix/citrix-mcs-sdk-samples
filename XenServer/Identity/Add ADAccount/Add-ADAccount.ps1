<#
.SYNOPSIS
    Addition of AD computer accounts.
.DESCRIPTION
    The `Add-ADAccount.ps1` script facilitates the addition of AD computer accounts.
    The original version of this script is compatible with Citrix Virtual Apps and Desktops 7 2203 Long Term Service Release (LTSR).
.INPUTS
    1. IdentityPoolName: The name of the identity pool to add AD computer accounts.
    2. Count: The number of accounts to be added.
    3. AdminAddress: The primary DDC address.
.OUTPUTS
    New AD Accounts.
.NOTES
    Version      : 1.0.0
    Author       : Citrix Systems, Inc.
.EXAMPLE
    .\Add-ADAccount.ps1 `
        -IdentityPoolName "MyIdentityPool" `
        -Count 2 `
        -AdminAddress "MyDDC.MyDomain.local"
#>

# /*************************************************************************
# * Copyright © 2024. Cloud Software Group, Inc. All Rights Reserved.
# * This file is subject to the license terms contained
# * in the license file that is distributed with this file.
# *************************************************************************/

param(
    [string] $IdentityPoolName,
    [int] $Count,
    [string] $AdminAddress
)

# Enable Citrix PowerShell Cmdlets
Add-PSSnapin citrix*

##########################################################
# Step 1: Add Active Directory (AD) Computer Accounts #
##########################################################
Write-Output "Step 1: Add Active Directory (AD) Computer Accounts."

# Configure the common parameters for New-AcctADAccount.
$newAcctADAccountParameters = @{
    IdentityPoolName  = $IdentityPoolName
    Count = $Count
}

# If operating in an On-Prem environment, configure the AdminAddress.
if ($AdminAddress) { $newAcctADAccountParameters['AdminAddress'] = $AdminAddress }

# Add Active Directory (AD) Computer Accounts
$newAcctADAccountResult = & New-AcctADAccount @newAcctADAccountParameters

# Simple Validation
if ($newAcctADAccountResult.SuccessfulAccountsCount -ne $Count) {
    Write-Output "Failed to Add AD Accounts. Below is the detail. `n $($newAcctADAccountResult.FailedAccounts | ConvertTo-JSON)"
    return
}
