﻿<#
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
# Step 1: Setup the parameters #
################################
# Add Citrix snap-ins
Add-PSSnapin -Name "Citrix.Host.Admin.V2","Citrix.MachineCreation.Admin.V2"

# [User Input Required] Set parameters for Remove-AcctIdentityPool
# The name of the identity pool. This must not contain any of the following characters \/;:#.*?=<>|[]()””’
$identityPoolName = "demo-identitypool01"

####################################
# Step 2: Remove the Identities    #
####################################
# Get the all the identities in the identity pool
$identityAccountName = Get-AcctIdentity -IdentityPoolName $identityPoolName | Select-Object -ExpandProperty IdentityAccountName
if($null -ne $identityAccountName -and $identityAccountName -ne '')
{
    Remove-AcctIdentity -IdentityPoolName $identityPoolName -IdentityAccountName $identityAccountName
}

################################################
# Step 3: Remove the Identity Pool properties. #
################################################
Remove-AcctIdentityPool -IdentityPoolName $identityPoolName