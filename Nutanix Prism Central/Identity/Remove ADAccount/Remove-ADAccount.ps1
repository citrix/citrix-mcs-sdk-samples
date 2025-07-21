<#
.SYNOPSIS
    Remves AD accounts
.DESCRIPTION
    `Remove-ADAccount.ps1` removes AD accounts within an Identity Pool.
    The original version of this script is compatible with Citrix Virtual Apps and Desktops 7 2203 Long Term Service Release (LTSR).
.INPUTS
    1. IdentityPoolName: Name of the identity pool from which AD computer accounts will be removed
    2. ADAccountNames: Names of the specific accounts to be removed
    3. RemoveAllAccounts: A flag to indicate whether all AD accounts within the specified identity pool should be removed
    4. AdminAddress: The primary DDC address
.EXAMPLE
    # Remove specific AD accounts:
    .\Remove-ADAccount.ps1 `
        -IdentityPoolName "myIDP" `
        -ADAccountNames "MyDomain\MyVM1","MyDomain\MyVM2" `

    # Remove all AD accounts:
    .\Remove-ADAccount.ps1 `
        -IdentityPoolName "myIDP" `
        -RemoveAllAccounts `
#>

# /*************************************************************************
# * Copyright © 2025. Cloud Software Group, Inc. All Rights Reserved.
# * This file is subject to the license terms contained
# * in the license file that is distributed with this file.
# *************************************************************************/

param(
    [Parameter(mandatory=$true)] [string] $IdentityPoolName,
    [string[]] $ADAccountNames,
    [switch] $RemoveAllAccounts = $False,
    [string] $AdminAddress = $null
)

# Enable Citrix PowerShell Cmdlets
Add-PSSnapin -Name "Citrix.Host.Admin.V2","Citrix.MachineCreation.Admin.V2"

if ($RemoveAllAccounts) {
    # Get all Ad Accounts Names to remove if $RemoveAllAccounts is set to true.
    $ADAccountNames = Get-AcctADAccount -IdentityPoolName $IdentityPoolName | Select-Object ADAccountName
}

# Configure the common parameters for Remove-AcctADAccount.
$params = @{
    IdentityPoolName  = $IdentityPoolName
    ADAccountName = $ADAccountNames
}

# If operating in an On-Prem environment, configure the AdminAddress.
if ($AdminAddress)
{
    $params['AdminAddress'] = $AdminAddress
}

# Remove Active Directory (AD) Computer Accounts
& Remove-AcctADAccount @params
