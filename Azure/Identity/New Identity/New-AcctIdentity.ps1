<#
.SYNOPSIS
    Creates new identities in an existing identity pool. Applicable for Citrix DaaS and on-prem.
.DESCRIPTION
    New-AcctIdentity.ps1 emulates the behavior of the New-AcctIdentity command.
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

# [User Input Required] Set parameters for New-AcctIdentity
$identityPoolName = "demo-identitypool01"

$count = 5

#################################
# Step 2: Create new Identities #
#################################
# Create multiple Identities into the given Identity Pool
New-AcctIdentity -IdentityPoolName $identityPoolName -Count $count -OutVariable result

# Display the result
$result[0].SuccessfulAccounts