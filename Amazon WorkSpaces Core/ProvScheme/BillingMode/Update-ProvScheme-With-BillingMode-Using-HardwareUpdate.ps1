<#
.SYNOPSIS
    Sets or changes the BillingMode property on an existing MCS catalog using service windows and optionally apply the change to existing VMs.
    The updated properties will be applicable to new machines post operation, along with the existing machines.
    Applicable for Citrix DaaS and on-prem.
.DESCRIPTION
    Update-ProvScheme-With-BillingMode-Using-HardwareUpdate helps sets or change the BillingMode property on an existing MCS catalog.
    The original version of this script is compatible with Citrix DaaS March 2026 Release (DDC 128).
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

# [User Input Required] Setup the parameters for hardware update operations
$provisioningSchemeName = "demo-provScheme"
$customProperties = "BillingMode,Monthly;"

# =======================================================================
# Step 1: Create a new provisioining scheme version with new billing mode
# =======================================================================
New-ProvSchemeVersion -ProvisioningSchemeName $provisioningSchemeName -CustomProperties $customProperties


# =========================================================
# Step 2: Get the newly created provisioning scheme version 
# =========================================================
# Display all versions — use this to find the version number just created
# (e.g. version 2) which you will reference in the hardware update commands below.
Get-ProvSchemeVersion -ProvisioningSchemeName $provisioningSchemeName | Select-Object ProvisioningSchemeName, version, state | Format-Table -AutoSize


# ==========================================================
# Step 3: Apply the BillingMode change to new VMs or all VMs
# ==========================================================
# Option 1: Apply the new version to new VMs only so that newly created VMs pick up the new billing mode.
New-ProvSchemeHardwareUpdate -ProvisioningSchemeVersion 2 -StartsNow -NewVMsOnly -MaxDurationInMinutes 100 -ProvisioningSchemeName $provisioningSchemeName

#Option 2: Apply the new version to all VMs in the catalog so that all VMs pick up the new billing mode.
New-ProvSchemeHardwareUpdate -ProvisioningSchemeVersion 2 -StartsNow -AllVMs -MaxDurationInMinutes 100 -ProvisioningSchemeName $provisioningSchemeName


# ========================================
# Step 4: Check the hardware update status
# ========================================
# After the service window succeeds, i.e. MaintenanceCycleStatus shows Completed, power on the machines to verify they start correctly.
Get-ProvSchemeHardwareUpdate -ProvisioningSchemeName $provisioningSchemeName | Select MaintenanceCycleId, MaintenanceCycleStatus