<#
.SYNOPSIS
    Creates an MCS Maintenance Cycle for Provisioning Scheme Hardware Update on XenServer. Applicable for Citrix DaaS and on-prem.
.DESCRIPTION
    Create-MaintenanceCycle creates an MCS Maintenance Cycle for Provisioning Scheme Hardware Update.
    Supports targeting all VMs or new VMs only. Requires a scheme version to be created first.
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
$provisioningSchemeName = "test"
$startTimeForMaintenanceCycle = [datetime]::UtcNow.Date.AddDays(7).AddHours(2)
$description = "Updating cpu counts of all virtual machines from 4 to 8"
$maxDurationInMinutes = 100
$dataToBeStoredInDB = 30
$sessionWarningTimeInMinutes = 45
$SessionWarningLogOffTitle = "Confirming Maintenance Alert"
$SessionWarningLogOffMessage = "Your workstation will soon be turned down for maintenance work, please save any data"

####################################################
# Create Provisioning Maintenance Cycle for all vms
####################################################
New-ProvSchemeHardwareUpdate -AllVMs `
  -ProvisioningSchemeName $provisioningSchemeName `
  -ScheduledStartTimeInUTC $startTimeForMaintenanceCycle `
  -MaintenanceCycleDescription $description `
  -MaxDurationInMinutes $maxDurationInMinutes `
  -PurgeDBAfterInDays $dataToBeStoredInDB `
  -SessionWarningTimeInMinutes $sessionWarningTimeInMinutes `
  -SessionWarningLogOffTitle $SessionWarningLogOffTitle `
  -SessionWarningLogOffMessage $SessionWarningLogOffMessage `
  -ProvisioningSchemeVersion 2

###########################################################################
# Create Provisioning Maintenance Cycle for new vms only and starting now
###########################################################################
New-ProvSchemeHardwareUpdate -NewVMs `
  -ProvisioningSchemeName $provisioningSchemeName `
  -StartsNow `
  -MaintenanceCycleDescription $description `
  -MaxDurationInMinutes $maxDurationInMinutes `
  -PurgeDBAfterInDays $dataToBeStoredInDB `
  -SessionWarningTimeInMinutes $sessionWarningTimeInMinutes `
  -SessionWarningLogOffTitle $SessionWarningLogOffTitle `
  -SessionWarningLogOffMessage $SessionWarningLogOffMessage `
  -ProvisioningSchemeVersion 2
