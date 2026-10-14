<#
.SYNOPSIS
    Creates an MCS Maintenance Cycle for Identity Disk Reset on XenServer. Applicable for Citrix DaaS and on-prem.
.DESCRIPTION
    Create-MaintenanceCycle creates an MCS Maintenance Cycle for Identity Disk Reset.
    Before creating the maintenance cycle, repair the identity information using Repair-AcctIdentity.
    Supports targeting all VMs or a specific list of VMs.
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
$vmNames = @("reset03", "reset05")
$startTimeForMaintenanceCycle = [datetime]::UtcNow.Date.AddDays(7).AddHours(2)
$description = "Resetting the Identity information of all virtual machines"
$maxDurationInMinutes = 100
$dataToBeStoredInDB = 30
$sessionWarningTimeInMinutes = 45
$SessionWarningLogOffTitle = "Confirming Maintenance Alert"
$SessionWarningLogOffMessage = "Your workstation will soon be turned down for maintenance work, please save any data"

#####################
# Repair the Identity
#####################
Get-ProvVm -ProvisioningSchemeName $provisioningSchemeName | Repair-AcctIdentity -Target IdentityInfo

####################################################
# Create Provisioning Maintenance Cycle for all vms
####################################################
New-ProvMaintenanceCycle -AllVMs `
  -ProvisioningSchemeName $provisioningSchemeName `
  -ScheduledStartTimeInUTC $startTimeForMaintenanceCycle `
  -Operation ResetIDDisk `
  -MaintenanceCycleDescription $description `
  -MaxDurationInMinutes $maxDurationInMinutes `
  -PurgeDBAfterInDays $dataToBeStoredInDB `
  -SessionWarningTimeInMinutes $sessionWarningTimeInMinutes `
  -SessionWarningLogOffTitle $SessionWarningLogOffTitle `
  -SessionWarningLogOffMessage $SessionWarningLogOffMessage

########################################################
# Create Provisioning Maintenance Cycle for list of vms
# Use this instead of the all-VMs cycle above. The repair is
# narrowed to match, so only these VMs get a new AD password.
########################################################
<#
$vmNames | ForEach-Object { Get-ProvVm -ProvisioningSchemeName $provisioningSchemeName -VMName $_ } |
  Repair-AcctIdentity -Target IdentityInfo

New-ProvMaintenanceCycle -VMName $vmNames `
  -ProvisioningSchemeName $provisioningSchemeName `
  -ScheduledStartTimeInUTC $startTimeForMaintenanceCycle `
  -Operation ResetIDDisk `
  -MaintenanceCycleDescription $description `
  -MaxDurationInMinutes $maxDurationInMinutes `
  -PurgeDBAfterInDays $dataToBeStoredInDB `
  -SessionWarningTimeInMinutes $sessionWarningTimeInMinutes `
  -SessionWarningLogOffTitle $SessionWarningLogOffTitle `
  -SessionWarningLogOffMessage $SessionWarningLogOffMessage
#>
