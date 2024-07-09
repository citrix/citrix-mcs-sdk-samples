<#
.SYNOPSIS
    Sets or changes the security group on an existing MCS catalog.
	The updated security group will be applicable to new machines post operation, not to the existing machines.
	For applying to existing machines, run Set-ProvVmUpdateTimeWindow.
	Applicable for Citrix DaaS and on-prem.
.DESCRIPTION
    Update-SecurityGroup helps change the security group on an existing MCS catalog.
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
$securityGroupName = "demo-sg"
$securityGroup = "XDHyp:\HostingUnits\$hostingUnitName\securitygroup.folder\$resourceGroupName.resourcegroup\$securityGroupName.securitygroup"

# Modify the Provisioning Scheme
Set-ProvScheme -ProvisioningSchemeName $provisioningSchemeName -SecurityGroup $securityGroup