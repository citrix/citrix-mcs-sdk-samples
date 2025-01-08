<#
.SYNOPSIS
    Imports one or mutiple existing identities into an existing identity pool. Applicable for Citrix DaaS and on-prem.
.DESCRIPTION
    Add-AcctIdentity.ps1 emulates the behavior of the Add-AcctIdentity command.
#>

# /*************************************************************************
# * Copyright © 2024. Cloud Software Group, Inc. All Rights Reserved.
# * This file is subject to the license terms contained
# * in the license file that is distributed with this file.
# *************************************************************************/

################################
# Step 1: Setup the parameters #
################################
# Add Citrix snap-ins
Add-PSSnapin -Name "Citrix.Host.Admin.V2","Citrix.MachineCreation.Admin.V2"

# [User Input Required] Set parameters for Add-AcctIdentity
$identityPoolName = "demo-identitypool01"

$identityName1 = "demo-001"

$identityName2 = "demo-002"

#################################
# Step 2: Import Identities #
#################################
# Add multiple Identities into the given Identity Pool
Add-AcctIdentity -IdentityPoolName $identityPoolName -IdentityAccountName $identityName1, $identityName2