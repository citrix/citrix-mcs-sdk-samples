<#
.SYNOPSIS
    Sets or changes custom properties on an existing MCS catalog using JSON format
    via service windows. Optionally applies the change to existing VMs.
    Applicable for Citrix DaaS and on-prem.
.DESCRIPTION
    Update-ProvScheme-With-JSON-CustomProperties.ps1 updates custom properties on an
    existing Amazon WorkSpaces Core provisioning scheme using the JSON format.
    This script uses service windows (New-ProvSchemeVersion / New-ProvSchemeHardwareUpdate)
    to apply changes to both new and existing machines.
    JSON custom properties are supported only on Amazon WorkSpaces Core, not on AWS EC2.
    The original version of this script is compatible with Citrix DaaS July 2026 Release (DDC 130).
    Keywords: Set-ProvScheme, New-ProvSchemeVersion, New-ProvSchemeHardwareUpdate,
              CustomProperties, JSON, Amazon WorkSpaces Core, WSC, service windows
#>

# /*************************************************************************
# * Copyright © 2026. Cloud Software Group, Inc. All Rights Reserved.
# * This file is subject to the license terms contained
# * in the license file that is distributed with this file.
# *************************************************************************/

# ============================
# Step 0: Setup the parameters
# ============================
# Add Citrix snap-ins
Add-PSSnapin -Name "Citrix.Host.Admin.V2","Citrix.MachineCreation.Admin.V2"

# [User Input Required] Setup the parameters for the update
$provisioningSchemeName = "demo-provScheme"

# [User Input Required] Custom properties in JSON format
# Only include the properties you want to update. The system will merge
# the updated properties with the existing provisioning scheme properties.
# You can update a catalog that was originally created with legacy format;
# the system handles the format conversion automatically.
$customProperties = @'
{
    "BillingMode": "Monthly",
    "WBCDiskStorageType": {
        "StorageType": "gp3",
        "Iops": 5000,
        "Throughput": 250
    }
}
'@

# =====================================================================
# Step 1: Create a new provisioning scheme version with JSON properties
# =====================================================================
New-ProvSchemeVersion -ProvisioningSchemeName $provisioningSchemeName -CustomProperties $customProperties

# =========================================================
# Step 2: Get the newly created provisioning scheme version
# =========================================================
# Display all versions to find the version number just created
# (e.g. version 2) which you will reference in the hardware update commands below.
Get-ProvSchemeVersion -ProvisioningSchemeName $provisioningSchemeName | Select-Object ProvisioningSchemeName, Version, State | Format-Table -AutoSize

# ==========================================================
# Step 3: Apply the custom property change to new or all VMs
# ==========================================================
# [User Input Required] Replace the version number below with the version from Step 2.

# Option 1: Apply the new version to new VMs only
New-ProvSchemeHardwareUpdate -ProvisioningSchemeVersion 2 -StartsNow -NewVMsOnly -MaxDurationInMinutes 100 -ProvisioningSchemeName $provisioningSchemeName

# Option 2: Apply the new version to all VMs in the catalog
New-ProvSchemeHardwareUpdate -ProvisioningSchemeVersion 2 -StartsNow -AllVMs -MaxDurationInMinutes 100 -ProvisioningSchemeName $provisioningSchemeName

# ========================================
# Step 4: Check the hardware update status
# ========================================
# After the service window succeeds, i.e. MaintenanceCycleStatus shows Completed,
# power on the machines to verify they start correctly.
Get-ProvSchemeHardwareUpdate -ProvisioningSchemeName $provisioningSchemeName | Select-Object MaintenanceCycleId, MaintenanceCycleStatus
