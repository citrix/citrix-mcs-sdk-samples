<#
.SYNOPSIS
    Switches a service account to a user-assigned managed identity assigned to the Cloud Connectors. Applicable for Citrix DaaS.
.DESCRIPTION
    Switch-ServiceAccountToUserAssignedManagedIdentity.ps1 switches an existing AzureAD service account, from an application client secret
    or a system-assigned managed identity, to a user-assigned managed identity assigned to the Cloud Connectors in a resource location.
    The client id of the managed identity overwrites the account id, and the stored secret and its expiry are cleared.
    The original version of this script is compatible with Citrix DaaS DDC 131.
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
Add-PSSnapin -Name "Citrix.ADIdentity.Admin.V2", "Citrix.Configuration.Admin.V2"

# [User Input Required] Set parameters for Set-AcctServiceAccount
$serviceAccountUid = "00000000-0000-0000-0000-000000000000"
$managedIdentityClientId = "ManagedIdentityClientId"                # Client id of the user-assigned managed identity
$zoneName = "demo-resource-location"                                # Resource location whose Cloud Connectors carry the managed identity

##############################
# Step 2: Find the zone Uid. #
##############################
$zone = Get-ConfigZone -Name $zoneName -ErrorAction 'SilentlyContinue'
if ($null -eq $zone)
{
    throw "Could not find the zone (zoneName): $($zoneName). Verify the zoneName exists."
}

##########################################
# Step 3: Switch the authentication mode #
##########################################
# Azure Arc onboarding (AzureArcResourceManagement) is not supported with a managed identity; keep such a service account on an application client secret.
# The custom properties are replaced, so supply all the properties the service account should end up with.
$customProperties = [ordered]@{
    ProxyHypervisorTrafficThroughConnector = $true
    ZoneUid = @($zone.Uid.ToString())
    AuthenticationMode = "UserAssignedManagedIdentity"
} | ConvertTo-Json -Compress

# The client id of the managed identity must be supplied in the same command; the stored account id means something else across a mode change.
# The switch acquires a Microsoft Graph token from the managed identity before the change is saved.
$serviceAccount = Set-AcctServiceAccount -ServiceAccountUid $serviceAccountUid `
    -AccountId $managedIdentityClientId `
    -CustomProperties $customProperties

############################################
# Step 4: Check the health of capabilities #
############################################
$serviceAccount.Capabilities | Format-Table Name, IsHealthy, FailureReason
