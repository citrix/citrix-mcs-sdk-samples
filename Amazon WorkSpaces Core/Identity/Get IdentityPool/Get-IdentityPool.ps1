﻿<#
.SYNOPSIS
    Gets an Identity Pool. Applicable for Citrix DaaS and on-prem.
.DESCRIPTION
    Get-IdentityPool.ps1 emulates the behavior of the Get-AcctIdentityPool command.
    The original version of this script is compatible with Citrix DaaS July 2025 Release (DDC 125).
#>

# /*************************************************************************
# * Copyright © 2025. Cloud Software Group, Inc. All Rights Reserved.
# * This file is subject to the license terms contained
# * in the license file that is distributed with this file.
# *************************************************************************/

################################
# Step 0: Setup the parameters #
################################
# Add Citrix snap-ins
Add-PSSnapin -Name "Citrix.Host.Admin.V2","Citrix.MachineCreation.Admin.V2"

# [User Input Required] Set parameters for Get-AcctIdentityPool
$identityPoolName = "demo-identitypool"
$filter = "{ NamingSchemeType -eq 'Numeric' }"
$sortBy = "-AvailableAccounts"
$maxRecord = 5

#################################
# Step 1: Get the Identity Pool #
#################################

# Get a specific Identity Pool
Get-AcctIdentityPool -IdentityPoolName $identityPoolName

# Use Filter and SortBy to get a list of Identity Pools
Get-AcctIdentityPool -Filter $filter -SortBy $sortBy -MaxRecordCount $maxRecord