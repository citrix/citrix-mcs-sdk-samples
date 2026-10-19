<#
.SYNOPSIS
    Sets or changes custom properties on an existing MCS catalog via service windows. Optionally applies the change to existing VMs.
    Applicable for Citrix DaaS and on-prem.
.DESCRIPTION
    Update-ProvSchemeAndVMs-WithBackupVmConfiguration.ps1 updates custom properties on an existing provisioning scheme.
	It also uses service windows (New-ProvSchemeVersion / New-ProvSchemeHardwareUpdate) to apply changes to both new and existing machines.    
    The original version of this script is compatible with Citrix DaaS 130 and CVAD 2611 CR.    
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
    "BackupVmConfiguration": [{"InstanceType": "t3.medium", "MarketType": "spot"}, {"InstanceType": "t3.large"}]
}
'@

# ===================================================================================
# Step 1: Create a new provisioning scheme version with updated BackupVmConfiguration
# ===================================================================================
$newProvSchemeVersion = New-ProvSchemeVersion -ProvisioningSchemeName $provisioningSchemeName -CustomProperties $customProperties

# =========================================================
# Step 2: Get the newly created provisioning scheme version
# =========================================================
# Verify if the new version got created and use the version from $newProvSchemeVersion.ProvisioningSchemeVersionCreated in next steps
if ("Finished" -ne $newProvSchemeVersion.TaskState)
{
    throw "Failed to create provisioning scheme version. TaskState: $($newProvSchemeVersion.TaskState)"
}

# ==========================================================
# Step 3: Apply the custom property change to new or all VMs
# ==========================================================

# Option 1: Apply the new version to new VMs only
New-ProvSchemeHardwareUpdate -ProvisioningSchemeVersion $newProvSchemeVersion.ProvisioningSchemeVersionCreated -StartsNow -NewVMsOnly -MaxDurationInMinutes 100 -ProvisioningSchemeName $provisioningSchemeName

# Option 2: Apply the new version to all VMs in the catalog
New-ProvSchemeHardwareUpdate -ProvisioningSchemeVersion $newProvSchemeVersion.ProvisioningSchemeVersionCreated -StartsNow -AllVMs -MaxDurationInMinutes 100 -ProvisioningSchemeName $provisioningSchemeName

# ========================================
# Step 4: Check the hardware update status
# ========================================
# After the service window succeeds, i.e. MaintenanceCycleStatus shows Completed,
# power on the machines to verify they start correctly.
Get-ProvSchemeHardwareUpdate -ProvisioningSchemeName $provisioningSchemeName | Select-Object MaintenanceCycleId, MaintenanceCycleStatus
