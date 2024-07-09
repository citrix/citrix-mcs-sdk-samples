<#
.SYNOPSIS
    Clears existing configuration for VirtualMachine. Applicable for Citrix DaaS and on-prem.
.DESCRIPTION
    Update-RevertToProvSchemeConfiguration.ps1 helps to clear the configuration on an existing Virtual Machine in a MCS catalog.
    The original version of this script is compatible with Citrix Virtual Apps and Desktops 7 2402 Long Term Service Release (LTSR).
#>

# /*************************************************************************
# * Copyright © 2024. Cloud Software Group, Inc. All Rights Reserved.
# * This file is subject to the license terms contained
# * in the license file that is distributed with this file.
# *************************************************************************/

# Add Citrix snap-ins
Add-PSSnapin -Name "Citrix.Host.Admin.V2","Citrix.MachineCreation.Admin.V2"

# [User Input Required]
$provisioningSchemeName = "demo-provScheme"
$vmName = "demo-vm"
$startTime = "3/12/2022 3am"
$durationInMinutes = 60 # The default duration is 120 minutes, and a value less than 0 signifies that there is no specified end time.

#############################
# Step 1: Modify the ProvVM #
#############################

Set-ProvVM -ProvisioningSchemeName $provisioningSchemeName -VMName $vmName -RevertToProvSchemeConfiguration

#############################################################################
# Step 2: Schedules the VM to clear the configurationn on the next power on #
#############################################################################

Set-ProvVmUpdateTimeWindow -ProvisioningSchemeName $provisioningSchemeName -VMName $vmName -StartTimeInUTC $startTime -DurationInMinutes $durationInMinutes
# You need to reboot the machine within the specified time window to get the above updates on the machine.