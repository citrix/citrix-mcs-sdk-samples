<#
.SYNOPSIS
    Sets or changes the custom property on an existing MCS catalog.
    The updated custom properties will be applicable to new machines post operation, not to the existing machines.
    Applicable for Citrix DaaS and on-prem.
.DESCRIPTION
    Update-CustomProperties helps sets or change the custom property on an existing MCS catalog.
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

# [User Input Required] Setup the parameters for Set-ProvScheme
$provisioningSchemeName = "demo-provScheme"
$customProperties = "AwsCaptureInstanceProperties,false;AwsOperationalResourcesTagging,false"

#####################################################
# Step 1: Change the Provisioning Scheme properties #
#####################################################
# Change the provisioining scheme properties
Set-ProvScheme -ProvisioningSchemeName $provisioningSchemeName -CustomProperties $customProperties