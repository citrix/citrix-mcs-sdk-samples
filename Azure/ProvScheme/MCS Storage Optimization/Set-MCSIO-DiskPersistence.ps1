<#
.SYNOPSIS
    Sets or changes the PersistWBC Custom Property on an existing MCS catalog.
	The updated PersistWBC property will be applicable to new machines post operation, not to the existing machines. For applying to existing machines, run Set-ProvVmUpdateTimeWindow.
	Applicable for Citrix DaaS and on-prem.
.DESCRIPTION
    Set-MCSIO-DiskPersistence.ps1 helps change the persistence of write back cache disk on an existing MCS catalog.
	This property only applies to a provisioning scheme with UseWriteBackCache enabled.
	If this property is not specified, the write back cache disk is deleted when the virtual machine is shut down, and is re-created when the virtual machine is powered on.
    In this example, the PersistWBC custom property on the ProvScheme is updated to 'True'
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

# Update the CustomProperties to persist the write back cache disk. Specify either True or False.
$customProperties = @"
<CustomProperties xmlns="http://schemas.citrix.com/2014/xd/machinecreation" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">
<Property xsi:type="StringProperty" Name="PersistWBC" Value="True" />
</CustomProperties>
"@

# Modify the Provisioning Scheme
Set-ProvScheme -ProvisioningSchemeName $provisioningSchemeName -CustomProperties $customProperties

# Schedules all existing VMs to be updated with the new configuration on the next power on
Set-ProvVmUpdateTimeWindow -ProvisioningSchemeName $provisioningSchemeName