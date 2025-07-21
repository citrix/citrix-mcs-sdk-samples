<#
.SYNOPSIS
    Update the Network Mapping for an existing ProvScheme.
.DESCRIPTION
    Remove-ProvScheme.ps1 updates the Network Mapping for an existing Provisioning Scheme.
    The original version of this script is compatible with  Citrix DaaS July 2025 Release.
.INPUTS
    1. ProvisioningSchemeName: Name of the provisioning scheme to update
    2. NetworkMapping: Updated NetworkMapping
.EXAMPLE
    .\Update-NetworkMapping.ps1 -ProvisioningSchemeName "myProvScheme" -NetworkMapping @{"0"="XDHyp:\HostingUnits\myHostingUnit\Clusters.folder\cluster01.cluster\Network-A.network"}
#>
# /*************************************************************************
# * Copyright © 2025. Cloud Software Group, Inc.
# * This file is subject to the license terms contained
# * in the license file that is distributed with this file.
# *************************************************************************/

param(
    [Parameter(mandatory=$true)]
    [string] $ProvisioningSchemeName,
    [Parameter(mandatory=$true)]
    [hashtable] $NetworkMapping
)
# Enable Citrix PowerShell Cmdlets
Add-PSSnapin -Name "Citrix.Host.Admin.V2","Citrix.MachineCreation.Admin.V2"

Write-Verbose "Remove ProvScheme: $($ProvisioningSchemeName)"
# Get Provisoning Scheme
try{
    & Set-ProvScheme -ProvisioningSchemeName $ProvisioningSchemeName -NetworkMapping $NetworkMapping -ErrorAction Stop
} catch {
    Write-Error $_
    exit
}