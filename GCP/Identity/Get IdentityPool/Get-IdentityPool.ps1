<#
.SYNOPSIS
    Gets an Identity Pool. Applicable for Citrix DaaS and on-prem.
.DESCRIPTION
    This script uses the Get-AcctIdentityPool command to get details of an Identity Pool.
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
$filter = "{ NamingSchemeType -eq 'Numeric' }"
$sortBy = "-AvailableAccounts"
$maxRecord = 5

###############################
# Step 1: Get Identity Pools. #
###############################
# Get a specific Identity Pool
Get-AcctIdentityPool -IdentityPoolName $identityPoolName

# Use Filter and SortBy to get a list of Identity Pools
Get-AcctIdentityPool -Filter $filter -SortBy $sortBy -MaxRecordCount $maxRecord