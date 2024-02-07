<#
.SYNOPSIS
    Edit the HostingConnection.
.DESCRIPTION
    Edit-HostingConnection.ps1 edits the HostingConnection when HostingConnectionName is provided.
        1. RenameSCVMMConnection rename the HostingConnection when RenameSCVMMConnection is provided.
        2. MaintenanceMode is set either True or False when MaintenanceMode is provided.
        3. Metadata of the HostingConnection is set when MetadatKey and MetadataValue is provided.
        4. Password is updated on HostingConnection when UpdatePassword is true.
    The original version of this script is compatible with Citrix Virtual Apps and Desktops 7 2203 Long Term Service Release (LTSR).
#>

# /*************************************************************************
# * Copyright © 2024. Cloud Software Group, Inc.
# * This file is subject to the license terms contained
# * in the license file that is distributed with this file.
# *************************************************************************/

# [User Input Required]
$ConnectionName = "SCVMMConnection"
$UserName = "UserName" #Example: domain-name\user-name
$UpdatePassword = $true
$RenameConnection = "RenameSCVMMConnection"
$MaintenanceMode = $true
$MetadataKey = "MetadatKey"
$MetadataValue = "MetadataValue"

# Enable Citrix PowerShell Cmdlets
Add-PSSnapin -Name "Citrix.Host.Admin.V2","Citrix.MachineCreation.Admin.V2"

$connectionPath = "XDHyp:\Connections\" + $ConnectionName

$HostingConnection = Get-BrokerHypervisorConnection -Name $ConnectionName
if($null -eq $HostingConnection)
{
    throw "Provided ConnectionName is not valid. Please give the right ConnectionName"
}

#########################################
# To modify MaintenanceMode #
#########################################

if($MaintenanceMode -ne $null)
{
    Set-Item -LiteralPath $connectionPath -MaintenanceMode $MaintenanceMode
}

#########################################
# To update the Metadata #
#########################################

if(($MetadataKey -ne "") -and ($MetadataValue -ne ""))
{
    Set-HypHypervisorConnectionMetadata -HypervisorConnectionName $ConnectionName -Name $MetadataKey -Value $MetadataValue
}

#########################################
# To update the UserName and Password #
#########################################

if($UpdatePassword )
{
    $secureUserInput = Read-Host 'Please enter your domain password' -AsSecureString
	$encryptedInput = ConvertFrom-SecureString -SecureString $secureUserInput
	$SecureApplicationPassword = ConvertTo-SecureString -String $encryptedInput
    Set-Item -LiteralPath $connectionPath -PassThru -Password $SecureApplicationPassword -UserName $UserName
}

#########################################
# To rename the HostingConnection #
#########################################

if($RenameConnection -ne "")
{
    Rename-Item -NewName $RenameConnection -Path $connectionPath
}