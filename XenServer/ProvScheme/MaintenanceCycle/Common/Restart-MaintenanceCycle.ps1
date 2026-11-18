<#
.SYNOPSIS
    Restarts a MCS Maintenance Cycle. Applicable for Citrix DaaS and on-prem.
.DESCRIPTION
    Restart-MaintenanceCycle restarts a cancelled, failed, or unprocessed MCS Maintenance Cycle.
    This script is common to all operation types: ImageUpdate, OSDiskReset, IdentityDiskReset, HardwareSchemeUpdate.
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
$newStartTime = [datetime]::UtcNow.Date.AddDays(7).AddHours(2)
$newMaxDuration = 400

####################################################
# Restarts Provisioning Maintenance Cycle
####################################################
Restart-ProvMaintenanceCycle -MaintenanceCycleId $maintenanceCycleId -ScheduledStartTimeInUTC $newStartTime -MaxDurationInMinutes $newMaxDuration
