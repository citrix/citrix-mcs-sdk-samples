﻿<#
.SYNOPSIS
    Sets or changes the service offering on an existing MCS catalog.
    The updated service offering will be applicable to new machines post operation, not to the existing machines.
    Applicable for Citrix DaaS and on-prem.
.DESCRIPTION
    Update-ServiceOffering helps sets or changes the an existing MCS catalog's properties.
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
$hostingUnitName = "demo-hostingunit"
$serviceOffering = "XDHyp:\HostingUnits\$hostingUnitName\T3 Medium Instance.serviceoffering"

#####################################################
# Step 1: Change the Provisioning Scheme properties #
#####################################################
# Change the provisioining scheme properties
Set-ProvScheme -ProvisioningSchemeName $provisioningSchemeName -ServiceOffering $serviceOffering