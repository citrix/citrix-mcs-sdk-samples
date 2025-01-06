<#
.SYNOPSIS
    Resets the given identity accounts in identity pool. It resets "Tainted" accounts to "Available". Applicable for Citrix DaaS and on-prem.
.DESCRIPTION
    This provides the ability to reset identities of the identity pool that behave abnormally. It resets "Tainted" accounts to "Available".
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
# The name of the identity. This must not contain any of the following characters \/;:#.*?=<>|[]()””’
$identityAccountName = "demo001"

####################################
# Step 2: Reset the Identity    #
####################################

# Reset the identiy
Reset-AcctIdentity -IdentityAccountName $identityAccountName
