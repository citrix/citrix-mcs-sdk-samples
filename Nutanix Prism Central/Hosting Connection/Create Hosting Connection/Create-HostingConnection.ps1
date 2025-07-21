<#
.SYNOPSIS
    Create a new Hosting Connection
.DESCRIPTION
    This powershell script creates a new Hosting Connection.
    NOTE: It does not create a Hosting Unit and it's associated resources, refer to the Create-HostingUnit.ps1 script
    The original version of this script is compatible with  Citrix DaaS July 2025 Release.
.EXAMPLE
    $securePassword = Read-Host "Enter the password" -AsSecureString
    .\Create-HostingConnection.ps1 `
        -ConnectionName "myDemoConnection" `
        -HypervisorAddress "1.2.3.4" `
        -UserName "myUserName" `
        -ZoneUid "11111111-2222-3333-4444-555555555555" `
        -SllThumbprint 111122223333444455556667778889990000AAAA
.INPUTS
    1. ConnectionName: Name of the connection
    2. HypervisorAddress: The IP address of the hypervisor
    3. UserName: Username of the account on hypervisor
    4. ZoneUid: UID of the zone where the hosting connection will be created
    5. SslThumbprint:  OPTIONAL SSL Thumbprint of Prims Central Server
    6. Scope:  OPTIONAL Administration scopes for connection
#>

# /*************************************************************************
# * Copyright © 2025. Cloud Software Group, Inc.
# * This file is subject to the license terms contained
# * in the license file that is distributed with this file.
# *************************************************************************/

param(
    [Parameter(mandatory=$true)]  [string]   $ConnectionName,
    [Parameter(mandatory=$true)]  [string]   $HypervisorAddress,
    [Parameter(mandatory=$true)]  [string]   $UserName,
    [Parameter(mandatory=$true)]  [guid]     $ZoneUid,
    [Parameter(mandatory=$false)] [string]   $SslThumbprint=$null,
    [Parameter(mandatory=$false)] [string[]] $Scope = @()
)

# Enable Citrix PowerShell Cmdlets
Add-PSSnapin -Name "Citrix.Host.Admin.V2","Citrix.MachineCreation.Admin.V2"


$connectionPath = "XDHyp:\Connections\" + $ConnectionName

$SecureUserInput    = Read-Host "Enter the password for the user $($UserName)" -AsSecureString
$EncryptedUserInput = $SecureUserInput | ConvertFrom-SecureString
$SecurePass         = ConvertTo-SecureString -String $EncryptedUserInput

# Create an item for the new hosting connection

try
{
    Write-Output "Create-HostingConnection: Creating a Hosting Connection. Path: $($connectionPath)"

    $params = @{}
    if(-not [string]::IsNullOrEmpty($SslThumbprint))
    {
        Write-Output "Adding SSL thumbprint $($SslThumbprint)"
        $params.Add("SslThumbprint", $SslThumbprint)
    }

    $connection = New-Item -Path $connectionPath `
        -ConnectionType "Custom" `
        -PluginId "AcropolisHypervisorPCFactory" `
        -HypervisorAddress @($hypervisorAddress) `
        -Persist `
        -UserName $UserName `
        -SecurePassword $SecurePass `
        -ZoneUid $ZoneUid `
        -Scope $Scope `
        @params `
        -ErrorVariable errorVariable `
        -ErrorAction SilentlyContinue
}
catch
{
    if($errorVariable -AND -not [string]::IsNullOrEmpty($errorVariable[0].ErrorData.Thumbprint))
    {
        $sslThumbprint = $errorVariable[0].ErrorData.Thumbprint
        Write-Output  ""
        Write-Output  "Create Connection Failed with SSL trust error."
        Write-Output  ""
        Write-Output  "Re-run the script with providing the optional parameter -SslThumbprint $($sslThumbprint)"
        Write-Output  ""
    }
    else
    {
        Write-Output  ""
        Write-Output  "Create Connection Failed: $($_.Exception.Message)"
        Write-Output  ""
    }
    exit
}

# Create a broker hypervisor connection
try
{
    New-BrokerHypervisorConnection -HypHypervisorConnectionUid $connection.HypervisorConnectionUid
}
catch
{
    Write-Error $_
    exit
}
