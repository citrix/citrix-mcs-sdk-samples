<#
.SYNOPSIS
    Creates a PVS provisioning scheme and a broker catalog.
.DESCRIPTION
    Create-PvsProvScheme.ps1 creates an PVS Provisioning Scheme.
    The original version of this script is compatible with Citrix Virtual Apps and Desktops 7 2402 Long Term Service Release (LTSR) or later.
#>

# /*************************************************************************
# * Copyright © 2025. Cloud Software Group, Inc. All Rights Reserved.
# * This file is subject to the license terms contained
# * in the license file that is distributed with this file.
# *************************************************************************/

# Add Citrix snap-ins
Add-PSSnapin -Name "Citrix.Host.Admin.V2","Citrix.MachineCreation.Admin.V2","Citrix.Broker.Admin.V2"

#------------------------------------------------- Create a ProvisioningScheme -----------------------------------------------------#
# [User Input Required] Set parameters for New-ProvScheme
$isCleanOnBoot = $true
$provisioningSchemeName = "demo-provScheme"
$identityPoolName = $provisioningSchemeName
$hostingUnitName = "demo-hostingUnit"
$masterImageResourceGroupName = "demo-masterImageResourceGroup"
$networkMappingResourceGroupName = "demo-networkMappingResourceGroup"
$region = "East US"
$vNet = "MyVnet"
$subnet = "subnet1"
$numberOfVms = 1
$machineProfileResourceGroupName = "demo-machineProfileResourceGroup"
$machineProfile = "mymachineprofile"
$sampleNamingScheme = "sampleNaming"
$domain = "sampleDomain"
$pvsSite = "samplePvsSiteGuid"
$pvsVDisk = "samplePvsVDiskGuid"
$sampleCustomProperties = "<CustomProperties xmlns=`"http://schemas.citrix.com/2014/xd/machinecreation`" xmlns:xsi=`"http://www.w3.org/2001/XMLSchema-instance`"><Property xsi:type=`"StringProperty`" Name=`"UseManagedDisks`" Value=`"true`" /><Property xsi:type=`"StringProperty`" Name=`"OsType`" Value=`"Windows`" /><Property xsi:type=`"StringProperty`" Name=`"StorageType`" Value=`"StandardSSD_LRS`" /><Property xsi:type=`"StringProperty`" Name=`"PersistWBC`" Value=`"true`" /><Property xsi:type=`"StringProperty`" Name=`"PersistOsDisk`" Value=`"false`" /><Property xsi:type=`"StringProperty`" Name=`"PersistVm`" Value=`"false`" /><Property xsi:type=`"StringProperty`" Name=`"WBCDiskStorageType`" Value=`"Premium_LRS`" /><Property xsi:type=`"StringProperty`" Name=`"UseTempDiskForWBC`" Value=`"false`" /><Property xsi:type=`"StringProperty`" Name=`"LicenseType`" Value=`"Windows_Server`" /><Property xsi:type=`"StringProperty`" Name=`"Zones`" Value=`"`" /></CustomProperties>" 

# [User Input Required] Setup the parameters for New-BrokerCatalog
$allocationType = "Random"
$description = "This is meant to be use as placeholders"
$persistUserChanges = "Discard"
$sessionSupport = "MultiSession"


# Set serviceOffering, masterImagePath and networkMapping parameters
$networkMapping = @{"0"="XDHyp:\HostingUnits\$hostingUnitName\$region.region\virtualprivatecloud.folder\$networkMappingResourceGroupName.resourcegroup\$vNet.virtualprivatecloud\$subnet.network"}
$serviceOffering = "XDHyp:\HostingUnits\$hostingUnitName\serviceoffering.folder\Standard_D2s_v3.serviceoffering"
$sampleMachineProfilePath = "XDHyp:\HostingUnits\$hostingUnitName\machineprofile.folder\$machineProfileResourceGroupName.resourcegroup\$machineProfile.vm"

#Create Identity Pool
New-AcctIdentityPool -IdentityPoolName $provisioningSchemeName $ -NamingScheme "$($sampleNamingScheme)##" -NamingSchemeType Numeric -Domain $domain

# Create the ProvisioningScheme
$createdProvScheme = New-ProvScheme -CleanOnBoot:$isCleanOnBoot `
-ProvisioningSchemeName $provisioningSchemeName `
-ProvisioningSchemeType PVS `
-PVSSite $pvsSite `
-PVSvDisk $pvsVDisk `
-HostingUnitName $hostingUnitName `
-IdentityPoolName $identityPoolName `
-InitialBatchSizeHint $numberOfVms `
-MasterImageVM $masterImagePath `
-NetworkMapping $networkMapping `
-ServiceOffering $serviceOffering `
-CustomProperties $sampleCustomProperties `
-MachineProfile $sampleMachineProfilePath `
-UseWriteBackCache -WriteBackCacheDiskSize 32 -WriteBackCacheDriveLetter "`0" -WriteBackCacheMemorySize 0


# Create the Broker Catalog. This allows you to see the catalog in Studio
New-BrokerCatalog -Name $provisioningSchemeName `
    -ProvisioningSchemeId $createdProvScheme.ProvisioningSchemeUid `
    -AllocationType $allocationType  `
    -Description $description `
    -IsRemotePC $False `
    -PersistUserChanges $persistUserChanges `
    -ProvisioningType "MCS" `
    -Scope @() `
    -SessionSupport $sessionSupport
    