<#
.SYNOPSIS
    Creates a service account that authenticates with an application client secret. Applicable for Citrix DaaS and on-prem.
.DESCRIPTION
    Create-ServiceAccount.ps1 creates an AzureAD service account from the application (client) id and client secret of an app registration.
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

# [User Input Required] Set parameters for New-AcctServiceAccount
$tenantId = "TenantId"                                              # Microsoft Entra tenant id
$applicationId = "AppId"                                            # Application (client) id of the app registration
$applicationSecret = Read-Host 'Please enter your application secret' -AsSecureString
$secretExpiryTime = "2027-09-09"                                    # Omit -SecretExpiryTime if the secret never expires
$displayName = "demo-serviceaccount"
$description = "Microsoft Entra ID and Intune device management"
$capabilities = @("AzureADDeviceManagement", "IntuneDeviceManagement")

######################################
# Step 2: Create the service account #
######################################
$serviceAccount = New-AcctServiceAccount -IdentityProviderType "AzureAD" `
    -IdentityProviderIdentifier $tenantId `
    -AccountId $applicationId `
    -AccountSecret $applicationSecret `
    -SecretExpiryTime $secretExpiryTime `
    -DisplayName $displayName `
    -Description $description `
    -Capabilities $capabilities

############################################
# Step 3: Check the health of capabilities #
############################################
# A capability is unhealthy when the app registration lacks a Microsoft Graph permission it needs; FailureReason names that permission.
$serviceAccount.Capabilities | Format-Table Name, IsHealthy, FailureReason
