<#
.SYNOPSIS
    Changes the disk controller type (SCSI or NVMe) of an existing MCS provisioning scheme by switching
    to a new machine size (service offering). The updated configuration applies to new machines post operation.
    For applying to existing machines, run Set-ProvVmUpdateTimeWindow. Applicable for Citrix DaaS and on-prem.
.DESCRIPTION
    Set-DiskControllerType.ps1 demonstrates how to change the disk controller type for an existing MCS
    provisioning scheme by moving to a VM size that uses the desired interface (for example, from a
    SCSI-only size to an NVMe-only size). The master image must support the target interface.

    Important: Changing between SCSI and NVMe requires redeployment of existing VMs.
    - SCSI -> SCSI or NVMe -> NVMe: No redeployment required.
    - SCSI -> NVMe or NVMe -> SCSI: Redeploy and recreate the VM.

    The original version of this script is compatible with Citrix Virtual Apps and Desktops 7 2607 LTSR CU1.
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

# [User Input Required] New service offering (VM size) with the desired disk controller type
# Move to a VM size that uses the target interface. The master image must support that interface.
$newMachineSize  = "Standard_D2ds_v6"   # Example: NVMe-only size
$serviceOffering = "XDHyp:\HostingUnits\$hostingUnitName\serviceoffering.folder\$newMachineSize.serviceoffering"

# Update the ProvisioningScheme with the new service offering
Set-ProvScheme -ProvisioningSchemeName $provisioningSchemeName -ServiceOffering $serviceOffering

# Schedules all existing VMs to be updated with the new configuration on the next power on.
# Note: SCSI <-> NVMe changes require VM redeployment and recreation. SCSI -> SCSI or NVMe -> NVMe changes do not.
Set-ProvVmUpdateTimeWindow -ProvisioningSchemeName $provisioningSchemeName
