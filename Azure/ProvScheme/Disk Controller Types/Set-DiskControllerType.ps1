<#
.SYNOPSIS
    Updates the disk controller type of an existing MCS provisioning scheme by switching the machine profile.
    The updated configuration applies to new machines post operation.
    For applying to existing machines, run Set-ProvVmUpdateTimeWindow. Applicable for Citrix DaaS and on-prem.
.DESCRIPTION
    Set-DiskControllerType.ps1 demonstrates how to change the disk controller type (NVMe or SCSI) for an
    existing MCS provisioning scheme by updating the machine profile.

    Important: Changing between SCSI and NVMe requires redeployment of existing VMs.
    - SCSI -> SCSI or NVMe -> NVMe: No redeployment required.
    - SCSI -> NVMe or NVMe -> SCSI: Redeploy and recreate the VM.

    The original version of this script is compatible with Citrix Virtual Apps and Desktops 7 2503.
#>

# /*************************************************************************
# * Copyright © 2026. Cloud Software Group, Inc. All Rights Reserved.
# * This file is subject to the license terms contained
# * in the license file that is distributed with this file.
# *************************************************************************/

# Add Citrix snap-ins
Add-PSSnapin -Name "Citrix.Host.Admin.V2","Citrix.MachineCreation.Admin.V2"

# [User Input Required] Set parameters for Set-ProvScheme
$provisioningSchemeName          = "demo-provScheme"
$hostingUnitName                 = "demo-hostingUnit"

# [User Input Required] Machine profile — with the desired storageProfile.diskControllerType (NVMe or SCSI)
$machineProfileResourceGroupName = "demo-machineProfileResourceGroupName"
$machineProfileVmName            = "demo-NVMe-vm"

# Update the MachineProfile parameter to point to a VM with the new disk controller type
$updatedMachineProfile = "XDHyp:\HostingUnits\$hostingUnitName\machineprofile.folder\$machineProfileResourceGroupName.resourcegroup\$machineProfileVmName.vm"

# Modify the ProvisioningScheme with the updated machine profile
Set-ProvScheme -ProvisioningSchemeName $provisioningSchemeName -MachineProfile $updatedMachineProfile

# Schedules all existing VMs to be updated with the new configuration on the next power on
# Note: SCSI <-> NVMe changes require VM redeployment and recreation. SCSI -> SCSI or NVMe -> NVMe changes do not.
Set-ProvVmUpdateTimeWindow -ProvisioningSchemeName $provisioningSchemeName
