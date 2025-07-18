﻿<#
.SYNOPSIS
    Sets or changes the an existing Broker catalog's properties. Applicable for Citrix DaaS and on-prem.
.DESCRIPTION
    Update-BrokerCatalog helps sets or changes the an existing Broker catalog's properties.
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

# [User Input Required] Setup the parameters for Set-ProvScheme
$provisioningSchemeName = "demo-provScheme"

# [User Input Required] Setup the parameters for Set-BrokerCatalog
$description = "This is a new description"

##########################################
# Step 1: Change the Catalog Description #
##########################################
# Update the description of the Catalog
Set-BrokerCatalog -Name $provisioningSchemeName -Description $description