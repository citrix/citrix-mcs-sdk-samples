<#
.SYNOPSIS
    Creates an Identity Pool. Applicable for Citrix DaaS and on-prem.
.DESCRIPTION
    Create-NDJ-IdentityPool.ps1 emulates the behavior of the New-AcctIdentityPool command.
    The original version of this script is compatible with Citrix Virtual Apps and Desktops 7 2203 Long Term Service Release (LTSR).
#>

# /*************************************************************************
# * Copyright © 2024. Cloud Software Group, Inc.
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
$namingSchemeType = "Numeric"
$zoneUid = "00000000-0000-0000-0000-000000000000"

#####################################################
# Step 1 : Create a Non-domain-joined Identity Pool #
#####################################################
New-AcctIdentityPool -IdentityPoolName $identityPoolName -NamingScheme $namingScheme -NamingSchemeType $namingSchemeType -ZoneUid $zoneUid -WorkgroupMachine