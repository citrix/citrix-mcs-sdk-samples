<#
.SYNOPSIS
    Adds a service account to one or more administration scopes. Applicable for Citrix DaaS and on-prem.
.DESCRIPTION
    Add-ServiceAccountScope.ps1 emulates the behavior of the Add-AcctServiceAccountScope command.
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

# [User Input Required] Set parameters for Add-AcctServiceAccountScope
$serviceAccountUid = "00000000-0000-0000-0000-000000000000"
$scopes = @("Finance", "Marketing")

#################################################
# Step 2: Add the service account to the scopes #
#################################################
Add-AcctServiceAccountScope -Scope $scopes -ServiceAccountUid $serviceAccountUid
