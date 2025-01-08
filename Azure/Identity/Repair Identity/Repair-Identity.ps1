<#
.SYNOPSIS
    Repair the given identity accounts in identity pool. Applicable for Citrix DaaS and on-prem.
.DESCRIPTION
    This provides the ability to repair identities in the identity pool that behave abnormal without changing the current states of the identities.
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
$identityAccountName1 = "demo001"
$identityAccountName2 = "demo002"

# The target to be repaired. It can be either 'IdentityInfo' or 'UserCertificate'. 
$target1 = "IdentityInfo"
$target2 = "UserCertificate"

####################################
# Step 2: Repair the Identities    #
####################################

# Repair the identiy's password and trust key pair
Repair-AcctIdentity -IdentityAccountName $identityAccountName1 -target $target1

# Repair the identiy's userCertificate
Repair-AcctIdentity -IdentityAccountName $identityAccountName2 -target $target2