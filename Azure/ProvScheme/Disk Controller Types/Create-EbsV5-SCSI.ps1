<#
.SYNOPSIS
    Creates an MCS catalog using an Ebsv5 VM size with a template spec machine profile. The template spec
    Disk Controller Type is set to SCSI. Result: VMs are provisioned with SCSI storage. Applicable for Citrix DaaS and on-prem.
.DESCRIPTION
    Create-EbsV5-SCSI.ps1 demonstrates creating an MCS catalog where the service offering is from the
    Ebsv5 series (supports both SCSI and NVMe) and the machine profile is a template spec whose VM resource has
    storageProfile.diskControllerType explicitly set to SCSI. Because SCSI is explicitly specified, provisioned VMs use SCSI storage.

    For VM sizes that support both SCSI and NVMe, the machine profile VM DiskControllerType determines the result.
    Omitting the field defaults to SCSI; setting it to SCSI also produces SCSI; setting it to NVMe produces NVMe.

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

# [User Input Required] Service offering — Ebsv5 series supports both SCSI and NVMe disk controller types
# Example sizes: Standard_E2bs_v5, Standard_E4bs_v5, Standard_E8bs_v5
$newMachineSize                      = "Standard_E2bs_v5"

# [User Input Required] Network mapping
$networkMappingResourceGroupName     = "demo-networkMappingResourceGroupName"
$networkName                         = "demo-network"
$subnetName                          = "default"

# [User Input Required] Machine profile
# The machine profile template spec must have storageProfile.diskControllerType set to "SCSI" in its VM resource.
# Because the Ebsv5 size supports both SCSI and NVMe, the machine profile Disk Controller Type determines which is used.
# Note: If the machine profile OS disk has diskControllerTypes set, it must match the master image's SupportedDiskControllerTypes.
# Result: SCSI
$machineProfileResourceGroupName     = "demo-machineProfileResourceGroupName"
$templateSpecName                    = "demo-templateSpec"
$templateSpecVersionName             = "demo-templateSpecVersion"  # This template spec has storageProfile.diskControllerType = SCSI

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
