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
        -Count 1 `
        -AdminAddress "MyDDC.MyDomain.local"
#>

# /*************************************************************************
# * Copyright © 2024. Cloud Software Group, Inc. All Rights Reserved.
# * This file is subject to the license terms contained
# * in the license file that is distributed with this file.
# *************************************************************************/

param(
    [Parameter(mandatory=$true)]
    [string] $IdentityPoolName,
    [int] $Count = 1,
    [string] $AdminAddress
)

# Enable Citrix PowerShell Cmdlets
Add-PSSnapin -Name "Citrix.Host.Admin.V2","Citrix.MachineCreation.Admin.V2" 

$params = @{
    IdentityPoolName  = $IdentityPoolName
    Count = $Count
}

# Add AD Accounts
& New-AcctADAccount @params
