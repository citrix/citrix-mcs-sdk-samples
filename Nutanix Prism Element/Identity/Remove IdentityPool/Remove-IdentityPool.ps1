<#
.SYNOPSIS
    Delete an identity pool.
.DESCRIPTION
    Remove-IdentityPool.ps1 removes an identity pool.
    The original version of this script is compatible with Citrix Virtual Apps and Desktops 7 2402 Long Term Service Release (LTSR).
.INPUTS
    1. IdentityPoolName: Name of the identity pool to be deleted
    2. AdminAddress: The primary DDC address
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
    [Parameter(mandatory=$true)]
    [string] $IdentityPoolName,
    [string] $AdminAddress = $null
)

# Enable Citrix PowerShell Cmdlets
Add-PSSnapin -Name "Citrix.Host.Admin.V2","Citrix.MachineCreation.Admin.V2"

# Configure the common parameters for Remove-AcctIdentityPool.
$removeAcctIdentityPoolParameters = @{
    IdentityPoolName  = $IdentityPoolName
}
if ($AdminAddress) { $removeAcctIdentityPoolParameters['AdminAddress'] = $AdminAddress }

& Remove-AcctIdentityPool @removeAcctIdentityPoolParameters
