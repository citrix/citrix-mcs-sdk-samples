<#
.SYNOPSIS
    Sets or changes Availability Zones on an existing MCS catalog.
	The updated availability zones will be applicable to new machines post operation, not to the existing machines. It is not yet supported on existing machines.
	Applicable for Citrix DaaS and on-prem.
.DESCRIPTION
    Set-AvailabilityZones.ps1 helps change Availability Zone configuration on an existing MCS catalog.
    VMs and their resources (disks, NICs) will be provisioned into the new availability zone settings specified by the Zones custom property.
    The original version of this script is compatible with Citrix Virtual Apps and Desktops 7 2402 Long Term Service Release (LTSR).
#>

# /*************************************************************************
# * Copyright © 2024. Cloud Software Group, Inc. All Rights Reserved.
# * This file is subject to the license terms contained
# * in the license file that is distributed with this file.
# *************************************************************************/

# Add Citrix snap-ins
Add-PSSnapin -Name "Citrix.Host.Admin.V2","Citrix.MachineCreation.Admin.V2"

#------------------------------------------------- Set parameters for an existing ProvisioningScheme -----------------------------------------------------#
# [User Input Required] Set parameters for Set-ProvScheme
$provisioningSchemeName = "demo-provScheme"

# Set the Zones custom property.
# You are allowed to specify more than one availability zone in a comma separated format. In this case, MCS will internally pick an availability zone for the resources.
# If only one zone is specified, the resources will be provisioned in that zone.
# In this example, VMs and their resources (disks, NICs) will be provisioned into one of the three Availability Zones in the region selected in the Hosting Unit. (e.g. East US (Zone3))
$customProperties = @"
<CustomProperties xmlns="http://schemas.citrix.com/2014/xd/machinecreation" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">
<Property xsi:type="StringProperty" Name="Zones" Value="1,2,3"/>
</CustomProperties>
"@

# Modify the ProvisioningScheme
Set-ProvScheme `
-ProvisioningSchemeName $provisioningSchemeName `
-CustomProperties $customProperties