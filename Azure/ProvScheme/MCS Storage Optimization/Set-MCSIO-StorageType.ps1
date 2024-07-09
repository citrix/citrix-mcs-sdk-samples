<#
.SYNOPSIS
    Sets or changes the WBCDiskStorageType Custom Property on an existing MCS catalog.
	The updated WBCDiskStorageType property will be applicable to new machines post operation, not to the existing machines. For applying to existing machines, run Set-ProvVmUpdateTimeWindow.
	Applicable for Citrix DaaS and on-prem.
.DESCRIPTION
    Set-MCSIO-StorageType.ps1 helps change the StorageType of write back cache disk on an existing MCS catalog.
    In this example, the WBCDiskStorageType custom property on the ProvScheme is updated to 'StandardSSD_LRS.'
    The original version of this script is compatible with Citrix Virtual Apps and Desktops 7 2203 Long Term Service Release (LTSR).
#>

# /*************************************************************************
# * Copyright © 2024. Cloud Software Group, Inc. All Rights Reserved.
# * This file is subject to the license terms contained
# * in the license file that is distributed with this file.
# *************************************************************************/

# Add Citrix snap-ins
Add-PSSnapin -Name "Citrix.MachineCreation.Admin.V2"

# [User Input Required] Set parameters for New-ProvScheme
$provisioningSchemeName = "demo-provScheme"

# Update the CustomProperties to include the new value for WBCDiskStorageType
$customProperties = @"
<CustomProperties xmlns="http://schemas.citrix.com/2014/xd/machinecreation" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">
<Property xsi:type="StringProperty" Name="WBCDiskStorageType" Value="StandardSSD_LRS" />
</CustomProperties>
"@

# Modify the Provisioning Scheme
Set-ProvScheme -ProvisioningSchemeName $provisioningSchemeName -CustomProperties $customProperties

# Schedules all existing VMs to be updated with the new configuration on the next power on
Set-ProvVmUpdateTimeWindow -ProvisioningSchemeName $provisioningSchemeName