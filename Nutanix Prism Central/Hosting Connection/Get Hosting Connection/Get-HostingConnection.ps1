<#
.SYNOPSIS
    Retrieves an existing Hosting Connection.
.DESCRIPTION
    This powershell script retrieves an existing Hosting Connection.
    The original version of this script is compatible with  Citrix DaaS July 2025 Release.
.EXAMPLE
    .\Get-HostingConnection.ps1 -ConnectionName "myDemoConnection"
.INPUTS
    1. ConnectionName: Name of hosting connection to retrieve
#>

# /*************************************************************************
# * Copyright © 2025. Cloud Software Group, Inc.
# * This file is subject to the license terms contained
# * in the license file that is distributed with this file.
# *************************************************************************/

param(
    [Parameter(mandatory=$true)] [string] $ConnectionName
)

# Enable Citrix PowerShell Cmdlets
Add-PSSnapin -Name "Citrix.Host.Admin.V2","Citrix.MachineCreation.Admin.V2"

$connectionPath = "XDHyp:\Connections\" + $ConnectionName

try
{
    Write-Output "Retrieving Connection item"
    Get-Item -Path $connectionPath -ErrorAction Stop

    Write-Output "Retrieving BrokerHypervisorConnection item"
    Get-BrokerHypervisorConnection -Name $ConnectionName -ErrorAction Stop
}
catch
{
    Write-Error "Host Connection with name $($ConnectionName) not found"
    exit
}