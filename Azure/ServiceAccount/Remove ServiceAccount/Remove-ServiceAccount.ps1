<#
.SYNOPSIS
    Removes a service account. Applicable for Citrix DaaS and on-prem.
.DESCRIPTION
    Remove-ServiceAccount.ps1 emulates the behavior of the Remove-AcctServiceAccount command.
    A managed identity backed service account is removed the same way; the managed identity in Azure is not changed.
    The original version of this script is compatible with Citrix Virtual Apps and Desktops 7 2411.
#>

# /*************************************************************************
# * Copyright © 2026. Cloud Software Group, Inc. All Rights Reserved.
# * This file is subject to the license terms contained
# * in the license file that is distributed with this file.
# *************************************************************************/

################################
# Step 1: Setup the parameters #
################################
# Add Citrix snap-ins
Add-PSSnapin -Name "Citrix.ADIdentity.Admin.V2"

# [User Input Required] Set parameters for Remove-AcctServiceAccount
$serviceAccountUid = "00000000-0000-0000-0000-000000000000"

###########################################################
# Step 2: Check the identity pools of the service account #
###########################################################
# A service account cannot be removed while an identity pool still uses it.
# Assign those identity pools another service account with Set-AcctIdentityPool -ServiceAccountUid first.
$identityPools = (Get-AcctServiceAccountIdentityPool -ServiceAccountUid $serviceAccountUid).IdentityPools
if ($identityPools)
{
    throw "The service account is still used by the identity pools: $($identityPools.IdentityPoolName -join ', ')."
}

######################################
# Step 3: Remove the service account #
######################################
Remove-AcctServiceAccount -ServiceAccountUid $serviceAccountUid
