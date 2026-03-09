<#
.SYNOPSIS
    Relocate the pagefile to another drive for existing Azure VMs using the MCS
    Service Window.

.DESCRIPTION
    This script demonstrates how to relocate the Windows pagefile to a different
    drive on existing Azure VMs via MCS (Machine Creation Services) Service
    Window PowerShell commands. By default the target drive is set to D: but
    you can change the $pageFileDriveLetter variable to any valid drive letter.

    The workflow is:
      1. Create a new provisioning scheme version with PageFileDiskDriveLetterOverride
         set to the target drive via custom properties.
      2. Apply the hardware update using one of two options:
         Option A – NewVMsOnly first, then test on a single VM or a list
                    of VMs before rolling out to all.
         Option B – Apply to all VMs directly.
      3. If a VM fails, roll back to the previous version.
      4. Verify results.

.PREREQUISITES
    - VDA 2503 or later must be installed on the target VMs (with MCSIO driver).
    - The target drive letter must exist and have sufficient free space for
      the pagefile.

.NOTES
    You can also configure InitialPageFileSizeInMB and MaxPageFileSizeInMB via
    custom properties in the same New-ProvSchemeVersion call to control the
    pagefile size.

    If the service window completes successfully but the Guest OS encounters
    issues (target drive not present, insufficient free space, etc.), the VM
    may fail to boot correctly. In that case roll back the provisioning scheme
    version to restore VM functionality.
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
$pageFileDriveLetter         = "D"                          # Target drive letter for the pagefile
$description                 = "Relocating pagefile to D: drive"
$maxDurationInMinutes        = 100                          # Max duration (minutes) allowed for the operation
$purgeDBAfterInDays          = 30                           # Days before the service window record is deleted
$sessionWarningTimeInMinutes = 45                           # Minutes before task execution to warn session users
$sessionWarningLogOffTitle   = "Confirming Maintenance Alert"
$sessionWarningLogOffMessage = "Your workstation will soon be turned down for maintenance."

# Optional: Configure pagefile size (uncomment to use)
# $initialPageFileSizeInMB   = 1024                        # Initial pagefile size in MB
# $maxPageFileSizeInMB       = 4096                        # Maximum pagefile size in MB

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
# Step 1 – Create a new provisioning scheme version with pagefile on D:
# ============================================================================

# Build custom properties XML to relocate the pagefile to D: drive
# You can also include InitialPageFileSizeInMB and MaxPageFileSizeInMB
$customProperties = @"
<CustomProperties xmlns="http://schemas.citrix.com/2014/xd/machinecreation" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">
    <Property xsi:type="StringProperty" Name="PageFileDiskDriveLetterOverride" Value="$pageFileDriveLetter" />
</CustomProperties>
"@

# Uncomment the block below to also set pagefile size limits:
<#
$customProperties = @"
<CustomProperties xmlns="http://schemas.citrix.com/2014/xd/machinecreation" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">
    <Property xsi:type="StringProperty" Name="PageFileDiskDriveLetterOverride" Value="$pageFileDriveLetter" />
    <Property xsi:type="IntProperty" Name="InitialPageFileSizeInMB" Value="$initialPageFileSizeInMB" />
    <Property xsi:type="IntProperty" Name="MaxPageFileSizeInMB" Value="$maxPageFileSizeInMB" />
</CustomProperties>
"@
#>

# Create a new version with the pagefile drive letter override.
$newSchemeVerionResult = New-ProvSchemeVersion `
    -ProvisioningSchemeName $provisioningSchemeName `
    -CustomProperties $customProperties

# The version number created is available via:
#   $newSchemeVerionResult.ProvisioningSchemeVersionCreated
# Display all versions for reference:
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
#      the updated pagefile location.
New-ProvSchemeHardwareUpdate -NewVMsOnly @serviceWindowParams `
    -ProvisioningSchemeVersion $newSchemeVerionResult.ProvisioningSchemeVersionCreated

# A-2. Test on a single VM (applies to persistent VMs).
#      Replace the filter below with your VM name.
$testVM = Get-BrokerMachine -DNSName "your-vm-name.domain.local"

New-ProvVmHardwareUpdate @serviceWindowParams `
    -ProvisioningSchemeVersion $newSchemeVerionResult.ProvisioningSchemeVersionCreated `
    -ADAccountSid $($testVM.SID)

# After the maintenance cycle completes, power on the machine and verify
# that the pagefile is now on the target drive.
# You can check via: wmic pagefile list /format:list

# A-3. (Optional) Apply to a list of VMs instead of one at a time.
<#
    $vmList = @("VM-001", "VM-002", "VM-003")
    foreach ($vmName in $vmList) {
        $vm = Get-BrokerMachine -DNSName "$vmName.domain.local"
        Write-Host "Applying to VM: $($vm.MachineName)  SID: $($vm.SID)"
        New-ProvVmHardwareUpdate @serviceWindowParams `
            -ProvisioningSchemeVersion $newSchemeVerionResult.ProvisioningSchemeVersionCreated `
            -ADAccountSid $($vm.SID)
    }
#>

# A-4. Once single/list VM test passes, roll out to remaining VMs.
<#
    New-ProvSchemeHardwareUpdate -AllVMs @serviceWindowParams `
        -ProvisioningSchemeVersion $newSchemeVerionResult.ProvisioningSchemeVersionCreated
#>

# ---- Option B: Apply to all VMs directly -------------------------------------
<#
    If you are confident and want to update every VM in the provisioning scheme
    at once, use -AllVMs:

    New-ProvSchemeHardwareUpdate -AllVMs @serviceWindowParams `
        -ProvisioningSchemeVersion $newSchemeVerionResult.ProvisioningSchemeVersionCreated
#>

# ============================================================================
# Step 3 – Roll back (if any VM fails)
# ============================================================================

<#
    Roll back a single VM to the previous provisioning scheme version.
    Replace the SID below with the target VM's SID (e.g. from Get-BrokerMachine).

    New-ProvVmHardwareUpdate @serviceWindowParams `
        -ProvisioningSchemeVersion 1 `
        -ADAccountSid "S-1-5-21-...replace-with-VM-SID..."

    Or roll back all VMs:

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
    To verify the pagefile location on a running VM, connect via RDP and run:
      wmic pagefile list /format:list
    or in PowerShell:
      Get-CimInstance -ClassName Win32_PageFileUsage | Select-Object Name, AllocatedBaseSize

    The pagefile should now be located at D:\pagefile.sys.

    If any machine failed, roll it back to the previous version (Step 3)
    and investigate the root cause before retrying.
#>
