<#
.SYNOPSIS
    Creates an MCS Maintenance Cycle for Provisioning Scheme Image Update on XenServer. Applicable for Citrix DaaS and on-prem.
.DESCRIPTION
    Create-MaintenanceCycle creates an MCS Maintenance Cycle for Provisioning Scheme Image Update.
    Supports both the traditional master image workflow and the decoupled image version workflow.
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
$startTimeForMaintenanceCycle = [datetime]::SpecifyKind([datetime]'2026-11-15 22:14:33', 'utc')
$description = "Updating image of the virtual machines on 15th November to 2411"
$maxDurationInMinutes = 100
$dataToBeStoredInDB = 30
$sessionWarningTimeInMinutes = 45
$SessionWarningLogOffTitle = "Confirming Maintenance Alert"
$SessionWarningLogOffMessage = "Your workstation will soon be turned down for maintenance work, please save any data"
$ImageVersionSpecUid = "00000000-0000-0000-0000-000000000000"
#Please add Master Image Vm Path for XenServer
$MasterImageVM = "XDHyp:\HostingUnits\XenServerUnit\<vm-name>.vm\<snapshot-name>.snapshot"

###############################################################################
# Create Provisioning Maintenance Cycle for traditional image update workflow
###############################################################################
New-ProvSchemeImageUpdate `
  -ProvisioningSchemeName $provisioningSchemeName `
  -ScheduledStartTimeInUTC $startTimeForMaintenanceCycle `
  -MaintenanceCycleDescription $description `
  -MaxDurationInMinutes $maxDurationInMinutes `
  -PurgeDBAfterInDays $dataToBeStoredInDB `
  -SessionWarningTimeInMinutes $sessionWarningTimeInMinutes `
  -SessionWarningLogOffTitle $SessionWarningLogOffTitle `
  -SessionWarningLogOffMessage $SessionWarningLogOffMessage `
  -MasterImageVM $MasterImageVM `
  -ProvisioningSchemeVersion 2

###########################################################################
# Create Provisioning Maintenance Cycle for decoupling workflow
###########################################################################
New-ProvSchemeImageUpdate `
  -ProvisioningSchemeName $provisioningSchemeName `
  -StartsNow `
  -MaintenanceCycleDescription $description `
  -MaxDurationInMinutes $maxDurationInMinutes `
  -PurgeDBAfterInDays $dataToBeStoredInDB `
  -SessionWarningTimeInMinutes $sessionWarningTimeInMinutes `
  -SessionWarningLogOffTitle $SessionWarningLogOffTitle `
  -SessionWarningLogOffMessage $SessionWarningLogOffMessage `
  -ImageVersionSpecUid $ImageVersionSpecUid
