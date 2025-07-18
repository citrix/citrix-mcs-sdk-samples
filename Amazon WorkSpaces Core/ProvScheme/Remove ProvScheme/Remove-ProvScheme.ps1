﻿<#
.SYNOPSIS
    Remove a provisioning Scheme. Applicable for Citrix DaaS and on-prem.
.DESCRIPTION
    Remove-ProvScheme.ps1 emulates the behavior of the Remove-ProvScheme command.
    It removes all remaining catalog level resources (such as basedisk, citrix povisioned resource group) from hypervisor,
	and also the internal data related to the provisioning scheme from the Citrix site database.
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

# [User Input Required] Setup the parameters for Remove-BrokerCatalog and Remove-ProvScheme
$provisioningSchemeName = "demo-provScheme"

##############################
# Step 1: Remove the Catalog #
##############################
Remove-BrokerCatalog -Name $provisioningSchemeName

##########################################
# Step 2: Remove the Provisioning Scheme #
##########################################
Remove-ProvScheme -ProvisioningSchemeName $provisioningSchemeName