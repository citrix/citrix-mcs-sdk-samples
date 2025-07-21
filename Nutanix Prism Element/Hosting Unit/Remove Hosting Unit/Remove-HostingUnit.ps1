<#
.SYNOPSIS
    Remove an existing Hosting Unit.
.DESCRIPTION
    This powershell script removes a Hosting Unit.
    The original version of this script is compatible with Citrix Virtual Apps and Desktops 7 2402 Long Term Service Release (LTSR).
.EXAMPLE
    .\Remove-HostingUnit.ps1 -Name myHostingUnit
.INPUTS
    1. Name: Name of Hosting Unit to delete
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

# Find Hosting Unit to remove
Write-Verbose "Remove-HostingUnit: Finding Hosting Unit: $($Name)"
try{
    Get-Item -Path $hostingUnitPath -Verbose:$false -ErrorAction Stop | Out-Null
}
catch {
    Write-Error "Cannot find Hosting Unit $($Name): $($_)"
}
Write-Verbose "Remove-HostingUnit: Found Hosting Unit to remove"

# Remove Hosting Unit
Write-Verbose "Remove-HostingUnit: Removing Hosting Unit"
try {
    & Remove-Item -LiteralPath $hostingUnitPath -ErrorAction Stop -Verbose:$false
}
catch {
    Write-Error $_
}
