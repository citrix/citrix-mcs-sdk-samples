﻿<#
.SYNOPSIS
    Creates an MCS catalog and provisions VMs into an existing, customer-supplied resource group. Applicable for Citrix DaaS and on-prem.
.DESCRIPTION
    Create-UseExistingResourceGroup creates an MCS catalog and provisionings VMs into an existing resource group.
    VMs and their resources (disks, NICs, etc) will be provisioned into the resource group specified by the ResourceGroups custom property.
    The original version of this script is compatible with Citrix Virtual Apps and Desktops 7 2203 Long Term Service Release (LTSR).
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
$existingResourceGroupName = "my-resource-group"
$machineProfileResourceGroupName = "demo-machineProfileResourceGroupName"
$networkMappingResourceGroupName = "demo-networkMappingResourceGroupName"
$masterImageResourceGroupName = "demo-masterImageResourceGroupName"
$masterImage = "demo-snapshot.snapshot"
$region = "East US"
$vNet = "MyVnet"
$subnet = "subnet1"
$machineProfile = "demo-machineProfile.vm"
$numberOfVms = 1

# Set machineProfilePath, masterImagePath and networkMapping parameters
$masterImagePath = "XDHyp:\HostingUnits\$hostingUnitName\image.folder\$masterImageResourceGroupName.resourcegroup\$masterImage"
$networkMapping = @{"0"="XDHyp:\HostingUnits\$hostingUnitName\$region.region\virtualprivatecloud.folder\$networkMappingResourceGroupName.resourcegroup\$vNet.virtualprivatecloud\$subnet.network"}
$machineProfilePath = "XDHyp:\HostingUnits\$hostingUnitName\machineprofile.folder\$machineProfileResourceGroupName.resourcegroup\$machineProfile"

# Set the ResourceGroups custom property.
# In this example, the resources will be provisioned into $resourceGroupName
$customProperties = @"
<CustomProperties xmlns="http://schemas.citrix.com/2014/xd/machinecreation" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">
<Property xsi:type="StringProperty" Name="ResourceGroups" Value="$existingResourceGroupName" />
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