<#
.SYNOPSIS
    Sets or changes the BackupVmConfiguration Custom Property on an existing MCS catalog.
	The updated BackupVmConfiguration property will be applicable to new machines post operation, not to the existing machines. For applying to existing machines, run Set-ProvVmUpdateTimeWindow.
	Applicable for Citrix DaaS and on-prem.
.DESCRIPTION
    Set-BackupVmConfiguration.ps1 helps change the BackupVmConfiguration configuration on an existing MCS catalog.
    In this example, the BackupVmConfiguration custom property on the ProvScheme is updated to a new list.

#>

# /*************************************************************************
# * Copyright © 2024. Cloud Software Group, Inc. All Rights Reserved.
# * This file is subject to the license terms contained
# * in the license file that is distributed with this file.
# *************************************************************************/

# Add Citrix snap-ins
Add-PSSnapin -Name "Citrix.Host.Admin.V2","Citrix.MachineCreation.Admin.V2"

# [User Input Required] Set parameters for Set-ProvScheme
$provisioningSchemeName = "demo-provScheme"

# Update the CustomProperties to include the new value for BackupVmConfiguration consisting of ServiceOfferings with a mix of Spot and Regular priorities
$customProperties = @"
<CustomProperties xmlns="http://schemas.citrix.com/2014/xd/machinecreation" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">
<Property xsi:type=`"StringProperty`" Name=`"BackupVmConfiguration`" Value=`"[{'ServiceOffering': 'Standard_D4a_v4', 'Type': 'Spot'}, {'ServiceOffering': 'Standard_D8a_v4', 'Type': 'Regular'}]`"/>
</CustomProperties>
"@

# Modify the ProvisioningScheme
Set-ProvScheme -ProvisioningSchemeName $provisioningSchemeName -CustomProperties $customProperties

# Schedules all existing VMs to be updated with the new configuration on the next power on
Set-ProvVmUpdateTimeWindow -ProvisioningSchemeName $provisioningSchemeName