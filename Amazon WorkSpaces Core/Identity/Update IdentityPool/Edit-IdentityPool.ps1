<#
.SYNOPSIS
    Updates an Identity Pool's properties. Applicable for Citrix DaaS and on-prem.
.DESCRIPTION
    Edit-IdentityPool.ps1 edits the Identity Pool's properties.
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

# [User Input Required] Set parameters for Set-AcctIdentityPool
$identityPoolName = "demo-identitypool"
$newIdentityPoolName = "new-demo-identitypool"
$namingScheme = "demo-###"
$domain = "demo.local"
$namingSchemeType = "Numeric"
$zoneUid = "00000000-0000-0000-0000-000000000000"

################################################
# Step 1: Change the Identity Pool properties. #
################################################
# Set Identity pool with user provided values
Set-AcctIdentityPool -IdentityPoolName $identityPoolName -NamingScheme $namingScheme -NamingSchemeType $namingSchemeType -Domain $domain -ZoneUid $zoneUid

####################################
# Step 2: Rename the Identity Pool #
####################################
# Change the Identity Pool Name
Rename-AcctIdentityPool -IdentityPoolName $identityPoolName -NewIdentityPoolName $newIdentityPoolName