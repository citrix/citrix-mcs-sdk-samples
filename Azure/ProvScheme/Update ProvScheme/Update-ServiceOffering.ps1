<#
.SYNOPSIS
    Sets or changes the service offering (machine size) on an existing MCS catalog.
	The updated machine size will be applicable to new machines post operation, not to the existing machines.
	For applying to existing machines, run Set-ProvVmUpdateTimeWindow.
	Applicable for Citrix DaaS and on-prem.
.DESCRIPTION
    Update-ServiceOffering helps change the ServiceOffering configuration on an existing MCS catalog.
    In this example, the ServiceOffering parameter is updated on the ProvScheme.
    The original version of this script is compatible with Citrix Virtual Apps and Desktops 7 2203 Long Term Service Release (LTSR).
#>

# /*************************************************************************
# * Copyright © 2024. Cloud Software Group, Inc.
# * This file is subject to the license terms contained
# * in the license file that is distributed with this file.
# *************************************************************************/

# Add Citrix snap-ins
Add-PSSnapin -Name "Citrix.Host.Admin.V2","Citrix.MachineCreation.Admin.V2"

# [User Input Required]
$provisioningSchemeName = "demo-provScheme"
$hostingUnitName = "demo-hostingUnit"
$newMachineSize = "Standard_D2s_v5"
$updatedServiceOffering = "XDHyp:\HostingUnits\$hostingUnitName\ServiceOffering.folder\$newMachineSize.serviceoffering"

# Modify the Provisioning Scheme
Set-ProvScheme -ProvisioningSchemeName $provisioningSchemeName -ServiceOffering $updatedServiceOffering