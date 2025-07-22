<#
.SYNOPSIS
    Rename a Hosting Unit
.DESCRIPTION
    Rename a Hosting Unit
    NOTE: It does not create a Hosting Unit and it's associated resources, refer to the Create-HostingUnit.ps1 script.
    The original version of this script is compatible with Citrix Virtual Apps and Desktops 7 2402 Long Term Service Release (LTSR).
.EXAMPLE
    .\Rename-HostingUnit.ps1 -Name myHostingUnit -NewName
.INPUTS
    1. Name: Name of Hosting Unit to create
    2. NewName: New name for the Hosting Unit
#>

# /*************************************************************************
# * Copyright © 2024. Cloud Software Group, Inc.
# * This file is subject to the license terms contained
# * in the license file that is distributed with this file.
# *************************************************************************/

param(
    [Parameter(mandatory=$true)]
    [string] $Name,
    [Parameter(mandatory=$true)]
    [string] $NewName
)

# Enable Citrix PowerShell Cmdlets
Add-PSSnapin -Name "Citrix.Host.Admin.V2","Citrix.MachineCreation.Admin.V2"

$hostingUnitPath = "XDHyp:\HostingUnits\$($Name)"

# Get Hosting Unit to edit
Write-Verbose "Rename-HostingUnit: Finding Hosting Unit: $($Name)"
try{
    Get-Item -Path $hostingUnitPath -ErrorAction Stop | Out-Null
}
catch {
    Write-Error "Cannot find Hosting Unit $($Name): $($_)"
}

# Make Changes
try{
    Rename-Item -Path $hostingUnitPath -NewName $NewName
}
catch {
    Write-Error $_
}
$hostingUnitPath = "XDHyp:\HostingUnits\$($NewName)"
$Name = $NewName

# Get updated Hosting Unit to display
try{
    Get-Item -Path $hostingUnitPath -ErrorAction Stop
}
catch {
    Write-Error "Error fetching updated Hosting Unit: $($Name): $($_)"
}