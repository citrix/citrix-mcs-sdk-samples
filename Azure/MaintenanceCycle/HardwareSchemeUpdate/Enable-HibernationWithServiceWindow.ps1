<#
.SYNOPSIS
    Enable hibernation for existing Azure VMs using the MCS Service Window.

.DESCRIPTION
    This script demonstrates how to enable hibernation on existing Azure VMs
    that use temporary disks via MCS (Machine Creation Services) Service Window
    PowerShell commands.

    The workflow is:
      1. Create a new provisioning scheme version with a hibernation-enabled
         machine profile.
      2. Apply the hardware update using one of two options:
         Option A – NewVMsOnly first, then test on a single VM or a list
                    of VMs before rolling out to all.
         Option B – Apply to all VMs directly.
      3. If a VM fails, roll back to the previous version.
      4. Verify results.

.PREREQUISITES
    - The VM SKU and operating system must support hibernation.
    - The pagefile must NOT reside on a temporary disk. For VM SKUs that
      include a temporary disk the pagefile is placed there by default.
      The Citrix MCSIO driver automatically relocates the pagefile to the
      C drive when the VM is changed to a hibernation-enabled machine
      profile, so manual relocation is not required.
    - The OS disk size must be greater than the VM's memory size.
    - A machine profile resource (VM or template spec) with hibernation enabled
      must already exist in Azure.

.NOTES
    If hibernation-related checks fail during preflight validation (e.g.
    unsupported SKU or OS), the operation will be blocked.

    If the service window completes successfully but the Guest OS encounters
    issues (insufficient free disk space, etc.), Azure power actions may fail
    and cause VM creation failures. In that case roll back the provisioning
    scheme version to restore VM functionality.

#>

# /*************************************************************************
# * Copyright © 2026. Cloud Software Group, Inc. All Rights Reserved.
# * This file is subject to the license terms contained
# * in the license file that is distributed with this file.
# *************************************************************************/

Add-PSSnapin -Name "Citrix.Host.Admin.V2","Citrix.MachineCreation.Admin.V2","Citrix.Broker.Admin.V2"

# ============================================================================
# Configuration – update these values for your environment
# ============================================================================
$provisioningSchemeName      = "MyProvScheme"              # Your provisioning scheme name
$machineProfilePath          = "XDHyp:\HostingUnits\MyHostUnit\machineprofile.folder\MyResourceGroup.resourcegroup\HibernationEnabledVM.vm"
$description                 = "Updating machine profile to enable hibernation"
$maxDurationInMinutes        = 100                          # Max duration (minutes) allowed for the operation
$purgeDBAfterInDays          = 30                           # Days before the service window record is deleted
$sessionWarningTimeInMinutes = 45                           # Minutes before task execution to warn session users
$sessionWarningLogOffTitle   = "Confirming Maintenance Alert"
$sessionWarningLogOffMessage = "Your workstation will soon be turned down for maintenance."
# Schedule the service window to start at a specific time (UTC).
# This gives administrators time to review and cancel the maintenance cycle
# before it begins.
# You can use -StartsNow in place of -ScheduledStartTimeInUTC if you would
# want the service window to execute immediately.
$scheduledStartTimeInUTC     = [datetime]::SpecifyKind([datetime]'2026-04-01 02:00:00', 'utc')

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
# Step 1 – Create a new provisioning scheme version with hibernation enabled
# ============================================================================

# Create a new version that references a machine profile with hibernation enabled
New-ProvSchemeVersion `
    -ProvisioningSchemeName $provisioningSchemeName `
    -MachineProfile $machineProfilePath

# Display all versions — use this to find the version number just created
# (e.g. version 2) which you will reference in the hardware update commands below.
Get-ProvSchemeVersion `
    -ProvisioningSchemeName $provisioningSchemeName |
    Select-Object ProvisioningSchemeName, version, state |
    Format-Table -AutoSize

# ============================================================================
# Step 2 – Apply the hardware update
#
#   Option A: NewVMsOnly first, then test on a single VM or a list of VMs.
#   Option B: Apply to all VMs directly.
#
#   Choose ONE of the two options below.
# ============================================================================

# ---- Option A: Gradual rollout (recommended) --------------------------------
#
# A-1. Apply the new version to new VMs only so that newly created VMs pick up
#      the hibernation-enabled profile.
New-ProvSchemeHardwareUpdate -NewVMsOnly @serviceWindowParams `
    -ProvisioningSchemeVersion 2

# A-2. Test on a single VM (applies to persistent VMs).
#      Replace the filter below with your VM name.
$testVM = Get-BrokerMachine -DNSName "your-vm-name.domain.local"

New-ProvVmHardwareUpdate @serviceWindowParams `
    -ProvisioningSchemeVersion 2 `
    -ADAccountSid $($testVM.SID)

# After the maintenance cycle completes, power on the machine and verify
# that hibernation works correctly.
# You can check via: Get-VM -Name "your-vm-name" | Select-Object HibernationEnabled

# A-3. (Optional) Canary rollout – apply to a small batch of VMs before the
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


# A-4. Once single-VM or canary batch passes, roll out to remaining VMs.

    New-ProvSchemeHardwareUpdate -AllVMs @serviceWindowParams `
        -ProvisioningSchemeVersion 2


# ---- Option B: Apply to all VMs directly -------------------------------------
<#
    If you are confident and want to update every VM in the provisioning scheme
    at once, use -AllVMs:
#>
    New-ProvSchemeHardwareUpdate -AllVMs @serviceWindowParams `
        -ProvisioningSchemeVersion 2



# ============================================================================
# Step 3 – Troubleshooting (if any VM fails)
# ============================================================================
# After the service window succeeds, power on the machines to verify they start
# correctly. If a VM fails to start, query the VM error/warning DB for details:

    Get-ProvOperationEvent `
        -OperationType PowerManagement `
        -Filter { OperationName -eq 'PowerOn' -and OperationTargetName -eq 'SPRDS-001' }
    # OperationTargetName is the VM name.

#
# If a machine failed, roll it back to the previous version and fix the
# underlying issue (e.g. insufficient free disk space) before retrying.
# If the issue is not fixable, keep the machine on the previous version and
# exclude it from the update while rolling out to the rest of the fleet.
<#
    # Roll back a single VM:
    New-ProvVmHardwareUpdate @serviceWindowParams `
        -ProvisioningSchemeVersion 1 `
        -ADAccountSid "S-1-5-21-...replace-with-VM-SID..."

    # Or roll back all VMs:
    New-ProvSchemeHardwareUpdate -AllVMs @serviceWindowParams `
        -ProvisioningSchemeVersion 1
#>

# ============================================================================
# Step 4 – Verify results
# ============================================================================

# After the service window completes, power on machines and validate.
# Review the overall maintenance cycle status:
Get-ProvMaintenanceCycleVM

<#
    If any machine failed, roll it back to the previous version (Step 3)
    and investigate the root cause before retrying.
#>
