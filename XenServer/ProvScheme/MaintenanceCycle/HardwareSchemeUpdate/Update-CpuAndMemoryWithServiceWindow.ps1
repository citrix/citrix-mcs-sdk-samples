<#
.SYNOPSIS
    Update CPU and memory for existing XenServer VMs using the MCS Service Window.

.DESCRIPTION
    This script demonstrates how to update the CPU count and memory of existing
    XenServer VMs via MCS (Machine Creation Services) Service Window PowerShell
    commands.

    The workflow is:
      1. Verify the current provisioning scheme configuration.
      2. Create a new provisioning scheme version with updated CPU and memory.
      3. Apply the hardware update using one of two options:
         Option A - Gradual rollout: NewVMs first, then test on a single VM
                    or canary batch, then roll out to all VMs.
         Option B - Apply to all VMs directly.
      4. Monitor progress and verify results.
      5. If a VM fails, roll back individually or all VMs to the previous version.

.PREREQUISITES
    - The XenServer hosting connection must be configured and accessible.
    - This feature needs XenPlugin MCS Power Managed to be enabled.
    - VMs must be powered off during the hardware update. The maintenance cycle
      handles this automatically via session warning and graceful logoff.

.NOTES
    XenServer recreates VMs during hardware updates: the original VM is destroyed
    and a new VM is created with the updated configuration. All disks (OS, identity,
    write-back cache) are preserved and re-attached to the new VM. This means the
    VM UUID will change after the update, but the machine identity and disks remain
    intact.

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
$provisioningSchemeName      = "MyXenServerCatalog"           # Your provisioning scheme name
$newCpuCount                 = 8                               # Target CPU count
$newMemoryMB                 = 8192                            # Target memory in MB
$description                 = "Updating CPU to $newCpuCount cores and memory to $($newMemoryMB / 1024) GB"
$maxDurationInMinutes        = 120                             # Max duration (minutes) for the operation
$purgeDBAfterInDays          = 30                              # Days before the record is purged from DB
$sessionWarningTimeInMinutes = 45                              # Minutes before execution to warn users
$sessionWarningLogOffTitle   = "Scheduled Maintenance"
$sessionWarningLogOffMessage = "Your workstation will be restarted for a hardware update. Please save your work."
# Schedule the service window to start at a specific time (UTC).
# Use -StartsNow instead of -ScheduledStartTimeInUTC to execute immediately.
$scheduledStartTimeInUTC     = [datetime]::UtcNow.Date.AddDays(7).AddHours(2)

# Common splatted parameters reused across service-window commands
$serviceWindowParams = @{
    ProvisioningSchemeName       = $provisioningSchemeName
    ScheduledStartTimeInUTC      = $scheduledStartTimeInUTC
    MaintenanceCycleDescription  = $description
    MaxDurationInMinutes         = $maxDurationInMinutes
    PurgeDBAfterInDays           = $purgeDBAfterInDays
    SessionWarningTimeInMinutes  = $sessionWarningTimeInMinutes
    SessionWarningLogOffTitle    = $sessionWarningLogOffTitle
    SessionWarningLogOffMessage  = $sessionWarningLogOffMessage
}

# ============================================================================
# Step 1 - Verify current provisioning scheme configuration
# ============================================================================

$currentScheme = Get-ProvScheme -ProvisioningSchemeName $provisioningSchemeName
Write-Host "Current configuration:"
Write-Host "  CPU Count: $($currentScheme.CpuCount)"
Write-Host "  Memory MB: $($currentScheme.MemoryMB)"
Write-Host "  Machine Profile: $($currentScheme.MachineProfile)"

# ============================================================================
# Step 2 - Create a new provisioning scheme version with updated CPU and memory
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
# Step 3 - Apply the hardware update
#
#   Option A: NewVMs first, then gradual rollout (recommended).
#   Option B: Apply to all VMs directly.
#
#   Choose ONE of the two options below.
# ============================================================================

# ---- Option A: Gradual rollout (recommended) --------------------------------
#
# A-1. Apply the new configuration to new VMs only so that newly provisioned
#      VMs use the updated CPU/memory.
New-ProvSchemeHardwareUpdate -NewVMs @serviceWindowParams `
    -ProvisioningSchemeVersion 2

# A-2. Test on a single VM before rolling out to the full catalog.
#      Replace the filter below with your VM name.
$testVM = Get-BrokerMachine -DNSName "your-vm-name.domain.local"

New-ProvVmHardwareUpdate @serviceWindowParams `
    -ProvisioningSchemeVersion 2 `
    -ADAccountSid $($testVM.SID)

# A-3. (Optional) Canary rollout - apply to a small batch of VMs before the
#      full fleet. This lets you validate the update on a controlled subset
#      and catch issues early, making the rollout safer.

$vmList = @("VM-001", "VM-002", "VM-003")
foreach ($vmName in $vmList) {
    $vm = Get-BrokerMachine -DNSName "$vmName.domain.local"
    Write-Host "Applying to VM: $($vm.MachineName)  SID: $($vm.SID)"
    New-ProvVmHardwareUpdate @serviceWindowParams `
        -ProvisioningSchemeVersion 2 `
        -ADAccountSid $($vm.SID)
}

# A-4. Once the single-VM or canary batch passes, roll out to the remaining VMs.
#      Uncomment and run this separately, after the earlier steps are validated.
<#
New-ProvSchemeHardwareUpdate -AllVMs @serviceWindowParams `
    -ProvisioningSchemeVersion 2
#>

# ---- Option B: Apply to all VMs directly -------------------------------------
<#
    If you are confident and want to update every VM in the catalog at once:

    New-ProvSchemeHardwareUpdate -AllVMs @serviceWindowParams `
        -ProvisioningSchemeVersion 2
#>

# ============================================================================
# Step 4 - Monitor progress
# ============================================================================

# Get the maintenance cycle status
$maintenanceCycle = Get-ProvSchemeHardwareUpdate `
    -ProvisioningSchemeName $provisioningSchemeName
Write-Host "`nMaintenance cycle status: $($maintenanceCycle.Status)"

# Get per-VM status
Get-ProvMaintenanceCycleVM `
    -MaintenanceCycleId $maintenanceCycle.MaintenanceCycleId `
    -MaintenanceOperation HardwareUpdate |
    Select-Object VMName, MaintenanceStatus |
    Format-Table -AutoSize

# ============================================================================
# Step 5 - Verify results after completion
# ============================================================================

# After the service window completes, verify VMs have the updated configuration.
# Note: On XenServer, VMs are recreated during hardware update. The VM UUID
# changes but the machine identity and all disks are preserved.

Get-ProvMaintenanceCycleVM `
    -MaintenanceCycleId $maintenanceCycle.MaintenanceCycleId |
    Select-Object VMName, MaintenanceStatus, MaintenanceOperation |
    Format-Table -AutoSize

# ============================================================================
# Step 6 - Rollback (if any VM fails)
# ============================================================================

<#
    If a machine failed during the update, roll it back to the previous version
    and investigate the issue before retrying.

    # Roll back a single VM:
    $failedVM = Get-BrokerMachine -DNSName "failed-vm-name.domain.local"
    New-ProvVmHardwareUpdate @serviceWindowParams `
        -ProvisioningSchemeVersion 1 `
        -ADAccountSid $($failedVM.SID)

    # Or roll back all VMs to previous version:
    New-ProvSchemeHardwareUpdate -AllVMs @serviceWindowParams `
        -ProvisioningSchemeVersion 1

    # Check scheme history for available versions:
    Get-ProvSchemeHistory `
        -ProvisioningSchemeName $provisioningSchemeName |
        Select-Object Version, State, CreatedDate |
        Format-Table -AutoSize
#>
