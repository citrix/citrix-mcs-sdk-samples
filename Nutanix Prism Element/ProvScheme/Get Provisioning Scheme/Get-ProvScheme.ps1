<#
.SYNOPSIS
    Get an existing ProvScheme.
.DESCRIPTION
    Get-ProvScheme.ps1 gets an existing Provisioning Scheme.
    The original version of this script is compatible with Citrix Virtual Apps and Desktops 7 2402 Long Term Service Release (LTSR).
.INPUTS
    1. ProvisioningSchemeName: Name of the provisioning scheme to get
.EXAMPLE
    .\Get-ProvisioningScheme.ps1 -ProvisioningSchemeName "myProvScheme"
#>

# /*************************************************************************
# * Copyright © 2024. Cloud Software Group, Inc.
# * This file is subject to the license terms contained
# * in the license file that is distributed with this file.
# *************************************************************************/

param(
    [Parameter(mandatory=$true)]
    [string] $ProvisioningSchemeName
)
# Enable Citrix PowerShell Cmdlets
Add-PSSnapin -Name "Citrix.Host.Admin.V2","Citrix.MachineCreation.Admin.V2"

Write-Verbose "Get ProvScheme: $($ProvisioningSchemeName)"
# Get Provisoning Scheme
try{
    & Get-ProvScheme -ProvisioningSchemeName $ProvisioningSchemeName -ErrorAction Stop
} catch {
    Write-Error $_
    exit
}
