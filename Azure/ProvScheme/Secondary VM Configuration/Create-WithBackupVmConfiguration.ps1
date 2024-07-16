<#
.SYNOPSIS
    Creates an MCS catalog using the BackupVmConfiguration custom property. Applicable for Citrix DaaS and on-prem.
.DESCRIPTION
    Create-BackupVmConfiguration creates an MCS ProvisioningScheme using the BackupVmConfiguration custom property.
    In this example, the BackupVmConfiguration custom property is set to a list of service offerings
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
$machineSize = "Standard_D2a_v4"

$serviceOffering = "XDHyp:\HostingUnits\$hostingUnitName\ServiceOffering.folder\$machineSize.serviceoffering"
$masterImagePath = "XDHyp:\HostingUnits\$hostingUnitName\image.folder\$resourceGroupName.resourcegroup\$masterImage"
$networkMapping = @{"0"="XDHyp:\HostingUnits\$hostingUnitName\$region.region\virtualprivatecloud.folder\$resourceGroupName.resourcegroup\$networkName.virtualprivatecloud\$subnetName.network"}
$machineProfilePath = "XDHyp:\HostingUnits\$hostingUnitName\machineprofile.folder\$resourceGroupName.resourcegroup\$machineProfile"

# Set the BackupVmConfiguration custom property.
$customProperties = @"
<CustomProperties xmlns="http://schemas.citrix.com/2014/xd/machinecreation" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">
<Property xsi:type=`"StringProperty`" Name=`"BackupVmConfiguration`" Value=`"[{'ServiceOffering': 'Standard_D4a_v4', 'Type': 'Spot'}, {'ServiceOffering': 'Standard_D8a_v4', 'Type': 'Regular'}]`"/>
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
-MachineProfile $machineProfilePath `
-ServiceOffering $serviceOffering