<#
.SYNOPSIS
    Deletion of an identity pool.
.DESCRIPTION
    `Delete-IdentityPool.ps1` is designed to aid in the deletion of an identity pool.
    The original version of this script is compatible with Citrix Virtual Apps and Desktops 7 2203 Long Term Service Release (LTSR).
.INPUTS
    1. IdentityPoolName: Name of the identity pool to be deleted.
    2. AdminAddress: The primary DDC address.
.OUTPUTS
    N/A
.NOTES
    Version      : 1.0.0
    Author       : Citrix Systems, Inc.
.EXAMPLE
    .\Remove-IdentityPool.ps1 `
        -IdentityPoolName "MyIdentityPool" `
        -AdminAddress "MyDDC.MyDomain.local"
#>

# /*************************************************************************
# * Copyright © 2024. Cloud Software Group, Inc. All Rights Reserved.
# * This file is subject to the license terms contained
# * in the license file that is distributed with this file.
# *************************************************************************/

param(
    [string] $IdentityPoolName,
    [string] $AdminAddress = $null
)

# Enable Citrix PowerShell Cmdlets
Add-PSSnapin citrix*

####################################
# Step 1: Remove the Identity Pool #
####################################
Write-Output "Step 1: Remove the Identity Pool."

# Basic validation.
$countAccounts = (Get-AcctADAccount -IdentityPoolName $IdentityPoolName).Count
if ($countAccounts -gt 0) {
    Write-Output "Cannot remove the identity pool: Associated AD accounts exist within it. Please remove the AD accounts."
    exit
}

# Configure the common parameters for Remove-AcctIdentityPool.
$removeAcctIdentityPoolParameters = @{
    IdentityPoolName  = $IdentityPoolName
}

# If operating in an On-Prem environment, configure the AdminAddress.
if ($AdminAddress) { $removeAcctIdentityPoolParameters['AdminAddress'] = $AdminAddress }

# Remove the Identity Pool.
& Remove-AcctIdentityPool @removeAcctIdentityPoolParameters
