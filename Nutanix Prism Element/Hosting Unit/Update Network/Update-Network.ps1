<#
.SYNOPSIS
    Update the network(s) for an existing Hosting Unit
.DESCRIPTION
    Replace the list of networks for an existing Hosting Unit with an updated list.
    The original version of this script is compatible with Citrix Virtual Apps and Desktops 7 2402 Long Term Service Release (LTSR).
.EXAMPLE
    .\Update-Network.ps1 -Name myHostingUnit -NetworkPath @("XDHyp:\Connections\nutanix\mynetwork.network")
.INPUTS
    1. Name: Name of Hosting Unit to create
    2. NetworkPath: List of updated NetworkPath(s) to assign to the Hosting Unit
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
    [string[]] $NetworkPath
)
# Enable Citrix PowerShell Cmdlets
Add-PSSnapin -Name "Citrix.Host.Admin.V2","Citrix.MachineCreation.Admin.V2"

$hostingUnitPath = "XDHyp:\HostingUnits\$($Name)"

# Get Hosting Unit to edit
Write-Verbose "Edit-HostingUnit: Finding Hosting Unit: $($Name)"
try{
    Get-Item -Path $hostingUnitPath -ErrorAction Stop | Out-Null
}
catch {
    Write-Error "Cannot find Hosting Unit $($Name): $($_)"
}

# Validate that provided network paths exist
Write-Verbose "Edit-HostingUnit: Validating network paths"
$NetworkPath | ForEach-Object {
    try{
        Write-Verbose "Edit-HostingUnit: Finding Network: $($_)"
        Get-Item -Path $_ -ErrorAction Stop | Out-Null
    }
    catch {
        Write-Error "Edit-HostingUnit: Cannot find network: $($_)"
        exit
    }
    Write-Verbose "Edit-HostingUnit: Found Network: $($_)"
}

# Make changes
Write-Verbose "Edit-HostingUnit: Editing Hosting Unit"
try {
    & Set-Item -Path $hostingUnitPath -NetworkPath $NetworkPath -ErrorAction Stop
}
catch {
    Write-Error $_
}

# Get updated Hosting Unit to display
try{
    Get-Item -Path $hostingUnitPath -ErrorAction Stop
}
catch {
    Write-Error "Error fetching updated Hosting Unit: $($Name): $($_)"
}