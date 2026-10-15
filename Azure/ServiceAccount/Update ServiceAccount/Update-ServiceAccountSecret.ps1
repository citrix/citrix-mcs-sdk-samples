<#
.SYNOPSIS
    Updates the application client secret of a service account and its expiry time. Applicable for Citrix DaaS and on-prem.
.DESCRIPTION
    Update-ServiceAccountSecret.ps1 updates the client secret of a service account that authenticates with an application client secret,
    for example after the secret of the app registration is renewed. A managed identity backed service account has no secret.
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

# [User Input Required] Set parameters for Set-AcctServiceAccount
$serviceAccountUid = "00000000-0000-0000-0000-000000000000"
$applicationSecret = Read-Host 'Please enter your new application secret' -AsSecureString
$secretExpiryTime = "2028-09-09"                                    # Use "" if the secret never expires

#############################
# Step 2: Update the secret #
#############################
Set-AcctServiceAccount -ServiceAccountUid $serviceAccountUid `
    -AccountSecret $applicationSecret `
    -SecretExpiryTime $secretExpiryTime
