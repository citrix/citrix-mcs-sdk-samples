<#
.SYNOPSIS
    Sets or changes storage types of an existing MCS catalog.
	The updated zone(s) will be applicable to new machines post-operation, not to the existing machines. For updating storage types of existing machines, run Set-ProvVmUpdateTimeWindow and restart the machines.
	Applicable for Citrix DaaS and on-prem.
.DESCRIPTION
    This script changes the storage type configuration on an existing MCS catalog.
    In this example, os disk storage type is updated to pd-ssd and identity disk storage type is updated to pd-standard via custom properties StorageType and IdentityDiskStorageType respectively.
	Similarly, Wbc disk storage type can be changed via WBCDiskStorageType custom property (Not shown in this example).
    The original version of this script is compatible with Citrix Virtual Apps and Desktops 7 2402 Long Term Service Release (LTSR).
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
$OsDiskStorageType = "pd-ssd"
$IdDiskStorageType = "pd-standard"

# Set the custom properties
$CustomProperties = '<CustomProperties xmlns="http://schemas.citrix.com/2014/xd/machinecreation" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">' `
					+ '<Property xsi:type="StringProperty" Name="StorageType" Value="' + $OsDiskStorageType +'"/>' `
					+ '<Property xsi:type="StringProperty" Name="IdentityDiskStorageType" Value="' + $IdDiskStorageType +'"/>' `
					+ '</CustomProperties>'


# Modify the ProvisioningScheme
Set-ProvScheme `
-ProvisioningSchemeName $provisioningSchemeName `
-CustomProperties $customProperties