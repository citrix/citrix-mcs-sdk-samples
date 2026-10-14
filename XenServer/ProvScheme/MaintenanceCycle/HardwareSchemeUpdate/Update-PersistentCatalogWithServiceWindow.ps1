<#
.SYNOPSIS
    Update hardware configuration for persistent catalog VMs on XenServer.

.DESCRIPTION
    This script demonstrates how to perform a hardware update (CPU, memory) on
    VMs in a persistent MCS catalog on XenServer.

    Persistent catalogs use full-clone disks rather than differencing disks.
    During a hardware update, XenServer recreates the VM but preserves all
    full-clone disks and re-attaches them to the new VM.

    The workflow is:
      1. Verify the current persistent catalog configuration.
      2. Capture disk state before the update (for verification).
      3. Create a new provisioning scheme version with updated hardware.
      4. Apply the hardware update (single VM, canary batch, or all VMs).
      5. Verify that full-clone disks are preserved after the update.

.PREREQUISITES
    - The provisioning scheme must be a persistent catalog (CleanOnBoot = false).
    - This feature needs XenPlugin MCS Power Managed to be enabled.
    - VMs must be powered off during the hardware update.

.NOTES
    Key differences for persistent catalogs:
      - Disks use full-clone (PersistentCloneDiskDefinition) instead of
        differencing disks (NonPersistentCloneDiskDefinition).
      - User data on the OS disk is preserved across the hardware update.
      - The full-clone VDI UUIDs remain the same after the update.
      - Both OS and identity disks are preserved and re-attached.

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
$provisioningSchemeName      = "MyPersistentCatalog"
$newCpuCount                 = 4
$newMemoryMB                 = 4096
$description                 = "Updating persistent catalog CPU to $newCpuCount and memory to $($newMemoryMB / 1024) GB"
$scheduledStartTimeInUTC     = [datetime]::UtcNow.Date.AddDays(7).AddHours(2)

$serviceWindowParams = @{
    ProvisioningSchemeName       = $provisioningSchemeName
    ScheduledStartTimeInUTC      = $scheduledStartTimeInUTC
    MaintenanceCycleDescription  = $description
    MaxDurationInMinutes         = 120
    PurgeDBAfterInDays           = 30
    SessionWarningTimeInMinutes  = 45
    SessionWarningLogOffTitle    = "Scheduled Maintenance"
    SessionWarningLogOffMessage  = "Your workstation will be restarted for a hardware update. Please save your work."
}

# ============================================================================
# Step 1 - Verify this is a persistent catalog
# ============================================================================

$scheme = Get-ProvScheme -ProvisioningSchemeName $provisioningSchemeName
Write-Host "Catalog: $($scheme.ProvisioningSchemeName)"
Write-Host "  CleanOnBoot: $($scheme.CleanOnBoot)"
Write-Host "  CPU Count: $($scheme.CpuCount)"
Write-Host "  Memory MB: $($scheme.MemoryMB)"

if ($scheme.CleanOnBoot) {
    Write-Host "WARNING: This is a non-persistent catalog. User data on OS disk will not be preserved across reboots."
} else {
    Write-Host "Confirmed: Persistent catalog. User data on OS disk is preserved."
}

# ============================================================================
# Step 2 - Capture disk state before update (for verification)
# ============================================================================

$vms = Get-ProvVM -ProvisioningSchemeName $provisioningSchemeName
Write-Host "`nVMs in catalog: $($vms.Count)"

# Record a sample VM's disk info for later comparison
$sampleVm = $vms | Select-Object -First 1
Write-Host "Sample VM: $($sampleVm.VMName), UUID: $($sampleVm.VMId)"
Write-Host "  Capture disks: xe vm-disk-list uuid=$($sampleVm.VMId)"

# ============================================================================
# Step 3 - Create a new provisioning scheme version with updated hardware
# ============================================================================

New-ProvSchemeVersion `
    -ProvisioningSchemeName $provisioningSchemeName `
    -CpuCount $newCpuCount `
    -MemoryMB $newMemoryMB

# Verify the version was created (e.g. version 2)
Get-ProvSchemeVersion `
    -ProvisioningSchemeName $provisioningSchemeName |
    Select-Object ProvisioningSchemeName, Version, State |
    Format-Table -AutoSize

# ============================================================================
# Step 4 - Apply the hardware update
#
#   For persistent catalogs, gradual rollout is recommended: test on a single
#   VM first, then a canary batch, then the full catalog.
# ============================================================================

# Option 1: Test on a single VM first (recommended for persistent catalogs)
$testVM = Get-BrokerMachine -DNSName "your-vm-name.domain.local"

New-ProvVmHardwareUpdate @serviceWindowParams `
    -ProvisioningSchemeVersion 2 `
    -ADAccountSid $($testVM.SID)

# Option 2: Canary rollout - apply to a small batch of VMs
<#
$vmList = @("VM-001", "VM-002", "VM-003")
foreach ($vmName in $vmList) {
    $vm = Get-BrokerMachine -DNSName "$vmName.domain.local"
    Write-Host "Applying to VM: $($vm.MachineName)  SID: $($vm.SID)"
    New-ProvVmHardwareUpdate @serviceWindowParams `
        -ProvisioningSchemeVersion 2 `
        -ADAccountSid $($vm.SID)
}
#>

# Option 3: Once validated, roll out to all VMs.
#           Uncomment and run this separately, after Option 1 or 2 is validated.
<#
New-ProvSchemeHardwareUpdate -AllVMs @serviceWindowParams `
    -ProvisioningSchemeVersion 2
#>

# ============================================================================
# Step 5 - Monitor and verify
# ============================================================================

$maintenanceCycle = Get-ProvSchemeHardwareUpdate `
    -ProvisioningSchemeName $provisioningSchemeName
Write-Host "`nMaintenance cycle status: $($maintenanceCycle.Status)"

# After completion, verify:
Get-ProvMaintenanceCycleVM `
    -MaintenanceCycleId $maintenanceCycle.MaintenanceCycleId |
    Select-Object VMName, MaintenanceStatus |
    Format-Table -AutoSize

# Verify disk preservation on the sample VM
$updatedVms = Get-ProvVM -ProvisioningSchemeName $provisioningSchemeName
$updatedSample = $updatedVms | Where-Object { $_.VMName -eq $sampleVm.VMName }
Write-Host "`nSample VM after update:"
Write-Host "  Old UUID: $($sampleVm.VMId)"
Write-Host "  New UUID: $($updatedSample.VMId)"
Write-Host "  Verify disks preserved: xe vm-disk-list uuid=$($updatedSample.VMId)"

<#
    Compare the VDI UUIDs before and after. For persistent catalogs, the
    full-clone disks should have identical VDI UUIDs, confirming that user
    data on the OS disk is intact.
#>
