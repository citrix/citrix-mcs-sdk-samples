<#
.SYNOPSIS
    Make changes to the properties of an existing Hosting Connection.
.DESCRIPTION
    This powershell script can edit the Name, Username, Password and/or Maintenance mode status
    of an existing Hosting Connection.
    The original version of this script is compatible with Citrix Virtual Apps and Desktops 7 2402 Long Term Service Release (LTSR).
.EXAMPLE
    .\Edit-HostingConnection.ps1 `
        -Name "myDemoConnection"
        -MaintenanceMode $true `
        -NewUserName "newDemoUser" `
        -NewName "myDemoConnectionV2" `
        -NewSecurePassword ConvertTo-SecureString "myNewUpdatedPassword" -AsPlainText -Force
.INPUTS
    1. ConnectionName: Name of hosting connection to make changes to
    2. NewUserName: New username for account on the hypervisor
    3. NewSecurePassword: SecureString containing new password for account on the hypervisor
    4. NewName: New name that is to be assigned to the hosting connection
#>

# /*************************************************************************
# * Copyright © 2024. Cloud Software Group, Inc.
# * This file is subject to the license terms contained
# * in the license file that is distributed with this file.
# *************************************************************************/

param(
    [Parameter(mandatory=$true)]
    [string] $ConnectionName,
    [string] $NewUserName,
    [string] $NewName,
    [securestring] $NewSecurePassword
)

# Enable Citrix PowerShell Cmdlets
Add-PSSnapin -Name "Citrix.Host.Admin.V2","Citrix.MachineCreation.Admin.V2"

$connectionPath = "XDHyp:\Connections\" + $ConnectionName

$cmdParameters = @{}

if($PSBoundParameters.ContainsKey('NewSecurePassword'))
{
    $encryptedUserInput = $NewSecurePassword | ConvertFrom-SecureString
    $securePass = ConvertTo-SecureString -String $encryptedUserInput
    $cmdParameters['SecurePassword'] = $securePass
}

if($PSBoundParameters.ContainsKey("NewUserName"))
{
    $cmdParameters['UserName'] = $NewUserName

    # Need to provide password to validate changes to connection
    if(!$PSBoundParameters.ContainsKey('NewSecurePassword')){
        $SecureUserInput = Read-Host "Enter the password for the user $($UserName)" -AsSecureString
        $EncryptedUserInput = $SecureUserInput | ConvertFrom-SecureString
        $SecurePass = ConvertTo-SecureString -String $EncryptedUserInput
        $cmdParameters['SecurePassword'] = $securePass
    }
}

if($cmdParameters.Keys.Count -gt 0){
    cmdParameters.Add("LiteralPath", $connectionPath)
    # Make changes for any provided parameters except NewName
    Write-Verbose "Edit-HostingConnection: Making changes to Host Connection object"
    try { & Set-Item @cmdParameters -ErrorAction Stop }
    catch { Write-Error $_; exit }
}

# Lastly, update name if required
if($PSBoundParameters.ContainsKey('NewName'))
{
    Write-Verbose "Edit-HostingConnection: Changing name"
    try { Rename-Item -NewName $NewName -Path $connectionPath -ErrorAction Stop }
    catch { Write-Error $_; exit }
}

