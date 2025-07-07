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
$identityPoolName = "demo-identitypool"
$namingScheme = "demo-###"
$domain = "aws-apollo.local"
$namingSchemeType = "Numeric"
$zoneUid = "00000000-0000-0000-0000-000000000000"

####################################
# Step 1: Create the Identity Pool #
####################################

New-AcctIdentityPool -IdentityPoolName $identityPoolName -NamingScheme $namingScheme -NamingSchemeType $namingSchemeType -Domain $domain -ZoneUid $zoneUid