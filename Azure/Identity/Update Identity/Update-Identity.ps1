<#
.SYNOPSIS
    Update the identity accounts in a given identity pool. Applicable for Citrix DaaS and on-prem.
.DESCRIPTION
    Provides the ability to synchronize the state of the identity accounts stored in the AD Identity Service with the accounts themselves. 
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

# [User Input Required] Set parameters for Repair-AcctIdentity
# The name of the identity pool. This must not contain any of the following characters \/;:#.*?=<>|[]()””’
$identityPoolName = "demo-identitypool"

####################################
# Step 2: Update the Identity    #
####################################

# Update the identiy
Update-AcctIdentity -IdentityPoolName $identityPoolName
