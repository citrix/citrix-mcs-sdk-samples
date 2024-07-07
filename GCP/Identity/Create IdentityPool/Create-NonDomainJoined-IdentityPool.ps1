<#
.SYNOPSIS
    Creates a Non-domain joined Identity Pool. Applicable for Citrix DaaS and on-prem.
.DESCRIPTION
    This script emulates the behavior of the New-AcctIdentityPool command.
    The original version of this script is compatible with Citrix Virtual Apps and Desktops 7 2203 Long Term Service Release (LTSR).
#>

# /*************************************************************************
# * Copyright © 2024. Cloud Software Group, Inc. All Rights Reserved.
# * This file is subject to the license terms contained
# * in the license file that is distributed with this file.
# *************************************************************************/

Add-PSSnapin -Name "Citrix.Host.Admin.V2","Citrix.MachineCreation.Admin.V2"

##########################
# Step 1: Find Zone Uid. #
##########################
# [User Input Required]
# Zone specific commands are only intended to be used for Citrix Cloud Delivery Controllers.
# Gets zone with the specified name.
$zoneName = "gcp-zone"
$zone = Get-ConfigZone -Name $zoneName -ErrorAction 'SilentlyContinue'
# Gets the UID that corresponds to the Zone in which these AD accounts will be created.
$zoneUid = $zone.Uid
if($null -eq $zoneUid)
{
    throw "Could not find the zone (zoneName): $($zoneName). Verify that the zone exists."
}

#################################
# Step 2: Setup the parameters. #
#################################
# [User Input Required]
# Set parameters for New-AcctIdentityPool
# This must not contain any of the following characters \/;:#.*?=<>|[]()””’
$identityPoolName = "demo-identity-pool"

# NamingScheme defines the template name for AD accounts created in the identity pool.
# The scheme can consist of fixed characters and a variable part defined by ‘#’ characters.
# For example, a naming scheme of H#### could create accounts called H0001, H0002 (for a numeric scheme type) or HAAAA, HAAAB (for an alphabetic type).
$namingScheme = "demo-identity-pool-###"

# The type of naming scheme. Can be "Numeric" or "Alphabetic".
$namingSchemeType = "Numeric"

# The type of identity type. This can be ActiveDirectory, AzureAD, HybridAzureAD, or Workgroup. For Non-domain joined machines, use "Workgroup".
$identityType = "Workgroup"

#####################################
# Step 3: Create the Identity Pool. #
#####################################
New-AcctIdentityPool -AllowUnicode `
    -IdentityType $identityType `
    -WorkgroupMachine -IdentityPoolName $identityPoolName `
    -NamingScheme $namingScheme `
    -NamingSchemeType $namingSchemeType `
    -Scope @() `
    -ZoneUid $zoneUid