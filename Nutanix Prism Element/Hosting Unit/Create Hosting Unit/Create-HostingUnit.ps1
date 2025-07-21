<#
.SYNOPSIS
    Create a new Hosting Unit
.DESCRIPTION
    This powershell script creates a new Hosting Unit.
    The RootPath associated with the HostingUnit will be "XDHyp:\Connections\<connection name>\"
    The original version of this script is compatible with Citrix Virtual Apps and Desktops 7 2402 Long Term Service Release (LTSR).
.EXAMPLE
    # Create a Hosting Unit
    .\Create-HostingUnit.ps1 `
        -Name myHostingUnit `
        -ConnectionName "nutanix" `
        -NetworkPath @("XDHyp:\Connections\nutanix\mynetwork.network") `
        -PersonalvDiskStoragePath @() `

    .\Create-HostingUnit.ps1 `
        -Name myHostingUnit `
        -ConnectionName "nutanix" `
        -NetworkPath @("XDHyp:\Connections\nutanix\mynetwork.network","XDHyp:\Connections\nutanix\mynetwork2.network") `
        -PersonalvDiskStoragePath @() `
.INPUTS
    1. Name: Name of Hosting Unit to create
    2. ConnectionName: Name of the Hypervisor connection
    3. NetworkPath: Path(s) to networks to use
    4. PersonalvDiskStoragePath: Path(s) to PersonalvDiskStorage to use
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
    [string] $ConnectionName,
    [string[]] $NetworkPath,
    [string[]] $PersonalvDiskStoragePath = @()
)
# Enable Citrix PowerShell Cmdlets
Add-PSSnapin -Name "Citrix.Host.Admin.V2","Citrix.MachineCreation.Admin.V2"

# Validate that provided Network paths exist
if($PSBoundParameters.ContainsKey("NetworkPath")){
    Write-Verbose "Create-HostingUnit: Validating network paths"
    $NetworkPath | ForEach-Object {
        try{
            Write-Verbose "Create-HostingUnit: Finding Network: $($_)"
            Get-Item -Path $_ -ErrorAction Stop | Out-Null
        }
        catch {
            Write-Error "Create-HostingUnit: Cannot find network: $($_)"
            exit
        }
        Write-Verbose "Create-HostingUnit: Found Network: $($_)"
    }
}

$params = @{
    "Path"= "XDHyp:\HostingUnits\" + $Name;
    "HypervisorConnectionName" = $ConnectionName;
    "NetworkPath" = $NetworkPath;
    "StoragePath" = @();
    "PersonalvDiskStoragePath" = $PersonalvDiskStoragePath;
    "RootPath" = "XDHyp:\Connections\$($ConnectionName)\"
}

# Create Hosting Unit
Write-Verbose "Create-HostingUnit: Creating Hosting Unit"
try {
    & New-Item @params -ErrorAction Stop
}
catch {
    Write-Error $_
}
