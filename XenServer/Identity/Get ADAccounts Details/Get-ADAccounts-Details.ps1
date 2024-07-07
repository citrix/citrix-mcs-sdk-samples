<#
.SYNOPSIS
    Returns the detail of AD Accounts within an identity pool.
.DESCRIPTION
    `Get-ADAccounts-Details.ps1` returns the detail of AD Accounts within an identity pool.
    The original version of this script is compatible with Citrix Virtual Apps and Desktops 7 2203 Long Term Service Release (LTSR).
.INPUTS
    1. IdentityPoolName: Name of the identity pool to be retrieved.
.OUTPUTS
    AD Account Objects.
.NOTES
    Version      : 1.0.0
    Author       : Citrix Systems, Inc.
.EXAMPLE
    .\Get-ADAccounts-Details.ps1 `
        -IdentityPoolName "MyIdentityPool"
#>

# /*************************************************************************
# * Copyright © 2024. Cloud Software Group, Inc. All Rights Reserved.
# * This file is subject to the license terms contained
# * in the license file that is distributed with this file.
# *************************************************************************/

param(
    [string] $IdentityPoolName
)

# Enable Citrix PowerShell Cmdlets
Add-PSSnapin citrix*

##############################################
# Step 1: Get the Detail of the AD Accounts. #
##############################################
Write-Output "Step 1: Get the Detail of the Identity Pool."

# Get the Detail of the AD Accounts within the specified Identity Pool.
Get-AcctADAccount -IdentityPoolName $IdentityPoolName
