<#
.SYNOPSIS
    Gets service accounts, the health of their capabilities, and their authentication mode. Applicable for Citrix DaaS and on-prem.
.DESCRIPTION
    Get-ServiceAccount.ps1 emulates the behavior of the Get-AcctServiceAccount command.
    The original version of this script is compatible with Citrix Virtual Apps and Desktops 7 2411.
#>

# /*************************************************************************
# * Copyright © 2026. Cloud Software Group, Inc. All Rights Reserved.
# * This file is subject to the license terms contained
# * in the license file that is distributed with this file.
# *************************************************************************/

################################
# Step 1: Setup the parameters #
################################
# Add Citrix snap-ins
Add-PSSnapin -Name "Citrix.ADIdentity.Admin.V2"

# [User Input Required] Set parameters for Get-AcctServiceAccount
$serviceAccountUid = "00000000-0000-0000-0000-000000000000"
$tenantId = "TenantId"                                              # Microsoft Entra tenant id
$filter = "{ IdentityProviderType -eq 'AzureAD' }"
$sortBy = "DisplayName"
$maxRecord = 5

####################################
# Step 2: Get the service accounts #
####################################
# Get a specific service account
$serviceAccount = Get-AcctServiceAccount -ServiceAccountUid $serviceAccountUid
$serviceAccount

# Get the service accounts of a Microsoft Entra tenant
Get-AcctServiceAccount -IdentityProviderIdentifier $tenantId

# Get the unhealthy service accounts
Get-AcctServiceAccount -IsHealthy $false

# Use Filter and SortBy to get a list of service accounts
Get-AcctServiceAccount -Filter $filter -SortBy $sortBy -MaxRecordCount $maxRecord

################################################
# Step 3: Check the health of the capabilities #
################################################
# A capability is unhealthy when the identity the service account authenticates as lacks a Microsoft Graph permission;
# FailureReason names that permission.
$serviceAccount.Capabilities | Format-Table Name, EffectiveScope, IsHealthy, FailureReason

#######################################
# Step 4: Get the authentication mode #
#######################################
# The authentication mode is the AuthenticationMode key of the custom properties. When it is absent, the service account
# authenticates with an application client secret.
$authenticationMode = "AppClientSecret"
if ($serviceAccount.CustomProperties)
{
    $customProperties = $serviceAccount.CustomProperties | ConvertFrom-Json
    if ($customProperties.AuthenticationMode) { $authenticationMode = $customProperties.AuthenticationMode }
}

# For a user-assigned managed identity, AccountId is the client id of the managed identity. For a system-assigned one, it is empty.
Write-Output "AuthenticationMode: $($authenticationMode), AccountId: $($serviceAccount.AccountId)"
