<#
.SYNOPSIS
    Verify that disks are preserved after a XenServer hardware update.

.DESCRIPTION
    This script demonstrates how to verify that disk VBDs (Virtual Block Devices),
    VDI UUIDs, and device ordering are preserved after a hardware update on XenServer.

    XenServer recreates VMs during hardware updates, so it is important to confirm
    that:
      - The disk count remains the same (root, identity, WBC disks).
      - The VDI UUIDs are identical before and after (same physical disks).
      - The userdevice ordering is preserved (e.g., OS disk at 0, ID disk at 1).

    The workflow is:
      1. Capture the disk inventory of the VM before the update.
      2. Perform the hardware update.
      3. Capture the disk inventory of the new VM.
      4. Compare the two inventories.

.PREREQUISITES
    - The XenServer hosting connection must be configured and accessible.
    - This feature needs XenPlugin MCS Power Managed to be enabled.
    - XenCenter or xe CLI access for disk verification.

.NOTES
    During a hardware update, XenServer:
      - Destroys the original VM and creates a new one.
      - Detaches disks from the old VM and re-attaches them to the new VM.
      - Preserves VDI UUIDs, so the physical disk data is unchanged.
      - Maintains userdevice ordering (disk slot assignments).

    This applies to all disk types: OS (root) disk, identity disk, and write-back
    cache disk. Both persistent (full-clone) and non-persistent (differencing) disks
    are preserved.

#>

# /*************************************************************************
# * Copyright © 2026. Cloud Software Group, Inc. All Rights Reserved.
# * This file is subject to the license terms contained
# * in the license file that is distributed with this file.
# *************************************************************************/

Add-PSSnapin -Name "Citrix.Host.Admin.V2","Citrix.MachineCreation.Admin.V2","Citrix.Broker.Admin.V2"

# ============================================================================
# Configuration - update these values for your environment
# ============================================================================
$provisioningSchemeName = "MyXenServerCatalog"
$vmName                 = "MyVM-001"

# ============================================================================
# Step 1 - Capture disk inventory before the update
# ============================================================================

# Get the VM details from the broker
$vm = Get-BrokerMachine -MachineName "*\$vmName"
Write-Host "VM: $($vm.MachineName)"
Write-Host "VM UUID: $($vm.HostedMachineId)"

# Use xe CLI or XenCenter to capture VDI UUIDs before the update.
# Example using xe CLI (run on XenServer host):
#   xe vm-disk-list uuid=<vm-uuid>
#
# Record the output for comparison after the update:
#   - userdevice (disk slot): 0 = OS disk, 1 = identity disk, 2 = WBC disk
#   - VDI UUID: unique identifier for each physical disk
#   - Disk count: total number of attached disks

Write-Host "`nBefore update - capture disk details using XenCenter or xe CLI:"
Write-Host "  xe vm-disk-list uuid=$($vm.HostedMachineId)"

# ============================================================================
# Step 2 - Create a new provisioning scheme version and apply hardware update
# ============================================================================

# Example: create a new version with updated CPU count
New-ProvSchemeVersion `
    -ProvisioningSchemeName $provisioningSchemeName `
    -CpuCount 4

# Verify the version was created
Get-ProvSchemeVersion `
    -ProvisioningSchemeName $provisioningSchemeName |
    Select-Object ProvisioningSchemeName, Version, State |
    Format-Table -AutoSize

New-ProvSchemeHardwareUpdate -AllVMs `
    -ProvisioningSchemeName $provisioningSchemeName `
    -StartsNow `
    -MaxDurationInMinutes 120 `
    -ProvisioningSchemeVersion 2

# Wait for the maintenance cycle to complete
$maintenanceCycle = Get-ProvSchemeHardwareUpdate `
    -ProvisioningSchemeName $provisioningSchemeName
Write-Host "`nMaintenance cycle status: $($maintenanceCycle.Status)"

# ============================================================================
# Step 3 - Capture disk inventory after the update
# ============================================================================

# The VM UUID changes after hardware update (new VM created).
# Get the updated VM reference.
$updatedVm = Get-BrokerMachine -MachineName "*\$vmName"
Write-Host "`nAfter update:"
Write-Host "  Old VM UUID: $($vm.HostedMachineId)"
Write-Host "  New VM UUID: $($updatedVm.HostedMachineId)"
Write-Host "  VM Name preserved: $($vm.MachineName -eq $updatedVm.MachineName)"

Write-Host "`nAfter update - capture disk details:"
Write-Host "  xe vm-disk-list uuid=$($updatedVm.HostedMachineId)"

# ============================================================================
# Step 4 - Compare disk inventories
# ============================================================================

# Verify the following manually or via script:
#   1. Disk count is the same before and after.
#   2. VDI UUIDs at each userdevice slot match.
#   3. Userdevice ordering is preserved (0, 1, 2...).
#
# Example expected output:
#   Before: userdevice=0 VDI=abc-123, userdevice=1 VDI=def-456
#   After:  userdevice=0 VDI=abc-123, userdevice=1 VDI=def-456
#   Result: All disks preserved.

Write-Host "`nCompare the VDI UUIDs at each userdevice slot."
Write-Host "If they match, disks were successfully preserved during the hardware update."
