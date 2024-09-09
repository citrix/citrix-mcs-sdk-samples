<#
.SYNOPSIS
    Creates an MCS catalog using a Template Spec as the MachineProfile source. Applicable for Citrix DaaS and on-prem.
.DESCRIPTION
    Create-MachineProfile-TemplateSpecSource creates an MCS ProvisioningScheme using a Template Spec as the MachineProfile source.
    VMs created from this provisioning scheme will be based on the provided template spec.
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
$machineProfileResourceGroupName = "demo-machineProfileResourceGroupName"
$networkMappingResourceGroupName = "demo-networkMappingResourceGroupName"
$masterImageResourceGroupName = "demo-masterImageResourceGroupName"
$masterImageSnapshotName = "demo-snapshot.snapshot"
$region = "East US"
$networkName = "demo-network"
$subnetName = "default"
$numberOfVms = 1
$templateSpecName = "demo-templateSpec"
$templateSpecVersion = "demo-templateSpecVersion"

# Set machineProfilePath, masterImagePath and networkMapping parameters
$machineProfilePath = "XDHyp:\HostingUnits\$hostingUnitName\machineprofile.folder\$machineProfileResourceGroupName.resourcegroup\$templateSpecName.templatespec\$templateSpecVersion.templatespecversion"
$masterImagePath = "XDHyp:\HostingUnits\$hostingUnitName\image.folder\$masterImageResourceGroupName.resourcegroup\$masterImageSnapshotName"
$networkMapping = @{"0"="XDHyp:\HostingUnits\$hostingUnitName\$region.region\virtualprivatecloud.folder\$networkMappingResourceGroupName.resourcegroup\$networkName.virtualprivatecloud\$subnetName.network"}

$customProperties = @"
<CustomProperties xmlns="http://schemas.citrix.com/2014/xd/machinecreation" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">
<Property xsi:type="StringProperty" Name="UseManagedDisks" Value="true"/>
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
-MachineProfile $machineProfilePath                   # The -MachineProfile parameter must be specified