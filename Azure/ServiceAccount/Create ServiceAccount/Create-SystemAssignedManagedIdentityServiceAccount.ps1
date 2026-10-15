<#
.SYNOPSIS
    Creates a service account that authenticates with the system-assigned managed identity of the Cloud Connectors. Applicable for Citrix DaaS.
.DESCRIPTION
    Create-SystemAssignedManagedIdentityServiceAccount.ps1 creates an AzureAD service account that obtains its Microsoft Graph tokens
    from the system-assigned managed identity of the Cloud Connectors in a resource location. Neither an account id nor a secret is supplied.
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

# [User Input Required] Set parameters for New-AcctServiceAccount
$tenantId = "TenantId"                                              # Microsoft Entra tenant id
$zoneName = "demo-resource-location"                                # Resource location whose Cloud Connectors carry the managed identity
$displayName = "demo-serviceaccount"
$description = "Microsoft Entra ID and Intune device management"
$capabilities = @("AzureADDeviceManagement", "IntuneDeviceManagement")

##############################
# Step 2: Find the zone Uid. #
##############################
$zone = Get-ConfigZone -Name $zoneName -ErrorAction 'SilentlyContinue'
if ($null -eq $zone)
{
    throw "Could not find the zone (zoneName): $($zoneName). Verify the zoneName exists."
}

######################################
# Step 3: Create the service account #
######################################
# The managed identity lives on the Cloud Connectors, so the service account routes its traffic through the connectors of the zone.
$customProperties = [ordered]@{
    ProxyHypervisorTrafficThroughConnector = $true
    ZoneUid = @($zone.Uid.ToString())
    AuthenticationMode = "SystemAssignedManagedIdentity"
} | ConvertTo-Json -Compress

# Creating the service account acquires a Microsoft Graph token from the managed identity before the account is saved.
$serviceAccount = New-AcctServiceAccount -IdentityProviderType "AzureAD" `
    -IdentityProviderIdentifier $tenantId `
    -DisplayName $displayName `
    -Description $description `
    -Capabilities $capabilities `
    -CustomProperties $customProperties

############################################
# Step 4: Check the health of capabilities #
############################################
# A capability is unhealthy when the managed identity lacks a Microsoft Graph permission it needs; FailureReason names that permission.
$serviceAccount.Capabilities | Format-Table Name, IsHealthy, FailureReason
