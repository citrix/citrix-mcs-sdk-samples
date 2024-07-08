<#
.SYNOPSIS
    Edit the HostingConnection.
.DESCRIPTION
    Edit-HostingConnection.ps1 edits the HostingConnection when ConnectionName is provided.
        1. RenameConnection - Renames the hosting connection. If no value is provided, connection is not renamed.
        2. MaintenanceMode can modified by setting to True or False. If no value is provided, script does not update Maintenance Mode
        3. Metadata of the HostingConnection is set when MetadatKey and MetadataValue is provided. If any of these values are blank/null, script does not update any Metadata.
			Example of MetadatKey: Citrix_Broker_MaxAbsoluteNewActionsPerMinute
			Excample of MetadataValue: 2000
        4. CustomProperties are updated on HostingConnection if provided. Here, the script tries to update value of 3 properties (if provided)
			1) ProxyHypervisorTrafficThroughConnector - This custom property enables network traffic (API calls from Citrix Cloud to GCP hypervisor) to be routed through Cloud Connectors in your environment.
			2) UsePrivatePool - To use private worker pool for cloud build service.
			3) AllGcpDiskTypesProperty - The possible values for AllGcpDiskTypesProperty are either True or False. This value controls the Disk Types displayed in Studio while creating a catalog.
            If set to false, it filters out local disk types other than in white list: pd-ssd, pd-standard, pd-balanced. When set to true, it displays all disk types for a given region.
            The default value while creating a hosting connection is false.
        5. $UpdateGcpServiceAccountEmail - If provided, this is used to update the private key and service account for the connection.
    The original version of this script is compatible with Citrix Virtual Apps and Desktops 7 2203 Long Term Service Release (LTSR).
#>

# /*************************************************************************
# * Copyright © 2024. Cloud Software Group, Inc. All Rights Reserved.
# * This file is subject to the license terms contained
# * in the license file that is distributed with this file.
# *************************************************************************/

# [User Input Required]
$ConnectionName = "GcpConnection"
$RenameConnection = "RenameGcpConnection"
$MaintenanceMode = $false
$GcpServiceAccountEmail = "example@project.iam.gserviceaccount.com" # Use client_email field from JSON key for the service account. To create new key go to Gcp console -> Service Account -> Keys -> Add Key -> JSON
$UpdateGcpServiceAccountEmail = ""
$MetadataKey = ""
$MetadataValue = ""
$ProxyHypervisorTrafficThroughConnector = $false
$UsePrivatePool = $false
$AllGcpDiskTypesProperty = $true
$CustomProperties = '<CustomProperties xmlns="http://schemas.citrix.com/2014/xd/machinecreation" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">' `
                    + '<Property xsi:type="StringProperty" Name="UsePrivateWorkerPool" Value="' + $UsePrivatePool + '"/>' `
                    + '<Property xsi:type="StringProperty" Name="ProxyHypervisorTrafficThroughConnector" Value="' + $ProxyHypervisorTrafficThroughConnector + '" />' `
                    + '<Property xsi:type="StringProperty" Name="AllGcpDiskTypesProperty" Value="' + $AllGcpDiskTypesProperty + '" />' `
                    + '</CustomProperties>'

# Enable Citrix PowerShell Cmdlets
Add-PSSnapin -Name "Citrix.Host.Admin.V2","Citrix.MachineCreation.Admin.V2","Citrix.Broker.Admin.V2"

$connectionPath = "XDHyp:\Connections\" + $ConnectionName

$HostingConnection = Get-BrokerHypervisorConnection -Name $ConnectionName
if($null -eq $HostingConnection)
{
    throw "Provided ConnectionName is not valid. Please provide the correct ConnectionName"
}

#########################################
# To update MaintenanceMode #
#########################################

if($null -ne $MaintenanceMode)
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
# To update the CustomProperties #
#########################################

if($CustomProperties -ne "")
{
    # Get private key
    $PrivateKeyUserInput = Read-Host 'Please enter private key' -AsSecureString # Use private_key field from JSON key file
    $EncryptedPrivateKey = ConvertFrom-SecureString -SecureString $PrivateKeyUserInput
    $ServiceAccount_PrivateKey = ConvertTo-SecureString -String $EncryptedPrivateKey

    Set-Item -LiteralPath $connectionPath -CustomProperties $CustomProperties -UserName $GcpServiceAccountEmail -SecurePassword $ServiceAccount_PrivateKey
}

#########################################
# To update the UserName and Password #
#########################################

if($UpdateGcpServiceAccountEmail -ne "")
{
	 # Get private key
    $PrivateKeyUserInput = Read-Host 'Please enter updated private key' -AsSecureString # Use private_key field from JSON key file
    $EncryptedPrivateKey = ConvertFrom-SecureString -SecureString $PrivateKeyUserInput
    $ServiceAccount_PrivateKey = ConvertTo-SecureString -String $EncryptedPrivateKey

    Set-Item -LiteralPath $connectionPath -PassThru -SecurePassword $ServiceAccount_PrivateKey -UserName $UpdateGcpServiceAccountEmail
}

#########################################
# To rename the HostingConnection #
#########################################

if($RenameConnection -ne "")
{
    Rename-Item -NewName $RenameConnection -Path $connectionPath
}