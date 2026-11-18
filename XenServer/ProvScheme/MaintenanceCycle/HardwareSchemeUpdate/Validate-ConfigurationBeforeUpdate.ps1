<#
.SYNOPSIS
    Validate provisioning scheme configuration before applying a hardware update on XenServer.

.DESCRIPTION
    This script demonstrates how to run pre-flight validation checks before
    applying a hardware update. The validation detects configuration issues
    that would cause the update to fail, such as:

      - Missing VM metadata (VMMetadataNotFound)
      - vTPM inconsistency (InconsistentVtpmSetting)

    The workflow is:
      1. Retrieve the current provisioning scheme and master image metadata.
      2. Build the updated specification with desired changes.
      3. Run validation using Set-ProvScheme -Validate.
      4. Review any errors before proceeding with the update.

.PREREQUISITES
    - The XenServer hosting connection must be configured and accessible.
    - The `XenPluginMCSPowerManaged` feature toggle must be enabled.

.NOTES
    vTPM Consistency Rules:
      - Master image has vTPM ON, update disables vTPM → InconsistentVtpmSetting error.
      - Master image has vTPM OFF, update enables vTPM → Allowed (no error).
      - Both have vTPM OFF → Allowed (no error).
      - Both have vTPM ON → Allowed (no error).

    Always run validation before creating a hardware update maintenance cycle
    to catch issues early and avoid failed updates across the catalog.

#>

# /*************************************************************************
# * Copyright © 2026. Cloud Software Group, Inc. All Rights Reserved.
# * This file is subject to the license terms contained
# * in the license file that is distributed with this file.
# *************************************************************************/

Add-PSSnapin -Name "Citrix.Host.Admin.V2","Citrix.MachineCreation.Admin.V2"

# ============================================================================
# Configuration - update these values for your environment
# ============================================================================
$provisioningSchemeName = "MyXenServerCatalog"

# ============================================================================
# Step 1 - Retrieve current provisioning scheme
# ============================================================================

$scheme = Get-ProvScheme -ProvisioningSchemeName $provisioningSchemeName
Write-Host "Current scheme:"
Write-Host "  Master Image: $($scheme.MasterImageVM)"
Write-Host "  CPU Count: $($scheme.CpuCount)"
Write-Host "  Memory MB: $($scheme.MemoryMB)"

# ============================================================================
# Step 2 - Validate before applying changes
# ============================================================================

# Validate a CPU and memory change
Write-Host "`nValidating CPU and memory update..."
$validationResult = Set-ProvScheme -ProvisioningSchemeName $provisioningSchemeName `
    -CpuCount 8 `
    -MemoryMB 8192 `
    -Validate

if ($validationResult) {
    Write-Host "Validation errors found:"
    $validationResult | ForEach-Object {
        Write-Host "  Error: $($_.ErrorToken)"
    }
    Write-Host "`nFix the issues above before proceeding with the hardware update."
} else {
    Write-Host "Validation passed. Safe to proceed with the hardware update."
}

# ============================================================================
# Step 3 - Validate machine profile change
# ============================================================================

# If updating the machine profile, validate that too
$machineProfilePath = "XDHyp:\HostingUnits\XenServerUnit\<profile-vm>.vm"

<#
Write-Host "`nValidating machine profile update..."
$profileValidation = Set-ProvScheme -ProvisioningSchemeName $provisioningSchemeName `
    -MachineProfile $machineProfilePath `
    -Validate

if ($profileValidation) {
    Write-Host "Validation errors found:"
    $profileValidation | ForEach-Object {
        Write-Host "  Error: $($_.ErrorToken)"
    }
} else {
    Write-Host "Machine profile validation passed."
}
#>

# ============================================================================
# Step 4 - Common validation errors and resolutions
# ============================================================================

<#
    Error: VMMetadataNotFound
    Cause: The provisioning scheme does not have valid XenServer VM metadata.
           This can happen if the master image path is invalid or the metadata
           was not properly exported during catalog creation.
    Fix:   Re-create the provisioning scheme with a valid master image path,
           or update the master image using New-ProvSchemeImageUpdate.

    Error: InconsistentVtpmSetting
    Cause: The master image has vTPM enabled, but the updated configuration
           would disable vTPM. Removing vTPM from VMs whose master image
           has it enabled is not supported.
    Fix:   Either keep vTPM enabled in the updated configuration, or use a
           master image that does not have vTPM enabled.
#>
