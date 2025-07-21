<#
.SYNOPSIS
    Get an existing Hosting Unit.
.DESCRIPTION
    This powershell script Gets an existing Hosting Unit.
    The original version of this script is compatible with  Citrix DaaS July 2025 Release.
.EXAMPLE
    .\Get-HostingUnit.ps1 -Name myHostingUnit
.INPUTS
    1. Name: Name of Hosting Unit to get
#>

# /*************************************************************************
# * Copyright © 2025. Cloud Software Group, Inc.
# * This file is subject to the license terms contained
# * in the license file that is distributed with this file.
# *************************************************************************/

param(
    [Parameter(mandatory=$true)] [string] $Name
)
# Enable Citrix PowerShell Cmdlets
Add-PSSnapin -Name "Citrix.Host.Admin.V2","Citrix.MachineCreation.Admin.V2"

# Get Hosting Unit to display
Write-Verbose "Get-HostingUnit: Finding Hosting Unit: $($Name)"
try
{
    Get-Item -Path "XDHyp:\HostingUnits\$($Name)" -ErrorAction Stop
}
catch
{
    Write-Error "Cannot find Hosting Unit $($Name): $($_)"
}