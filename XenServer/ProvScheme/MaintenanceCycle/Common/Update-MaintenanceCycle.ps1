<#
.SYNOPSIS
    Updates a MCS Maintenance Cycle. Applicable for Citrix DaaS and on-prem.
.DESCRIPTION
    Update-MaintenanceCycle updates attributes of a pending MCS Maintenance Cycle.
    This script is common to all operation types: ImageUpdate, OSDiskReset, IdentityDiskReset, HardwareSchemeUpdate.
    For OSDiskReset and IdentityDiskReset cycles, you can also update the VM list using the -VMName parameter.
#>

# /*************************************************************************
# * Copyright © 2026. Cloud Software Group, Inc. All Rights Reserved.
# * This file is subject to the license terms contained
# * in the license file that is distributed with this file.
# *************************************************************************/

Add-PSSnapin -Name "Citrix.Host.Admin.V2","Citrix.MachineCreation.Admin.V2"

#####################
# Prepare Parameters
#####################
#real maintenance cycle guid should be passed in
$maintenanceCycleId = "00000000-0000-0000-0000-000000000000"
#real provisioning scheme guid should be passed in
$provisioningSchemeUid = "00000000-0000-0000-0000-000000000000"
$newStartTimeForMaintenanceCycle = [datetime]::UtcNow.Date.AddDays(7).AddHours(2)
$newDescription = "Updating maintenance cycle"
$newMaxDurationInMinutes = 400
$newDataToBeStoredInDB = 40
$newSessionWarningTimeInMinutes = 100
$newSessionWarningLogOffTitle = "Confirming Maintenance Alert - Sunday"
$newSessionWarningLogOffMessage = "Your workstation will soon be turned down for maintenance work, please save any data to avoid data loss"

#####################################################################################
# Updates a Provisioning Maintenance Cycle (all operation types)
#####################################################################################
Update-ProvMaintenanceCycle -MaintenanceCycleId $maintenanceCycleId `
  -ScheduledStartTimeInUTC $newStartTimeForMaintenanceCycle `
  -MaintenanceCycleDescription $newDescription `
  -MaxDurationInMinutes $newMaxDurationInMinutes `
  -PurgeDBAfterInDays $newDataToBeStoredInDB `
  -SessionWarningTimeInMinutes $newSessionWarningTimeInMinutes `
  -SessionWarningLogOffTitle $newSessionWarningLogOffTitle `
  -SessionWarningLogOffMessage $newSessionWarningLogOffMessage `
  -ProvisioningSchemeUid $provisioningSchemeUid

#####################################################################################
# Updates with VM list change (OSDiskReset / IdentityDiskReset only)
#####################################################################################
Update-ProvMaintenanceCycle -MaintenanceCycleId $maintenanceCycleId `
  -VMName reset04 `
  -ScheduledStartTimeInUTC $newStartTimeForMaintenanceCycle `
  -MaintenanceCycleDescription $newDescription `
  -MaxDurationInMinutes $newMaxDurationInMinutes `
  -PurgeDBAfterInDays $newDataToBeStoredInDB `
  -SessionWarningTimeInMinutes $newSessionWarningTimeInMinutes `
  -SessionWarningLogOffTitle $newSessionWarningLogOffTitle `
  -SessionWarningLogOffMessage $newSessionWarningLogOffMessage `
  -ProvisioningSchemeUid $provisioningSchemeUid
