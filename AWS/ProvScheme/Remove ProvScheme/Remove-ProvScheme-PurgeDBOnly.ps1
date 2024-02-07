<#
.SYNOPSIS
    Remove a provisioning Scheme. Applicable for Citrix DaaS and on-prem.
.DESCRIPTION
    Remove-ProvScheme-PurgeDBOnly.ps1 only removes the provisioning Scheme from the Citrix site database.
	Catalog VMs and related resources created still remain in the hypervisor.
    The original version of this script is compatible with Citrix Virtual Apps and Desktops 7 2402 Long Term Service Release (LTSR).
#>

# /*************************************************************************
# * Copyright © 2024. Cloud Software Group, Inc.
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
Remove-ProvScheme -ProvisioningSchemeName $provisioningSchemeName -PurgeDBOnly