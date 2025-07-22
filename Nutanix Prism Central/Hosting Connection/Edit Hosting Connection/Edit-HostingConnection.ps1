<#
.SYNOPSIS
    Make changes to the properties of an existing Hosting Connection.
.DESCRIPTION
    This powershell script can edit the Name, Username, Password and/or Maintenance mode status
    of an existing Hosting Connection.
    The original version of this script is compatible with  Citrix DaaS July 2025 Release.
.EXAMPLE
    .\Edit-HostingConnection.ps1 `
        -ConnectionName "myDemoConnection" `
        -NewUserName "newDemoUser" `
        -NewName "myDemoConnectionV2" `
        -NewSslThumbprint "<ssl-thumbprint>"
        -NewPassword
.INPUTS
    1. ConnectionName:    Name of hosting connection to make changes to
    2. NewUserName:       New username for account on the hypervisor
    3. NewName:           New name to be assigned to the hosting connection
    4. NewSslThumbprint:  New SSL Thumbprint to set in the hosting connection
    5. NewPassword:       Parameter that indicates password change for the hosting connection, will prompt for password
#>

# /*************************************************************************
# * Copyright © 2025. Cloud Software Group, Inc.
# * This file is subject to the license terms contained
# * in the license file that is distributed with this file.
# *************************************************************************/

param(
    [Parameter(mandatory=$true)]  [string] $ConnectionName,
    [Parameter(mandatory=$false)] [string] $NewUserName,
    [Parameter(mandatory=$false)] [string] $NewName,
    [Parameter(mandatory=$false)] [string] $NewSslThumbprint,
    [Parameter(mandatory=$false)] [switch] $NewPassword
)

# Enable Citrix PowerShell Cmdlets
Add-PSSnapin -Name "Citrix.Host.Admin.V2","Citrix.MachineCreation.Admin.V2"

$connectionPath = "XDHyp:\Connections\" + $ConnectionName

$requireCred = $false

$cmdParameters = @{}

if ($PSBoundParameters.ContainsKey("NewSslThumbprint"))
{
    $cmdParameters['SslThumbprint'] = $NewSslThumbprint
    $requireCred = $true
}

if ($PSBoundParameters.ContainsKey("NewUserName"))
{
    $cmdParameters['UserName'] = $NewUserName
    $requireCred = $false
    $NewPassword = $true
}
elseif ($NewPassword)
{
    $requireCred = $true
}

if ($requireCred)
{
    $cred = Get-Credential -Message "Credentials for Hosting Connection"
    $NewPassword = $false
    $cmdParameters['UserName'] = $cred.username
    $cmdParameters['SecurePassword'] = $cred.password
}

if ($NewPassword)
{
    $SecureUserInput = Read-Host "Enter the password for the user $($NewUserName)" -AsSecureString
    $EncryptedUserInput = $SecureUserInput | ConvertFrom-SecureString
    $SecurePass = ConvertTo-SecureString -String $EncryptedUserInput
    $cmdParameters['SecurePassword'] = $securePass
}

if($cmdParameters.Keys.Count -gt 0)
{
    # Make changes for any provided parameters except NewName
    Write-Verbose "Edit-HostingConnection: Making changes to Host Connection object"
    try
    {
        & Set-Item -LiteralPath $connectionPath @cmdParameters -ErrorAction Stop
    }
    catch
    {
        Write-Error $_
        exit
    }
}

# Lastly, update name if required
if($PSBoundParameters.ContainsKey('NewName'))
{
    Write-Verbose "Edit-HostingConnection: Changing name"
    try
    {
        Rename-Item -NewName $NewName -Path $connectionPath -ErrorAction Stop
    }
    catch
    {
        Write-Error $_
        exit
    }
}

