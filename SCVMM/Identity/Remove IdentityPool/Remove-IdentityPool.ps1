<#
.SYNOPSIS
    Removes an Identity Pool. Applicable for Citrix DaaS and on-prem.
.DESCRIPTION
    Remove-IdentityPool.ps1 emulates the behavior of the New-AcctIdentityPool command.
    The original version of this script is compatible with Citrix Virtual Apps and Desktops 7 2203 Long Term Service Release (LTSR).
#>

# /*************************************************************************
# * Copyright © 2024. Cloud Software Group, Inc. All Rights Reserved.
# * This file is subject to the license terms contained
# * in the license file that is distributed with this file.
# *************************************************************************/

################################
# Step 0: Setup the parameters #
################################
# Add Citrix snap-ins
Add-PSSnapin -Name "Citrix.Host.Admin.V2","Citrix.MachineCreation.Admin.V2"

# [User Input Required] Set parameters for Remove-AcctIdentityPool
$identityPoolName = "demo-identitypool"

####################################
# Step 1: Remove the AD Account(s) #
####################################
# Get the all the AD Accounts in the identity pool
$adAccountNames = Get-AcctADAccount -IdentityPoolName $identityPoolName | Select-Object -ExpandProperty ADAccountName

Remove-AcctADAccount -IdentityPoolName $identityPoolName -ADAccountName $adAccountNames

################################################
# Step 2: Remove the Identity Pool properties. #
################################################

Remove-AcctIdentityPool -IdentityPoolName $identityPoolName