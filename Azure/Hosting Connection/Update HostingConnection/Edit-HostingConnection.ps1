<#
.SYNOPSIS
    Edit the HostingConnection.
.DESCRIPTION
    Edit-HostingConnection.ps1 edits the HostingConnection when HostingConnectionName is provided.
        1. RenameAzureConnection rename the HostingConnection when RenameAzureConnection is provided.
        2. MaintenanceMode is set either True or False when MaintenanceMode is provided.
        3. Metadata of the HostingConnection is set when MetadatKey and MetadataValue is provided.
        4. CustomProperties are updated on HostingConnection when the CustomProperties are provided. Here ProxyHypervisorTrafficThroughConnector custom property is added.
        This custom property enables network traffic (API calls from Citrix Cloud to Azure hypervisor) to be routed through Cloud Connectors in your environment.
        5. Password is updated on HostingConnection when UpdatePassword is true.
        6. Hosting Connection is updated to include user/system assigned identity when updateAuthMode is set to True and AuthenticationMode is provided. This feature is cloud only and not available for on-prem at this point.
    The original version of this script is compatible with Citrix Virtual Apps and Desktops 7 2203 Long Term Service Release (LTSR).
#>

# /*************************************************************************
# * Copyright © 2024. Cloud Software Group, Inc. All Rights Reserved.
# * This file is subject to the license terms contained
# * in the license file that is distributed with this file.
# *************************************************************************/

# [User Input Required]
$ConnectionName = "AzureConnection"
$updateAuthMode = $true                                     # True if you want to update existing hypervisor to Azure Managed Identity, else False
$AuthenticationMode = "SystemAssignedManagedIdentity"       # Can be SystemAssignedManagedIdentity or UserAssignedManagedIdentity
$UserName = "AppId"                                         # Azure Application ID. ManagedIdentities Client ID if updateAuthMode is True and AuthenticationMode is UserAssignedManagedIdentity
$SubscriptionId = "SubscriptionId"                          # Azure subscription ID
$TenantId ="TenantId"                                       # Azure AD Directory ID
$UpdatePassword = $true
$RenameConnection = "RenameAzureConnection"
$MaintenanceMode = $true
$MetadataKey = "MetadatKey"
$MetadataValue = "MetadataValue"
$CustomProperties = '<CustomProperties xmlns="http://schemas.citrix.com/2014/xd/machinecreation" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">' `
+ '<Property xsi:type="StringProperty" Name="SubscriptionId" Value="' + $SubscriptionId + '" />'`
+ '<Property xsi:type="StringProperty" Name="ManagementEndpoint" Value="https://management.azure.com/" />'`
+ '<Property xsi:type="StringProperty" Name="AuthenticationAuthority" Value="https://login.microsoftonline.com/" />'`
+ '<Property xsi:type="StringProperty" Name="StorageSuffix" Value="core.windows.net" />'`
+ '<Property xsi:type="StringProperty" Name="TenantId" Value="' + $TenantId + '" />'`
+ '<Property xsi:type="StringProperty" Name="ProxyHypervisorTrafficThroughConnector" Value="True" />'`
+ '</CustomProperties>'

# Enable Citrix PowerShell Cmdlets
Add-PSSnapin -Name "Citrix.Host.Admin.V2","Citrix.MachineCreation.Admin.V2","Citrix.Broker.Admin.V2"

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
# To update the CustomProperties #
#########################################

if($CustomProperties -ne '')
{
    $cred = Get-Credential
    Set-Item -LiteralPath $connectionPath -CustomProperties $CustomProperties -UserName $cred.username -Password $cred.password
}

#########################################
# To update the UserName and Password #
#########################################

if($UpdatePassword)
{
    $secureUserInput = Read-Host 'Please enter your application secret' -AsSecureString
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

#####################################################################################
# To update existing hypversisor connection to use a system/user assigned identity #
#####################################################################################

if($updateAuthMode)
{
    $cred = Get-Credential
    $customPropsAuthMode = '<CustomProperties xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns="http://schemas.citrix.com/2014/xd/machinecreation">'`
    + '<Property xsi:type="StringProperty" Name="SubscriptionId" Value="' + $SubscriptionId + '" />'`
    + '<Property xsi:type="StringProperty" Name="ManagementEndpoint" Value="https://management.azure.com/" />'`
    + '<Property xsi:type="StringProperty" Name="AuthenticationAuthority" Value="https://login.microsoftonline.com/" />'`
    + '<Property xsi:type="StringProperty" Name="StorageSuffix" Value="core.windows.net" />'`
    + '<Property xsi:type="StringProperty" Name="TenantId" Value="' + $TenantId + '" />'`
    + '<Property xsi:type="StringProperty" Name="AzureAdDeviceManagement" Value="false" />'`
    + '<Property xsi:type="StringProperty" Name="ProxyHypervisorTrafficThroughConnector" Value="true" />'`
    + '<Property xsi:type="StringProperty" Name="AuthenticationMode" Value="' + $AuthenticationMode + '" />'`
    + '</CustomProperties>'

    Set-Item -LiteralPath $connectionPath -CustomProperties $customPropsAuthMode -UserName $cred.username -Password $cred.password
}