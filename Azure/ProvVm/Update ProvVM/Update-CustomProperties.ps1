<#
.SYNOPSIS
    Sets or changes the Custom Properties on an existing VirtualMachine in a MCS catalog. Applicable for Citrix DaaS and on-prem.
.DESCRIPTION
    Update-CustomProperties.ps1 helps change the CustomProperties configuration on an existing VirtualMachine in a MCS catalog.
    These new settings are appended to the existing settings and the existing settings are modified to the values provided during the update.
    The original version of this script is compatible with Citrix Virtual Apps and Desktops 7 2402 Long Term Service Release (LTSR).
#>

# /*************************************************************************
# * Copyright © 2024. Cloud Software Group, Inc. All Rights Reserved.
# * This file is subject to the license terms contained
# * in the license file that is distributed with this file.
# *************************************************************************/

# Add Citrix snap-ins
Add-PSSnapin -Name "Citrix.Host.Admin.V2","Citrix.MachineCreation.Admin.V2"

# [User Input Required] Set parameters for Set-ProvVM
$provisioningSchemeName = "demo-provScheme"
$vmName = "demo-vm"
$startTime = "3/12/2022 3am"
$durationInMinutes = 60 # The default duration is 120 minutes, and a value less than 0 signifies that there is no specified end time.

# 1. Update the CustomProperties to include the new value for StorageType
# 2. Update the CustomProperties to include the new value for StorageTypeAtShutdown
$customProperties = @"
<CustomProperties xmlns="http://schemas.citrix.com/2014/xd/machinecreation" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">
<Property xsi:type="StringProperty" Name="StorageType" Value="StandardSSD_LRS" />
<Property xsi:type="StringProperty" Name="StorageTypeAtShutdown" Value="Standard_LRS" />
</CustomProperties>
"@

#############################
# Step 1: Modify the ProvVM #
#############################

Set-ProvVM -ProvisioningSchemeName $provisioningSchemeName -VMName $vmName -CustomProperties $customProperties

##########################################################################################
# Step 2: Schedules the VM to be updated with the new configuration on the next power on #
##########################################################################################

Set-ProvVmUpdateTimeWindow -ProvisioningSchemeName $provisioningSchemeName -VMName $vmName -StartTimeInUTC $startTime -DurationInMinutes $durationInMinutes
# You need to reboot the machine within the specified time window to get the above updates on the machine.