<#
.SYNOPSIS
    Updates the display name, description and capabilities of a service account. Applicable for Citrix DaaS and on-prem.
.DESCRIPTION
    Update-ServiceAccount.ps1 emulates the behavior of the Set-AcctServiceAccount command.
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

# [User Input Required] Set parameters for Set-AcctServiceAccount
$serviceAccountUid = "00000000-0000-0000-0000-000000000000"
$displayName = "demo-serviceaccount"
$description = "Microsoft Entra ID, Intune and security group management"
# The capabilities are replaced, so supply the full set the service account should end up with.
$capabilities = @("AzureADDeviceManagement", "AzureADSecurityGroupManagement", "IntuneDeviceManagement")

######################################
# Step 2: Update the service account #
######################################
$serviceAccount = Set-AcctServiceAccount -ServiceAccountUid $serviceAccountUid `
    -DisplayName $displayName `
    -Description $description `
    -Capabilities $capabilities

############################################
# Step 3: Check the health of capabilities #
############################################
# A capability is unhealthy when the identity the service account authenticates as lacks a Microsoft Graph permission;
# FailureReason names that permission.
$serviceAccount.Capabilities | Format-Table Name, IsHealthy, FailureReason
