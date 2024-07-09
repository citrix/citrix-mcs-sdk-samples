<#
.SYNOPSIS
    Creates an MCS catalog using the StorageTypeAtShutdown custom property. Applicable for Citrix DaaS and on-prem.
.DESCRIPTION
    Create-StorageTypeAtShutdown creates an MCS ProvisioningScheme using the StorageTypeAtShutdown custom property.
    In this example, the StorageTypeAtShutdown custom property is set to 'Standard_LRS.'
    When the VM is deallocated, the persistent OsDisk uses the Standard_LRS storage tier.
    When the VM is powered on, the persistent OsDisk returns to its base storage tier (in this example, Premium_LRS).
    The original version of this script is compatible with Citrix Virtual Apps and Desktops 7 2402 Long Term Service Release (LTSR).
#>

# /*************************************************************************
# * Copyright © 2024. Cloud Software Group, Inc. All Rights Reserved.
# * This file is subject to the license terms contained
# * in the license file that is distributed with this file.
# *************************************************************************/

# Add Citrix snap-ins
Add-PSSnapin -Name "Citrix.Host.Admin.V2","Citrix.MachineCreation.Admin.V2"

#------------------------------------------------- Create a ProvisioningScheme -----------------------------------------------------#
# [User Input Required] Set parameters for New-ProvScheme
$isCleanOnBoot = $false
$provisioningSchemeName = "demo-provScheme"
$identityPoolName = $provisioningSchemeName
$hostingUnitName = "demo-hostingUnit"
$resourceGroupName = "demo-resourceGroup"
$masterImage = "demo-snapshot.snapshot"
$machineProfile = "demo-machineProfile.vm"
$region = "East US"
$networkName = "demo-network"
$subnetName = "default"
$numberOfVms = 1

$masterImagePath = "XDHyp:\HostingUnits\$hostingUnitName\image.folder\$resourceGroupName.resourcegroup\$masterImage"
$networkMapping = @{"0"="XDHyp:\HostingUnits\$hostingUnitName\$region.region\virtualprivatecloud.folder\$resourceGroupName.resourcegroup\$networkName.virtualprivatecloud\$subnetName.network"}
$machineProfilePath = "XDHyp:\HostingUnits\$hostingUnitName\machineprofile.folder\$resourceGroupName.resourcegroup\$machineProfile"

# Set the StorageTypeAtShutdown custom property.
# The only valid values for StorageTypeAtShutdown are 'Standard_LRS' or ''. Using '' means that you are not using the feature.
# In this example, we also set the StorageType custom property to 'Premium_LRS.' StorageType is the desired StorageType when the VM is powered on.
$customProperties = @"
<CustomProperties xmlns="http://schemas.citrix.com/2014/xd/machinecreation" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">
<Property xsi:type="StringProperty" Name="StorageTypeAtShutdown" Value="Standard_LRS"/>
<Property xsi:type="StringProperty" Name="StorageType" Value="Premium_LRS"/>
</CustomProperties>
"@

# Create the ProvisioningScheme
New-ProvScheme -CleanOnBoot:$isCleanOnBoot `
-ProvisioningSchemeName $provisioningSchemeName `
-HostingUnitName $hostingUnitName `
-IdentityPoolName $identityPoolName `
-InitialBatchSizeHint $numberOfVms `
-MasterImageVM $masterImagePath `
-NetworkMapping $networkMapping `
-CustomProperties $customProperties `
-MachineProfile $machineProfilePath