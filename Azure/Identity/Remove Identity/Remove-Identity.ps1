<#
.SYNOPSIS
    Removes an Identity from the given Identity Pool. Applicable for Citrix DaaS and on-prem.
.DESCRIPTION
    Remove-Identity.ps1 emulates the behavior of the Remove-AcctIdentity command.
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

# [User Input Required] Set parameters for Remove-AcctIdentity
# The name of the identity pool. This must not contain any of the following characters \/;:#.*?=<>|[]()””’
$identityPoolName = "demo-identitypool01"

# The name of the identities
$identityAccountName1 = "demo001"
$identityAccountName2 = "demo002"

####################################
# Step 2: Remove the Identities    #
####################################

# Simply remove a identity from identity pool
Remove-AcctIdentity -IdentityPoolName $identityPoolName -IdentityAccountName $identityAccountName1

# Removes a identity from identity pool and delete it from AD
Remove-AcctIdentity -IdentityPoolName $identityPoolName -RemovalOption Delete -IdentityAccountName $identityAccountName2