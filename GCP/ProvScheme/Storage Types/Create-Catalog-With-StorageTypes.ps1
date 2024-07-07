<#
.SYNOPSIS
    Creates an MCS catalog using the storage type custom properties. Applicable for Citrix DaaS and on-prem.
.DESCRIPTION
    This script creates an MCS ProvisioningScheme using the StorageType, IdentityDiskStorageType and WbcDiskStorageType custom properties.
    In this example, the StorageType custom property is set to 'pd-standard', IdentityDiskStorageType is set to 'pd-balanced'. The provisioned os disk will use storage type 'pd-standard' and identity disk will use storage type 'pd-balanced'.
	Similarly, the Wbc disk storage type can be specified using the WbcDiskStorageType custom property(not used in this example).
    The original version of this script is compatible with Citrix Virtual Apps and Desktops 7 2203 Long Term Service Release (LTSR).
#>

# /*************************************************************************
# * Copyright © 2024. Cloud Software Group, Inc. All Rights Reserved.
# * This file is subject to the license terms contained
# * in the license file that is distributed with this file.
# *************************************************************************/

# Add Citrix snap-ins
Add-PSSnapin -Name "Citrix.Host.Admin.V2","Citrix.MachineCreation.Admin.V2"

# [User Input Required] Set parameters for New-ProvScheme
$isCleanOnBoot = $false
$provisioningSchemeName = "demo-provScheme"
$identityPoolName = $provisioningSchemeName
$hostingUnitName = "GcpHostingUnitName"
$masterImageVmName = "antz-vda2303-n1std1"
$masterImageSnapshotName = "vda-snap-10-21-2023"
$vpcName = "vpc-name"
$subnetName = "subnet-name"
$numberOfVms = 1
$OsDiskStorageType = "pd-standard"
$IdDiskStorageType = "pd-balanced"

# [User Input Required] Set parameters for New-BrokerCatalog
$AllocationType = "Random"
$Description = "Sample description for catalog"
$PersistUserChanges = "Discard"
$SessionSupport = "MultiSession"

# Set paths for master image and network mapping
$masterImageVm = "XDHyp:\HostingUnits\$hostingUnitName\$masterImageVmName.vm\$masterImageSnapshotName.snapshot"
$networkMapping = @{"0"="XDHyp:\HostingUnits\$hostingUnitName\$vpcName.virtualprivatecloud\$subnetName.network"}

# Set the custom properties
$CustomProperties = '<CustomProperties xmlns="http://schemas.citrix.com/2014/xd/machinecreation" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">' `
					+ '<Property xsi:type="StringProperty" Name="StorageType" Value="' + $OsDiskStorageType +'"/>' `
					+ '<Property xsi:type="StringProperty" Name="IdentityDiskStorageType" Value="' + $IdDiskStorageType +'"/>' `
					+ '</CustomProperties>'

# Create the ProvisioningScheme
$createdProvScheme = New-ProvScheme -CleanOnBoot:$isCleanOnBoot `
    -ProvisioningSchemeName $provisioningSchemeName `
    -HostingUnitName $hostingUnitName `
    -IdentityPoolName $identityPoolName `
    -InitialBatchSizeHint $numberOfVms `
    -MasterImageVM $masterImageVm `
    -NetworkMapping $networkMapping `
    -CustomProperties $customProperties

# Create a Broker catalog. This allows you to see and manage the catalog from Studio
New-BrokerCatalog -Name $ProvisioningSchemeName `
    -ProvisioningSchemeId $createdProvScheme.ProvisioningSchemeUid `
    -AllocationType $AllocationType `
    -Description $Description `
    -IsRemotePC $False `
    -PersistUserChanges $PersistUserChanges `
    -ProvisioningType "MCS" `
    -Scope @() `
    -SessionSupport $SessionSupport
