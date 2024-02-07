<#
.SYNOPSIS
    Sets or changes the MachineProfile parameter on an existing MCS catalog. The updated machine profile will be applicable to new machines post operation, not to the existing machines. Applicable for Citrix DaaS and on-prem.
.DESCRIPTION
    Set-MachineProfile-ProvScheme.ps1 helps change the MachineProfile configuration on an existing MCS catalog.
    In this example, the MachineProfile parameter is updated on the ProvScheme.
    The original version of this script is compatible with Citrix Virtual Apps and Desktops 7 2402 Long Term Service Release (LTSR).
#>

# /*************************************************************************
# * Copyright © 2024. Cloud Software Group, Inc.
# * This file is subject to the license terms contained
# * in the license file that is distributed with this file.
# *************************************************************************/

##########################
# Step 0: Set parameters #
##########################
# Add Citrix snap-ins
Add-PSSnapin -Name "Citrix.Host.Admin.V2","Citrix.MachineCreation.Admin.V2"

# [User Input Required] Setup the parameters for Set-ProvScheme
$updatedMachineProfileVmName= "demo-update-machineprofile"
$hostingUnitName = "demo-hostingunit"
$updatedMachineProfile= "XDHyp:\HostingUnits\$hostingUnitName\$updatedMachineProfileVmName.vm"
$provisioningSchemeName = "demo-provScheme"

#####################################################
# Step 1: Change the Provisioning Scheme Properties #
#####################################################

Set-ProvScheme -ProvisioningSchemeName $provisioningSchemeName -MachineProfile $updatedMachineProfile