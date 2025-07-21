<#
.SYNOPSIS
    Delete an existing Hosting Connection.
.DESCRIPTION
    This powershell script deletes an existing Hosting Connection AND removes any Hosting Units under the Connection,
    The original version of this script is compatible with  Citrix DaaS July 2025 Release.
.EXAMPLE
    .\Remove-HostingConnection.ps1 -ConnectionName "myDemoConnection"
.INPUTS
    1. ConnectionName: Name of the hosting connection to be removed
#>

# /*************************************************************************
# * Copyright © 2025. Cloud Software Group, Inc.
# * This file is subject to the license terms contained
# * in the license file that is distributed with this file.
# *************************************************************************/

param(
    [Parameter(mandatory=$true)]  [string] $ConnectionName
)

# Enable Citrix PowerShell Cmdlets
Add-PSSnapin -Name "Citrix.Host.Admin.V2","Citrix.MachineCreation.Admin.V2"

$connectionPath = "XDHyp:\Connections\" + $ConnectionName

Write-Verbose "Remove-HostingConnection: Finding all Hosting Units under this connection"

# Get the Hosting Units under this Hosting Connection
$hostingUnits = Get-ChildItem "XDHyp:\HostingUnits\"  | Where-Object { $_.HypervisorConnection.HypervisorConnectionName -eq $ConnectionName }

# Remove the Hosting Units under the Hosting Connection
if(($hostingUnits | Measure-Object).Count -gt 0)
{
    Write-Verbose "Remove-HostingConnection: Found $(($hostingUnits | Measure-Object).Count) hosting units to delete"
    $hostingUnits.HostingUnitName | ForEach-Object {

        Write-Verbose "Remove-HostingConnection: Deleting Hosting Unit: $($_)"
        try
        {
            Remove-Item -LiteralPath ("XDHyp:\HostingUnits\"+$_) -Force -ErrorAction Stop
        }
        catch
        {
            Write-Error $_
            exit
        }
    }
    Write-Verbose "Remove-HostingConnection: All Hosting Units under connection $($ConnectionName) deleted"
}
else
{
    Write-Verbose "Remove-HostingConnection: No Hosting Units to delete"
}

Write-Verbose "Remove-HostingConnection: Removing the BrokerHypervisorConnection object"
try
{
    & Remove-Item -LiteralPath $connectionPath  -ErrorAction Stop
}
catch [System.Management.Automation.ItemNotFoundException]
{
    Write-Error "Host Connection $($ConnectionName) does not exist"
    exit
}

Write-Verbose "Remove-HostingConnection: Removing the Hosting Connection item"
try
{
    Remove-BrokerHypervisorConnection -Name $ConnectionName  -ErrorAction Stop
}
catch
{
    Write-Error $_
    exit
}