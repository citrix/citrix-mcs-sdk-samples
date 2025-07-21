<#
.SYNOPSIS
    Get an existing Hosting Unit.
.DESCRIPTION
    This powershell script Gets an existing Hosting Unit.
    The original version of this script is compatible with Citrix Virtual Apps and Desktops 7 2402 Long Term Service Release (LTSR).
.EXAMPLE
    .\Get-HostingUnit.ps1 -Name myHostingUnit
.INPUTS
    1. Name: Name of Hosting Unit to get
#>

# /*************************************************************************
# * Copyright © 2024. Cloud Software Group, Inc.
# * This file is subject to the license terms contained
# * in the license file that is distributed with this file.
# *************************************************************************/

param(
    [Parameter(mandatory=$true)]
    [string] $Name
)
# Enable Citrix PowerShell Cmdlets
Add-PSSnapin -Name "Citrix.Host.Admin.V2","Citrix.MachineCreation.Admin.V2"

$hostingUnitPath = "XDHyp:\HostingUnits\$($Name)"

# Get Hosting Unit to display
Write-Verbose "Get-HostingUnit: Finding Hosting Unit: $($Name)"
try{
    Get-Item -Path $hostingUnitPath -ErrorAction Stop
}
catch {
    Write-Error "Cannot find Hosting Unit $($Name): $($_)"
}