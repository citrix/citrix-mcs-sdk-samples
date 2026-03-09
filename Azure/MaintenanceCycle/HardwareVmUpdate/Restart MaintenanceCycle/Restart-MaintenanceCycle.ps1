<#
.SYNOPSIS
    Restarts a MCS Maintenance Cycle. Applicable for Citrix DaaS and on-prem.
.DESCRIPTION
    Restart-MaintenanceCycle Restarts a MCS Maintenance Cycle
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
#real maintenance cycle guid should be passed in
$maintenanceCycleId = "00000000-0000-0000-0000-000000000000"
$newStartTime = [datetime]::SpecifyKind([datetime]'2025-11-18 22:14:33', 'utc')
$newMaxDuration = 400

####################################################
# Restarts Provisioning Maintenance Cycle
####################################################
Restart-ProvMaintenanceCycle -MaintenanceCycleId $maintenanceCycleId -ScheduledStartTimeInUTC $newStartTime -MaxDurationInMinutes $newMaxDuration