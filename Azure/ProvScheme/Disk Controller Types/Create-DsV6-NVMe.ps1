<#
.SYNOPSIS
    Creates an MCS catalog using a Dsv6 VM size (NVMe-only) with a template spec machine profile. The template spec
    Disk Controller Type is set to NVMe. Result: VMs are provisioned with NVMe storage. Applicable for Citrix DaaS and on-prem.
.DESCRIPTION
    Create-DsV6-NVMe.ps1 demonstrates creating an MCS catalog where the service offering is from the
    Dsv6 series (NVMe-only — Azure v6 and later VM generations support NVMe exclusively) and the machine profile is
    a template spec whose VM resource has storageProfile.diskControllerType explicitly set to NVMe.

    The original version of this script is compatible with Citrix Virtual Apps and Desktops 7 2503.
#>

# /*************************************************************************
# * Copyright © 2026. Cloud Software Group, Inc. All Rights Reserved.
# * This file is subject to the license terms contained
# * in the license file that is distributed with this file.
# *************************************************************************/

# Add Citrix snap-ins
Add-PSSnapin -Name "Citrix.Host.Admin.V2","Citrix.MachineCreation.Admin.V2"

#------------------------------------------------- Create a ProvisioningScheme -----------------------------------------------------#
# [User Input Required] Set parameters for New-ProvScheme
$isCleanOnBoot                       = $false
$provisioningSchemeName              = "demo-provScheme"
$identityPoolName                    = $provisioningSchemeName
$hostingUnitName                     = "demo-hostingUnit"
$numberOfVms                         = 1
$region                              = "East US"

# [User Input Required] Master image — must support NVMe (SupportedDiskControllerTypes includes NVMe)
$masterImageResourceGroupName        = "demo-masterImageResourceGroupName"
$masterImageSnapshotName             = "demo-snapshot.snapshot"

# [User Input Required] Service offering — Dsv6 series is NVMe-only (Azure v6 and later support NVMe exclusively)
# Example sizes: Standard_D2ds_v6, Standard_D4ds_v6, Standard_D8ds_v6
$newMachineSize                      = "Standard_D2ds_v6"

# [User Input Required] Network mapping
$networkMappingResourceGroupName     = "demo-networkMappingResourceGroupName"
$networkName                         = "demo-network"
$subnetName                          = "default"

# [User Input Required] Machine profile
# The machine profile template spec has storageProfile.diskControllerType set to "NVMe" in its VM resource.
# Note: If the machine profile OS disk has diskControllerTypes set, it must match the master image's SupportedDiskControllerTypes.
# Result: NVMe
$machineProfileResourceGroupName     = "demo-machineProfileResourceGroupName"
$templateSpecName                    = "demo-templateSpec"
$templateSpecVersionName             = "demo-templateSpecVersion"  # This template spec has storageProfile.diskControllerType = NVMe

# Set masterImagePath, serviceOffering, networkMapping and machineProfile parameters
$masterImagePath    = "XDHyp:\HostingUnits\$hostingUnitName\image.folder\$masterImageResourceGroupName.resourcegroup\$masterImageSnapshotName"
$serviceOffering    = "XDHyp:\HostingUnits\$hostingUnitName\serviceoffering.folder\$newMachineSize.serviceoffering"
$networkMapping     = @{"0"="XDHyp:\HostingUnits\$hostingUnitName\$region.region\virtualprivatecloud.folder\$networkMappingResourceGroupName.resourcegroup\$networkName.virtualprivatecloud\$subnetName.network"}
$machineProfile     = "XDHyp:\HostingUnits\$hostingUnitName\machineprofile.folder\$machineProfileResourceGroupName.resourcegroup\$templateSpecName.templateSpec\$templateSpecVersionName.templatespecversion"

# Create the ProvisioningScheme
New-ProvScheme -CleanOnBoot:$isCleanOnBoot `
-ProvisioningSchemeName $provisioningSchemeName `
-HostingUnitName $hostingUnitName `
-IdentityPoolName $identityPoolName `
-InitialBatchSizeHint $numberOfVms `
-MasterImageVM $masterImagePath `
-NetworkMapping $networkMapping `
-ServiceOffering $serviceOffering `
-MachineProfile $machineProfile
