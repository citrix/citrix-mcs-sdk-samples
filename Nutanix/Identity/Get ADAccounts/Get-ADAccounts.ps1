<#
.SYNOPSIS
    Returns the AD Accounts within an identity pool.
.DESCRIPTION
    `Get-ADAccounts.ps1` returns AD Accounts within an identity pool.
    The original version of this script is compatible with Citrix Virtual Apps and Desktops 7 2402 Long Term Service Release (LTSR).
.INPUTS
    1. IdentityPoolName: Name of the identity pool to be retrieved.
.OUTPUTS
    AD Account Objects.
.EXAMPLE
    .\Get-ADAccounts.ps1 `
        -IdentityPoolName "MyIdentityPool"
#>

# /*************************************************************************
# * Copyright © 2024. Cloud Software Group, Inc. All Rights Reserved.
# * This file is subject to the license terms contained
# * in the license file that is distributed with this file.
# *************************************************************************/

param(
    [Parameter(mandatory=$true)]
    [string] $IdentityPoolName
)

# Enable Citrix PowerShell Cmdlets
Add-PSSnapin -Name "Citrix.Host.Admin.V2","Citrix.MachineCreation.Admin.V2" 

Get-AcctADAccount -IdentityPoolName $IdentityPoolName
