<#
.SYNOPSIS
    Sets or changes the MachineProfile parameter on an existing MCS catalog. The updated machine profile will be applicable to new machines post operation, not to the existing machines. Applicable for Citrix DaaS and on-prem.
.DESCRIPTION
    Set-ProvScheme-MachineProfile.ps1 helps change the MachineProfile configuration on an existing MCS catalog.
    In this example, the MachineProfile parameter is updated on the ProvScheme.
    The original version of this script is compatible with Citrix Virtual Apps and Desktops 7 2305.
.INPUTS
    1. ProvisioningSchemeName: Name of the provisioning scheme to be updated.
    2. MachineProfile: The path to the new machine profile template.
.OUTPUTS
    N/A
.NOTES
    Version      : 1.0.0
    Author       : Citrix Systems, Inc.
.EXAMPLE
    .\Set-ProvScheme-MachineProfile.ps1 `
        -ProvisioningSchemeName "MyCatalog" `
        -MachineProfile "XDHyp:\HostingUnits\MyHostingUnit\MyTemplate.template" `  
#>

# /*************************************************************************
# * Copyright © 2024. Cloud Software Group, Inc. All Rights Reserved.
# * This file is subject to the license terms contained
# * in the license file that is distributed with this file.
# *************************************************************************/

##########################
# Step 0: Set parameters #
##########################
param(
    [string] $ProvisioningSchemeName,
    [string] $MachineProfile
)

# Enable Citrix PowerShell Cmdlets
Add-PSSnapin citrix*

#########################################################
# Step 1: Change the Provisioning Scheme MachineProfile #
#########################################################

Set-ProvScheme -ProvisioningSchemeName $ProvisioningSchemeName -MachineProfile $MachineProfile