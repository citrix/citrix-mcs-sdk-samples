<#
.SYNOPSIS
    Creates an MCS Maintenance Cycle for Provisioning Scheme Hardware Update. Applicable for Citrix DaaS and on-prem.
.DESCRIPTION
    Create-MaintenanceCycle creates an MCS Maintenance Cycle for Provisioning Scheme Hardware Update
#>

# /*************************************************************************
# * Copyright © 2025. Cloud Software Group, Inc. All Rights Reserved.
# * This file is subject to the license terms contained
# * in the license file that is distributed with this file.
# *************************************************************************/

Add-PSSnapin -Name "Citrix.Host.Admin.V2","Citrix.MachineCreation.Admin.V2"

#####################
# Prepare Parameters
#####################
$provisioningSchemeName = "test"
$startTimeForMaintenanceCycle = [datetime]::SpecifyKind([datetime]'2025-11-15 22:14:33', 'utc')
$description = "Updating cpu counts of all virtual machines on 15th Novembers from 4 to 8"
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
  -StartsNow`
  -MaintenanceCycleDescription $description `
  -MaxDurationInMinutes $maxDurationInMinutes `
  -PurgeDBAfterInDays $dataToBeStoredInDB `
  -SessionWarningTimeInMinutes $sessionWarningTimeInMinutes `
  -SessionWarningLogOffTitle $SessionWarningLogOffTitle `
  -SessionWarningLogOffMessage $SessionWarningLogOffMessage `
  -ProvisioningSchemeVersion 2