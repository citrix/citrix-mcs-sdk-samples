<#
.SYNOPSIS
    Renames an existing MCS and Broker catalog. Applicable for Citrix DaaS and on-prem.
.DESCRIPTION
    Rename-ProvScheme renames an existing MCS and Broker catalog's.
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

# [User Input Required] Setup the parameters for Rename-BrokerCatalog and Rename-ProvScheme
$provisioningSchemeName = "demo-provScheme"
$newprovisioningSchemeName = "new-demo-provScheme"

######################################################
# Step 1: Rename the Provisioning Scheme and Catalog #
######################################################
# Rename Catalog and Provscheme
Rename-BrokerCatalog -Name $provisioningSchemeName -NewName $newprovisioningSchemeName
Rename-ProvScheme -ProvisioningSchemeName $provisioningSchemeName -NewProvisioningSchemeName $newprovisioningSchemeName