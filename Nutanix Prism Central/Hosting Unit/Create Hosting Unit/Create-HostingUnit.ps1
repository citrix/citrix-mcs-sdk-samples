<#
.SYNOPSIS
    Create a new Hosting Unit
.DESCRIPTION
    This powershell script creates a new Hosting Unit.
    The RootPath associated with the HostingUnit will be "XDHyp:\Connections\<connection name>\"
    The original version of this script is compatible with  Citrix DaaS July 2025 Release.
.EXAMPLE
    # Create a Hosting Unit
    .\Create-HostingUnit.ps1 `
        -Name myHostingUnit `
        -ConnectionName "nutanix"
.INPUTS
    1. Name:           Name of Hosting Unit to create
    2. ConnectionName: Name of the Hypervisor connection
#>

# /*************************************************************************
# * Copyright © 2025. Cloud Software Group, Inc.
# * This file is subject to the license terms contained
# * in the license file that is distributed with this file.
# *************************************************************************/

param(
    [Parameter(mandatory=$true)] [string] $Name,
    [Parameter(mandatory=$true)] [string] $ConnectionName
)

# Enable Citrix PowerShell Cmdlets
Add-PSSnapin -Name "Citrix.Host.Admin.V2","Citrix.MachineCreation.Admin.V2"

$connectionPath = "XDHyp:\Connections\" + $ConnectionName
$hostUnitPath   = "XDHyp:\HostingUnits\" + $Name

# Create Hosting Unit

Write-Verbose "Create-HostingUnit: Creating Hosting Unit $($Name) for Hosting Connection $($ConnectionName)"

try {
    New-Item -HypervisorConnectionName $ConnectionName `
        -Path $hostUnitPath `
        -RootPath $connectionPath `
        -NetworkPath @() `
        -StoragePath @() `
        -ErrorAction Stop
}
catch
{
    Write-Error $_
}
