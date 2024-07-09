<#
.SYNOPSIS
    Removes an Identity Pool. Applicable for Citrix DaaS and on-prem.
.DESCRIPTION
    Remove-IdentityPool.ps1 emulates the behavior of the New-AcctIdentityPool command.
    The original version of this script is compatible with Citrix Virtual Apps and Desktops 7 2203 Long Term Service Release (LTSR).
#>

# /*************************************************************************
# * Copyright © 2024. Cloud Software Group, Inc. All Rights Reserved.
# * This file is subject to the license terms contained
# * in the license file that is distributed with this file.
# *************************************************************************/

################################
# Step 1: Setup the parameters #
################################
# Add Citrix snap-ins
Add-PSSnapin -Name "Citrix.Host.Admin.V2","Citrix.MachineCreation.Admin.V2"

# [User Input Required] Set parameters for Remove-AcctIdentityPool
# The name of the identity pool. This must not contain any of the following characters \/;:#.*?=<>|[]()””’
$identityPoolName = "demo-identitypool01"

# [User Input Required] AzContext
# Azure Subscription Id. It should be Guid.
$subscriptionId = "SubscriptionId"  #should be Guid
# The tenantId of AzureAD.
$azureADTenantId = "TenantId" #should be Guid
###############################################################
# Step 2: Connect to your Azure Resource Manager subscription #
###############################################################
Connect-AzAccount -TenantId $azureADTenantId -Credential (Get-Credential)

#################################################
# Step 2: Set subscription Id in your AD tenant #
#################################################
Set-AzContext -Tenant $azureADTenantId -Subscription $subscriptionId

##################################
# Step 3: Get Azure access token #
##################################
$token = Get-AzAccessToken -ResourceTypeName MSGraph -TenantId $azureADTenantId

####################################
# Step 4: Remove the AD Account(s) #
####################################
# Get the all the AD Accounts in the identity pool
$adAccountNames = Get-AcctADAccount -IdentityPoolName $identityPoolName | Select-Object -ExpandProperty ADAccountName
if($null -ne $adAccountNames -and $adAccountNames -ne '')
{
    Remove-AcctADAccount -IdentityPoolName $identityPoolName -ADAccountName $adAccountNames
}

################################################
# Step 5: Remove the Identity Pool properties. #
################################################
Remove-AcctIdentityPool -IdentityPoolName $identityPoolName -AzureADAccessToken $token.Token