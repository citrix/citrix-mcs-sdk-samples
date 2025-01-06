<#
.SYNOPSIS
    Retrieve a list of existing identities and its properties. Applicable for Citrix DaaS and on-prem.
.DESCRIPTION
    Get-AcctIdentity.ps1 emulates the behavior of the Get-AcctIdentity command.
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

# [User Input Required] Set parameters for Get-AcctIdentity
$identityAccountId = "S-2-7-21-24521345-865934153-2418134190-2784"
$identityPoolName = "demo-identitypool"
$filter = "{ State -eq 'InUse' }"
$sortBy = "IdentityPoolUid"
$maxRecord = 5

#################################
# Step 2: Get the Identity      #
#################################
# Get specific Identity
Get-AcctIdentity -IdentityAccountId $identityAccountId

# Get Identities in the specific Identity Pool
Get-AcctIdentity -IdentityPoolName $identityPoolName

# Use Filter and SortBy to get a list of Identity Pools
Get-AcctIdentity -Filter $filter -SortBy $sortBy -MaxRecordCount $maxRecord