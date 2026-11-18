<#
.SYNOPSIS
    Verify that old VMs are cleaned up after a XenServer hardware update.

.DESCRIPTION
    This script demonstrates how to verify that XenServer properly cleans up
    the original VM after a hardware update and that the new VM retains the
    original machine identity.

    During a hardware update on XenServer:
      - The original VM is destroyed.
      - A new VM is created with the updated configuration.
      - Disks are detached from the old VM and re-attached to the new VM.
      - The new VM retains the original VM name and machine identity.
      - The VM UUID changes (it is a different VM on the hypervisor).

    The workflow is:
      1. Record VM UUIDs before the update.
      2. Perform the hardware update.
      3. Verify old VMs no longer exist on the hypervisor.
      4. Verify new VMs have the original names and machine identities.

.PREREQUISITES
    - The XenServer hosting connection must be configured and accessible.
    - The `XenPluginMCSPowerManaged` feature toggle must be enabled.
    - XenCenter or xe CLI access for VM verification.

.NOTES
    This behavior is unique to XenServer. Other hypervisors (Azure, GCP) modify
    VMs in-place without destroying and recreating them.

    What changes after the update:
      - VM UUID (hypervisor-level identifier)

    What is preserved after the update:
      - VM name (machine catalog name)
      - Machine SID and AD identity
      - All attached disks (VDI UUIDs)
      - Network interface configuration

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

# ============================================================================
# Step 1 - Record VM UUIDs before the update
# ============================================================================

$vmsBefore = Get-ProvVM -ProvisioningSchemeName $provisioningSchemeName
$beforeSnapshot = @{}

foreach ($vm in $vmsBefore) {
    $beforeSnapshot[$vm.VMName] = $vm.VMId
    Write-Host "Before: $($vm.VMName) → UUID: $($vm.VMId)"
}

# ============================================================================
# Step 2 - Create a new provisioning scheme version and apply hardware update
# ============================================================================

# Create a new version with updated CPU count
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
Write-Host "`nWaiting for maintenance cycle to complete..."
do {
    Start-Sleep -Seconds 30
    $cycle = Get-ProvSchemeHardwareUpdate -ProvisioningSchemeName $provisioningSchemeName
    Write-Host "  Status: $($cycle.Status)"
} while ($cycle.Status -eq "InProgress" -or $cycle.Status -eq "Pending")

# ============================================================================
# Step 3 - Verify old VMs no longer exist
# ============================================================================

Write-Host "`nVerifying old VM cleanup..."
foreach ($vmName in $beforeSnapshot.Keys) {
    $oldUuid = $beforeSnapshot[$vmName]

    # Check if the old UUID still exists on the hypervisor
    # Use xe CLI on the XenServer host:
    #   xe vm-list uuid=<old-uuid>
    # Expected result: empty (VM no longer exists)

    Write-Host "  $vmName - old UUID $oldUuid should no longer exist on hypervisor"
    Write-Host "    Verify: xe vm-list uuid=$oldUuid"
}

# ============================================================================
# Step 4 - Verify new VMs have original names and new UUIDs
# ============================================================================

Write-Host "`nVerifying new VMs..."
$vmsAfter = Get-ProvVM -ProvisioningSchemeName $provisioningSchemeName

foreach ($vm in $vmsAfter) {
    $oldUuid = $beforeSnapshot[$vm.VMName]
    $uuidChanged = $oldUuid -ne $vm.VMId
    $namePreserved = $beforeSnapshot.ContainsKey($vm.VMName)

    Write-Host "  $($vm.VMName):"
    Write-Host "    Old UUID: $oldUuid"
    Write-Host "    New UUID: $($vm.VMId)"
    Write-Host "    UUID changed: $uuidChanged"
    Write-Host "    Name preserved: $namePreserved"

    if (-not $uuidChanged) {
        Write-Host "    WARNING: UUID did not change. VM may not have been updated."
    }
}

# ============================================================================
# Summary
# ============================================================================

Write-Host "`nSummary:"
Write-Host "  VMs before update: $($vmsBefore.Count)"
Write-Host "  VMs after update: $($vmsAfter.Count)"
Write-Host "  Expected: VM count unchanged, all UUIDs changed, all names preserved."
