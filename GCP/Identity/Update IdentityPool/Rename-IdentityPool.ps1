<#
.SYNOPSIS
    Renames an Identity Pool. Applicable for Citrix DaaS and on-prem.
.DESCRIPTION
    This script renames the Identity Pool.
    The original version of this script is compatible with Citrix Virtual Apps and Desktops 7 2203 Long Term Service Release (LTSR).
#>

# /*************************************************************************
# * Copyright © 2024. Cloud Software Group, Inc. All Rights Reserved.
# * This file is subject to the license terms contained
# * in the license file that is distributed with this file.
# *************************************************************************/

# Add Citrix snap-ins
Add-PSSnapin -Name "Citrix.Host.Admin.V2","Citrix.MachineCreation.Admin.V2"

# [User Input Required]
$identityPoolName = "demo-identitypool"
$newIdentityPoolName = "rename-demo-identitypool"

##########################################
# Step 1: Change the Identity Pool Name. #
##########################################

Rename-AcctIdentityPool -IdentityPoolName $identityPoolName -NewIdentityPoolName $newIdentityPoolName