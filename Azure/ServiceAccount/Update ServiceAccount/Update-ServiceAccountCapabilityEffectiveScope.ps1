<#
.SYNOPSIS
    Sets the effective scope of a capability of a service account. Applicable for Citrix DaaS and on-prem.
.DESCRIPTION
    Update-ServiceAccountCapabilityEffectiveScope.ps1 emulates the behavior of the Set-AcctServiceAccountCapabilityEffectiveScope command.
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

# [User Input Required] Set parameters for Set-AcctServiceAccountCapabilityEffectiveScope
$serviceAccountUid = "00000000-0000-0000-0000-000000000000"
$capability = "AzureArcResourceManagement"
$effectiveScope = "SubscriptionId"                                  # For an AzureAD service account, an Azure subscription id in the tenant

#####################################################
# Step 2: Set the effective scope of the capability #
#####################################################
Set-AcctServiceAccountCapabilityEffectiveScope -ServiceAccountUid $serviceAccountUid `
    -Capability $capability `
    -EffectiveScope $effectiveScope
