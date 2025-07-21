<#
.SYNOPSIS
    Remove an existing ProvScheme.
.DESCRIPTION
    Remove-ProvScheme.ps1 removes an existing Provisioning Scheme.
    The original version of this script is compatible with  Citrix DaaS July 2025 Release.
.INPUTS
    1. ProvisioningSchemeName: Name of the provisioning scheme to remove
.EXAMPLE
    .\Remove-ProvisioningScheme.ps1 -ProvisioningSchemeName "myProvScheme"
#>
# /*************************************************************************
# * Copyright © 2025. Cloud Software Group, Inc.
# * This file is subject to the license terms contained
# * in the license file that is distributed with this file.
# *************************************************************************/

param(
    [Parameter(mandatory=$true)]  [string] $ProvisioningSchemeName,
    [Parameter(mandatory=$false)] [switch] $PurgeDBOnly,
    [Parameter(mandatory=$false)] [switch] $ForgetVM
)

# Enable Citrix PowerShell Cmdlets
Add-PSSnapin -Name "Citrix.Host.Admin.V2","Citrix.MachineCreation.Admin.V2"

Write-Verbose "Remove ProvScheme: $($ProvisioningSchemeName)"

$additionalParameters = @{}
if ($PSBoundParameters.ContainsKey("PurgeDBOnly"))
{
    $additionalParameters.Add("PurgeDBOnly", $null)
}
if ($PSBoundParameters.ContainsKey("ForgetVM"))
{
    $additionalParameters.Add("ForgetVM", $null)
}

try
{
    & Remove-ProvScheme -ProvisioningSchemeName $ProvisioningSchemeName @additionalParameters
}
catch
{
    Write-Error $_
    exit
}
