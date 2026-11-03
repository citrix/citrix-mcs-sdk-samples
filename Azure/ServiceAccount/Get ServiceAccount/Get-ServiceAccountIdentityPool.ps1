<#
.SYNOPSIS
    Gets the identity pools that use a service account. Applicable for Citrix DaaS and on-prem.
.DESCRIPTION
    Get-ServiceAccountIdentityPool.ps1 emulates the behavior of the Get-AcctServiceAccountIdentityPool command.
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

# [User Input Required] Set parameters for Get-AcctServiceAccountIdentityPool
$serviceAccountUid = "00000000-0000-0000-0000-000000000000"

#########################################################
# Step 2: Get the identity pools of the service account #
#########################################################
# IdentityPools lists the IdentityPoolName and IdentityPoolUid of every identity pool that uses the service account.
(Get-AcctServiceAccountIdentityPool -ServiceAccountUid $serviceAccountUid).IdentityPools
