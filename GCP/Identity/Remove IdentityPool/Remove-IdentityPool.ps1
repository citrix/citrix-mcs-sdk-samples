<#
.SYNOPSIS
    Removes an Identity Pool. Applicable for Citrix DaaS and on-prem.
.DESCRIPTION
    This script uses the Remove-AcctADAccount command to delete AD Accounts followed by Remove-AcctIdentityPool command to delete the given Identity pool.
    The original version of this script is compatible with Citrix Virtual Apps and Desktops 7 2203 Long Term Service Release (LTSR).
#>

# /*************************************************************************
# * Copyright © 2024. Cloud Software Group, Inc. All Rights Reserved.
# * This file is subject to the license terms contained
# * in the license file that is distributed with this file.
# *************************************************************************/

Add-PSSnapin -Name "Citrix.Host.Admin.V2","Citrix.MachineCreation.Admin.V2"

# [User Input Required]
$identityPoolName = "demo-identitypool"

####################################
# Step 1: Remove the AD Account(s) #
####################################

$adAccountNames = Get-AcctADAccount -IdentityPoolName $identityPoolName | Select-Object -ExpandProperty ADAccountName
if($null -ne $adAccountNames -and $adAccountNames -ne '')
{
    Remove-AcctADAccount -IdentityPoolName $identityPoolName -ADAccountName $adAccountNames
}

#####################################
# Step 2: Remove the Identity Pool. #
#####################################

Remove-AcctIdentityPool -IdentityPoolName $identityPoolName