<#
.SYNOPSIS
    Creates an Identity Pool. Applicable for Citrix DaaS and on-prem.
.DESCRIPTION
    Create-IdentityPool.ps1 emulates the behavior of the New-AcctIdentityPool command.
    The original version of this script is compatible with Citrix Virtual Apps and Desktops 7 2203 Long Term Service Release (LTSR).
#>

# /*************************************************************************
# * Copyright © 2024. Cloud Software Group, Inc.
# * This file is subject to the license terms contained
# * in the license file that is distributed with this file.
# *************************************************************************/

##########################
# Step 1: Find Zone Uid. #
##########################
# [User Input Required] Set parameters for New-AcctIdentityPool
# Gets zones with the specified name.
$zoneName = "AzureResourceLocation"

# The UID that corresponds to the Zone in which these AD accounts will be created.
# This is only intended to be used for Citrix Cloud Delivery Controllers.
$zoneUid = $null
$zone = Get-ConfigZone -Name $zoneName -ErrorAction 'SilentlyContinue'
$zoneUid = $zone.Uid
if($null -eq $zoneUid)
{
    throw "Could not find the zone (zoneName): $($zoneName). Verify the zoneName exists or try the default 'Primary.'"
}

################################
# Step 2: Setup the parameters #
################################
# Add Citrix snap-ins
Add-PSSnapin -Name "Citrix.Host.Admin.V2","Citrix.MachineCreation.Admin.V2"

# [User Input Required] Set parameters for New-AcctIdentityPool

# The type of device management type.
# This can be Intune, IntuneWithCitrixTags, or None.
# Setup value to be Intune here to support Azure Active Directory with Intune case.
$deviceManagementType = "Intune"
# The tenantId of AzureAD.
# Must be specified if “AzureADSecurityGroupName” is specified to create Azure AD security group, and IdentityType is “AzureAD” or “HybridAzureAD”.
$azureADTenantId = "TenantId" #should be Guid
# The name of the identity pool. This must not contain any of the following characters \/;:#.*?=<>|[]()””’
$identityPoolName = "demo-identitypool01"
# Defines the template name for AD accounts created in the identity pool.
# The scheme can consist of fixed characters and a variable part defined by ‘#’ characters.
# There can be only one variable region defined.
# The number of ‘#’ characters defines the minimum length of the variable region.
# For example, a naming scheme of H#### could create accounts called H0001,
# H0002 (for a numeric scheme type) or HAAAA, HAAAB (for an alphabetic type).
$namingScheme = "demo-###"
# The type of naming scheme. This can be Numeric or Alphabetic.
# This defines the format of the variable part of the AD account names that will be created.
# Setup value to be Numeric as a demo.
$namingSchemeType = "Numeric"
# The type of identity type. This can be ActiveDirectory, AzureAD, HybridAzureAD, or Workgroup.
# Setup value to be AzureAD to support AAD case.
$identityType = "AzureAD"
# Specifies the next number to be used when creating new AD accounts in the identity pool.
$startCount = 1
# The name of AzureAD security group. This is only intended to be used when IdentityType is “AzureAD” or “HybridAzureAD”.
$securityGroupMemberName = "aadsgxyz01"

# [User Input Required] Set parameters for AzContext
# Azure Subscription Id. It should be Guid.
$subscriptionId = "SubscriptionId"  #should be Guid

###############################################################
# Step 3: Connect to your Azure Resource Manager subscription #
###############################################################
Connect-AzAccount -TenantId $azureADTenantId -Credential (Get-Credential)

#################################################
# Step 4: Set subscription Id in your AD tenant #
#################################################
Set-AzContext -Tenant $azureADTenantId -Subscription $subscriptionId

##################################
# Step 5: Get Azure access token #
##################################
$token = Get-AzAccessToken -ResourceTypeName MSGraph -TenantId $azureADTenantId

####################################
# Step 6: Create the Identity Pool #
####################################
New-AcctIdentityPool -DeviceManagementType $deviceManagementType `
    -AzureADAccessToken $token.Token `
    -AzureADSecurityGroupName $securityGroupMemberName `
    -AzureADTenantId $azureADTenantId `
    -IdentityPoolName $identityPoolName `
    -IdentityType  $identityType `
    -NamingScheme $namingScheme `
    -NamingSchemeType $namingSchemeType `
    -StartCount $startCount `
    -ZoneUid $zoneUid `
    -WorkgroupMachine

#######################################################################################
# Step 7: Get Azure AD security group to verfiy if it has been created successfully.  #
#######################################################################################
$securtiyGroupMember = Get-AcctAzureADSecurityGroup -AccessToken $token.Token -Assigned $False -Dynamic $False -MaxRecordCount 300 -Name $securityGroupMemberName
if($null -eq $securtiyGroupMember.ObjectId)
{
    throw "Could not find the Azure AD security group (Azure AD Security Group Name): $($securityGroupMemberName). Please verify if the security group name created."
}