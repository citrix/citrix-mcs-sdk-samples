<#
.SYNOPSIS
    Create the Service Principal.
.DESCRIPTION
    Create-ServicePrincipal.ps1 creates the service principal when SubscriptionId, TenantId, ApplicationName are provided.
    The original version of this script is compatible with Citrix Virtual Apps and Desktops 7 2203 Long Term Service Release (LTSR).
#>

# /*************************************************************************
# * Copyright © 2024. Cloud Software Group, Inc. All Rights Reserved.
# * This file is subject to the license terms contained
# * in the license file that is distributed with this file.
# *************************************************************************/

# [User Input Required]
$ApplicationName = "MyAppId2"           # The name of your application
$SubscriptionId = "SubscriptionId"      # Azure subscription ID
$TenantId = "TenantId"                  # Azure AD Directory ID
$roleName = "Role"                      # Like Contributor

# Note - Open Powershell as Administrator
# Install the Az modules before importing. Refer to the README file in the "Add HostingConnection" folder.
Import-Module Az

###############################################################
# Step 1: Connect to your Azure Resource Manager subscription #
###############################################################

Connect-AzAccount

####################################################
# Step 2: Create the application in your AD tenant #
####################################################

Set-AzContext -Tenant $TenantId -Subscription $SubscriptionId
Get-AzSubscription -SubscriptionId $SubscriptionId | Select-AzSubscription
$AzureADApplication = New-AzADApplication -DisplayName $ApplicationName

######################################
# Step 3: Create a service principal #
######################################

# Run Get-AzSubscription -ObjectId $objectId (you can find the ObjectId value on App created in Azure portal). And if the output of this cmdlet has AppId instead of ApplicationId use $AzureADApplication.AppId inplace of $AzureADApplication.ApplicationId.
New-AzADServicePrincipal -ApplicationId $AzureADApplication.ApplicationId

##################################################
# Step 4: Assign a role to the service principal #
##################################################

# Run Get-AzSubscription -ObjectId $objectId (you can find the ObjectId value on App created in Azure portal). And if the output of this cmdlet has AppId instead of ApplicationId use $AzureADApplication.AppId inplace of $AzureADApplication.ApplicationId.
New-AzRoleAssignment -RoleDefinitionName $roleName -ServicePrincipalName $AzureADApplication.ApplicationId -scope /subscriptions/$SubscriptionId
# From the output window of the PowerShell console, note the ApplicationId. You have to provide that ID when creating the host connection.
# Obtain the application secret from Azure by following the link provided in the README document within this folder