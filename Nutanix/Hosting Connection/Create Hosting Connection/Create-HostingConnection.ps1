<#
.SYNOPSIS
    Create a new Hosting Connection
.DESCRIPTION
    This powershell script creates a new Hosting Connection.
    NOTE: It does not create a Hosting Unit and it's associated resources, refer to the Create-HostingUnit.ps1 script
    The original version of this script is compatible with Citrix Virtual Apps and Desktops 7 2402 Long Term Service Release (LTSR).
.EXAMPLE
    .\Create-HostingConnection.ps1 `
        -ConnectionName "myDemoConnection" `
        -HypervisorAddress "https://myhypervisor.com" `
        -SecurePass Read-Host "Enter the password" -AsSecureString `
        -UserName "myUserName" `
        -ZoneUid "00000000-0000-0000-0000-000000000000"
.INPUTS
    1. ConnectionName: Name of the connection
    2. UserName: Username of the account on hypervisor
    3. ZoneUid: UID of the zone where the hosting connection will be created
    4. ConnectionType: Type of the hosting connection ("Custom" by default for Nutanix)
    5. HypervisorAddress: The IP address of the hypervisor
    6. Persist: Boolean value that sets if the connection is persistent
    7. Scope: Administration scopes for connection
#>

# /*************************************************************************
# * Copyright © 2024. Cloud Software Group, Inc.
# * This file is subject to the license terms contained
# * in the license file that is distributed with this file.
# *************************************************************************/

param(
    [Parameter(mandatory=$true)]
    [string] $ConnectionName,
    [Parameter(mandatory=$true)]
    [string] $UserName,
    [Parameter(mandatory=$true)]
    [guid] $ZoneUid,
    [string] $ConnectionType = "Custom",
    [Parameter(mandatory=$true)]
    [string] $HypervisorAddress = $null,
    [bool] $Persist = $true,
    [string[]] $Scope = @()
)

# Enable Citrix PowerShell Cmdlets
Add-PSSnapin -Name "Citrix.Host.Admin.V2","Citrix.MachineCreation.Admin.V2"

Write-Verbose "Create-HostingConnection: Creating a Hosting Connection."

$connectionPath = "XDHyp:\Connections\" + $ConnectionName

$SecureUserInput = Read-Host "Enter the password for the user $($UserName)" -AsSecureString
$EncryptedUserInput = $SecureUserInput | ConvertFrom-SecureString
$SecurePass = ConvertTo-SecureString -String $EncryptedUserInput

$params = @{
    "ConnectionType"= $ConnectionType;
    "Path"= $connectionPath;
    "Persist" = $Persist;
    "Scope"= $Scope;
    "HypervisorAddress"= $hypervisorAddress;
    "PluginId"= "AcropolisFactory";
    "SecurePassword"= $SecurePass;
    "UserName"= $UserName;
    "ZoneUid"= $ZoneUid;
}

# Create an item for the new hosting connection
try {
    $connection = New-Item @params
}
catch {
    Write-Error $_
    exit
}

# Create a broker hypervisor connection
try { New-BrokerHypervisorConnection -HypHypervisorConnectionUid $connection.HypervisorConnectionUid }
catch {
    Write-Error $_
    exit
}