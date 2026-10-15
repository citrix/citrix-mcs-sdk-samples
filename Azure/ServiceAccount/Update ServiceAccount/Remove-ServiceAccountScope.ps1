<#
.SYNOPSIS
    Removes a service account from one or more administration scopes. Applicable for Citrix DaaS and on-prem.
.DESCRIPTION
    Remove-ServiceAccountScope.ps1 emulates the behavior of the Remove-AcctServiceAccountScope command.
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

# [User Input Required] Set parameters for Remove-AcctServiceAccountScope
$serviceAccountUid = "00000000-0000-0000-0000-000000000000"
$scopes = @("Finance", "Marketing")

######################################################
# Step 2: Remove the service account from the scopes #
######################################################
Remove-AcctServiceAccountScope -Scope $scopes -ServiceAccountUid $serviceAccountUid
