<#
.SYNOPSIS
    Creates an MCS catalog using a Dsv5 VM size (SCSI only). Result: VMs are provisioned with SCSI storage.
    Applicable for Citrix DaaS and on-prem.
.DESCRIPTION
    Create-DsV5-SCSI.ps1 demonstrates creating an MCS catalog where the service offering is from the
    Dsv5 series (supports SCSI only). VMs provisioned with these sizes always use SCSI storage regardless
    of the machine profile VM DiskControllerType setting.

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

# [User Input Required] Service offering — Dsv5 series supports SCSI only
# Example sizes: Standard_D2ds_v5, Standard_D4ds_v5, Standard_D8ds_v5
$newMachineSize                      = "Standard_D2ds_v5"

# [User Input Required] Network mapping
$networkMappingResourceGroupName     = "demo-networkMappingResourceGroupName"
$networkName                         = "demo-network"
$subnetName                          = "default"

# [User Input Required] Machine profile
# The machine profile VM storageProfile.diskControllerType should be set to "SCSI" or left unset.
# Dsv5 sizes support SCSI only — the result is always SCSI.
# Note: If the machine profile OS disk has diskControllerTypes set, it must match the master image's SupportedDiskControllerTypes.
# Result: SCSI
$machineProfileResourceGroupName     = "demo-machineProfileResourceGroupName"
$machineProfileVmName                = "demo-vm"  # This VM has storageProfile.diskControllerType = SCSI (or the field can be left unset)

# Set masterImagePath, serviceOffering, networkMapping and machineProfile parameters
$masterImagePath    = "XDHyp:\HostingUnits\$hostingUnitName\image.folder\$masterImageResourceGroupName.resourcegroup\$masterImageSnapshotName"
$serviceOffering    = "XDHyp:\HostingUnits\$hostingUnitName\serviceoffering.folder\$newMachineSize.serviceoffering"
$networkMapping     = @{"0"="XDHyp:\HostingUnits\$hostingUnitName\$region.region\virtualprivatecloud.folder\$networkMappingResourceGroupName.resourcegroup\$networkName.virtualprivatecloud\$subnetName.network"}
$machineProfile     = "XDHyp:\HostingUnits\$hostingUnitName\machineprofile.folder\$machineProfileResourceGroupName.resourcegroup\$machineProfileVmName.vm"

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
