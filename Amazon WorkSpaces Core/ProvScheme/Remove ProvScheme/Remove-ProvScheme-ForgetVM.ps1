<#
.SYNOPSIS
    Remove a provisioning Scheme. Applicable for Citrix DaaS and on-prem.
.DESCRIPTION
    Remove-ProvScheme-ForgetVM.ps1 keeps catalog VMs and related resources (network interface, OsDisk etc.) in the hypervisor
	Tags created by provisioning process and associated with the provisioning scheme will be removed
    It also removes the provisioning Scheme data from the Citrix site database.
    The original version of this script is compatible with Citrix Virtual Apps and Desktops 7 2402 Long Term Service Release (LTSR).
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
Remove-ProvScheme -ProvisioningSchemeName $provisioningSchemeName -ForgetVM