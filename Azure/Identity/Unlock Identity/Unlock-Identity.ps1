<#
.SYNOPSIS
    Unlocks the given identity accounts. It resets "Tainted" accounts to "Available". Applicable for Citrix DaaS and on-prem.
.DESCRIPTION
    Provides the ability to unlock given identity accounts. An identity account is marked as locked while the Machine Creation Services (MCS) are processing tasks relating to the account.
    If these tasks are forcibly stopped, an account can remain locked despite no longer being processed. 
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
# Step 2: Unlock the Identity    #
####################################

# Unlock the identiy
Unlock-AcctIdentity -IdentityAccountName $identityAccountName
