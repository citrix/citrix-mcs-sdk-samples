<#
.SYNOPSIS
    Switches a managed identity backed service account back to an application client secret. Applicable for Citrix DaaS.
.DESCRIPTION
    Switch-ServiceAccountToAppClientSecret.ps1 switches an existing AzureAD service account from a system-assigned or user-assigned
    managed identity back to the client secret of an app registration. The application id and secret were cleared when the service account
    moved to the managed identity, so they must be supplied again.
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
$applicationId = "AppId"                                            # Application (client) id of the app registration
$applicationSecret = Read-Host 'Please enter your application secret' -AsSecureString
$secretExpiryTime = "2027-09-09"                                    # Omit -SecretExpiryTime if the secret never expires
$zoneName = "demo-resource-location"                                # Resource location whose Cloud Connectors the traffic is routed through

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
# The custom properties are replaced, so supply all the properties the service account should end up with.
$customProperties = [ordered]@{
    ProxyHypervisorTrafficThroughConnector = $true
    ZoneUid = @($zone.Uid.ToString())
    AuthenticationMode = "AppClientSecret"
} | ConvertTo-Json -Compress

# The application id and secret must be supplied in the same command.
$serviceAccount = Set-AcctServiceAccount -ServiceAccountUid $serviceAccountUid `
    -AccountId $applicationId `
    -AccountSecret $applicationSecret `
    -SecretExpiryTime $secretExpiryTime `
    -CustomProperties $customProperties

############################################
# Step 4: Check the health of capabilities #
############################################
$serviceAccount.Capabilities | Format-Table Name, IsHealthy, FailureReason
