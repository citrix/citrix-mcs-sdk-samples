<#
.SYNOPSIS
    Sets or changes the network mapping on an existing MCS catalog.
	The updated network mapping will be applicable to new machines post operation, not to the existing machines.
	For applying to existing machines, run Set-ProvVmUpdateTimeWindow.
	Applicable for Citrix DaaS and on-prem.
.DESCRIPTION
    Update-NetworkMapping helps change the network mapping on an existing MCS catalog.
    The original version of this script is compatible with Citrix Virtual Apps and Desktops 7 2402 Long Term Service Release (LTSR).
#>

# /*************************************************************************
# * Copyright © 2024. Cloud Software Group, Inc. All Rights Reserved.
# * This file is subject to the license terms contained
# * in the license file that is distributed with this file.
# *************************************************************************/

# Add Citrix snap-ins
Add-PSSnapin -Name "Citrix.Host.Admin.V2","Citrix.MachineCreation.Admin.V2"

# [User Input Required]
$provisioningSchemeName = "demo-provScheme"
$hostingUnitName = "demo-hostingUnit"
$resourceGroupName = "demo-resourceGroup"
$region = "East US"
$vNet = "MyVnet"
$subnet = "subnet1"

$networkMapping = @{"0"="XDHyp:\HostingUnits\$hostingUnitName\$region.region\virtualprivatecloud.folder\$resourceGroupName.resourcegroup\$vNet.virtualprivatecloud\$subnet.network"}

# Modify the Provisioning Scheme
Set-ProvScheme -ProvisioningSchemeName $provisioningSchemeName -NetworkMapping $networkMapping