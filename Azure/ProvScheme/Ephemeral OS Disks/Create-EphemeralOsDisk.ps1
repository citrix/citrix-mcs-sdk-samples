<#
.SYNOPSIS
    Creates a non-persistent MCS catalog with ephemeral OS Disks. Applicable for Citrix DaaS and on-prem.
.DESCRIPTION
    Create-EphemeralOsDisk.ps1 creates a non-persistent MCS catalog, where the provisioned OS Disks will be ephemeral.
    The original version of this script is compatible with Citrix Virtual Apps and Desktops 7 2203 Long Term Service Release (LTSR).
#>

# /*************************************************************************
# * Copyright © 2024. Cloud Software Group, Inc.
# * This file is subject to the license terms contained
# * in the license file that is distributed with this file.
# *************************************************************************/

# Add Citrix snap-ins
Add-PSSnapin -Name "Citrix.Host.Admin.V2","Citrix.MachineCreation.Admin.V2"

#------------------------------------------------- Create a ProvisioningScheme -----------------------------------------------------#
# [User Input Required] Set parameters for New-ProvScheme
$isCleanOnBoot = $true
$provisioningSchemeName = "demo-provScheme"
$identityPoolName = $provisioningSchemeName
$hostingUnitName = "demo-hostingUnit"
$resourceGroupName = "demo-resourceGroup"
$masterImage = "demo-snapshot.snapshot"
$region = "East US"
$vNet = "MyVnet"
$subnet = "subnet1"
$machineProfile = "demo-machineProfile.vm"

$masterImagePath = "XDHyp:\HostingUnits\$hostingUnitName\image.folder\$resourceGroupName.resourcegroup\$masterImage"
$networkMapping = @{"0"="XDHyp:\HostingUnits\$hostingUnitName\$region.region\virtualprivatecloud.folder\$resourceGroupName.resourcegroup\$vNet.virtualprivatecloud\$subnet.network"}
$machineProfilePath = "XDHyp:\HostingUnits\$hostingUnitName\machineprofile.folder\$resourceGroupName.resourcegroup\$machineProfile"
$numberOfVms = 1

# Set the UseEphemeralOsDisk custom property.
# This feature has two prerequisites that must be set in the custom properties:
#     1. UseManagedDisks must be true. Ephemeral OS Disks are not supported with unmanaged disks/vhds
#     2. UseSharedImageGallery must be true. Ephemeral OsDisks are only supported when the mastered image is stored in an Azure Compute Gallery (ACG). An ACG is also known as a Shared Image Gallery (SIG)
$customProperties = @"
<CustomProperties xmlns="http://schemas.citrix.com/2014/xd/machinecreation" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">
<Property xsi:type="StringProperty" Name="UseManagedDisks" Value="true"/>
<Property xsi:type="StringProperty" Name="UseSharedImageGallery" Value="true"/>
<Property xsi:type="StringProperty" Name="UseEphemeralOsDisk" Value="true"/>
</CustomProperties>
"@

# For this example, we specify a specific Service Offering that supports Ephemeral OsDisks
$serviceOffering = "XDHyp:\HostingUnits\$hostingUnitName\serviceoffering.folder\Standard_D8s_v3.serviceoffering"

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
