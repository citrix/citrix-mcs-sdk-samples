<#
.SYNOPSIS
    Creates an MCS catalog in an Azure Extended Zone. Applicable for Citrix DaaS and on-prem.
.DESCRIPTION
    Create-ExtendedZone.ps1 creates an MCS catalog and provisions VMs into an Azure Extended Zone.
    The key difference when creating a ProvScheme for an Extended Zone is in the network mapping path,
    which must reference ".extendedzone" instead of ".region".
    The original version of this script is compatible with Citrix Virtual Apps and Desktops 7 2603.
#>

# /*************************************************************************
# * Copyright © 2026. Cloud Software Group, Inc. All Rights Reserved.
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
$hostingUnitName = "MyExtendedZoneHostingUnit"
$machineProfileResourceGroupName = "demo-machineProfileResourceGroupName"
$networkMappingResourceGroupName = "demo-networkMappingResourceGroupName"
$masterImageResourceGroupName = "demo-masterImageResourceGroupName"
$masterImage = "demo-snapshot.snapshot"
$extendedZone = "Los Angeles"
$vNet = "MyExtendedZoneVnet"
$subnet = "MyExtendedZoneSubnet"
$machineProfile = "demo-machineProfile.vm"
$numberOfVms = 1

# Set machineProfilepath, masterImagePath and networkMapping parameters
$masterImagePath = "XDHyp:\HostingUnits\$hostingUnitName\image.folder\$masterImageResourceGroupName.resourcegroup\$masterImage"
$machineProfilePath = "XDHyp:\HostingUnits\$hostingUnitName\machineprofile.folder\$machineProfileResourceGroupName.resourcegroup\$machineProfile"
# Key difference: Use ".extendedzone" instead of ".region" in the network path
$networkMapping = @{"0"="XDHyp:\HostingUnits\$hostingUnitName\$extendedZone.extendedzone\virtualprivatecloud.folder\$networkMappingResourceGroupName.resourcegroup\$vNet.virtualprivatecloud\$subnet.network"}

# Create the ProvisioningScheme
New-ProvScheme -CleanOnBoot:$isCleanOnBoot `
-ProvisioningSchemeName $provisioningSchemeName `
-HostingUnitName $hostingUnitName `
-IdentityPoolName $identityPoolName `
-InitialBatchSizeHint $numberOfVms `
-MasterImageVM $masterImagePath `
-NetworkMapping $networkMapping `
-MachineProfile $machineProfilePath