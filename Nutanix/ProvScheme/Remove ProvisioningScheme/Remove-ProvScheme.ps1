<#
.SYNOPSIS
    Remove an existing ProvScheme.
.DESCRIPTION
    Remove-ProvScheme.ps1 removes an existing Provisioning Scheme.
    The original version of this script is compatible with Citrix Virtual Apps and Desktops 7 2402 Long Term Service Release (LTSR).
.INPUTS
    1. ProvisioningSchemeName: Name of the provisioning scheme to remove
.EXAMPLE
    .\Remove-ProvisioningScheme.ps1 -ProvisioningSchemeName "myProvScheme"
#>

# /*************************************************************************
# * Copyright © 2024. Cloud Software Group, Inc.
# * This file is subject to the license terms contained
# * in the license file that is distributed with this file.
# *************************************************************************/

param(
    [Parameter(mandatory=$true)]
    [string] $ProvisioningSchemeName,
    [switch] $PurgeDBOnly=$false,
    [switch] $ForgetVM=$false
)
# Enable Citrix PowerShell Cmdlets
Add-PSSnapin -Name "Citrix.Host.Admin.V2","Citrix.MachineCreation.Admin.V2" 

Write-Verbose "Remove ProvScheme: $($ProvisioningSchemeName)"
# Get Provisoning Scheme
try{
    & Remove-ProvScheme -ProvisioningSchemeName $ProvisioningSchemeName -PurgeDBOnly $PurgeDBOnly -ForgetVM $ForgetVM -ErrorAction stop
} catch {
    Write-Error $_
    exit
}
