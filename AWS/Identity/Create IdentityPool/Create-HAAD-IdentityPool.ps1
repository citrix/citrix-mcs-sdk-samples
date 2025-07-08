<#
.SYNOPSIS
    Creates an Identity Pool. Applicable for Citrix DaaS and on-prem.
.DESCRIPTION
    Create-IdentityPool.ps1 emulates the behavior of the New-AcctIdentityPool command.
    The original version of this script is compatible with Citrix DaaS July 2025 Release (DDC 125).
#>

# /*************************************************************************
# * Copyright © 2025. Cloud Software Group, Inc. All Rights Reserved.
# * This file is subject to the license terms contained
# * in the license file that is distributed with this file.
# *************************************************************************/

################################
# Step 0: Setup the parameters #
################################
# Add Citrix snap-ins
Add-PSSnapin -Name "Citrix.Host.Admin.V2","Citrix.MachineCreation.Admin.V2"

# [User Input Required] Set parameters for New-AcctIdentityPool
$identityPoolName = "haad-identitypool"
$namingScheme = "haad-###"
$domain = "cvad-haad.local"
$namingSchemeType = "Numeric"
$zoneUid = "00000000-0000-0000-0000-000000000000"
$identityType = "HybridAzureAD"
$OU = "CN=Computers,DC=cvad,DC=local"

# Validate Zone UID
$zone = Get-ConfigZone -Uid $zoneName
if($null -eq $zone)
{
    throw "Could not find the zone (zoneUid): $($zoneUid). Verify the zoneUid exists."
}
####################################
# Step 1: Create the Identity Pool #
####################################

New-AcctIdentityPool -IdentityPoolName $identityPoolName `
    -NamingScheme $namingScheme `
    -NamingSchemeType $namingSchemeType `
    -IdentityType $identityType `
    -OU $OU `
    -Domain $domain `
    -ZoneUid $zoneUid