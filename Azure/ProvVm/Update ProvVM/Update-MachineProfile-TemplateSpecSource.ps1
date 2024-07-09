<#
.SYNOPSIS
    Sets or changes the MachineProfile parameter on an existing VirtualMachine in a MCS catalog. Applicable for Citrix DaaS and on-prem.
.DESCRIPTION
    Update-MachineProfile-TemplateSpecSource.ps1 helps change the MachineProfile configuration on an existing VirtualMachine in a MCS catalog.
    In this example, the MachineProfile parameter is updated on the VirtualMachine.
    The original version of this script is compatible with Citrix Virtual Apps and Desktops 7 2402 Long Term Service Release (LTSR).
#>

# /*************************************************************************
# * Copyright © 2024. Cloud Software Group, Inc. All Rights Reserved.
# * This file is subject to the license terms contained
# * in the license file that is distributed with this file.
# *************************************************************************/

# Add Citrix snap-ins
Add-PSSnapin -Name "Citrix.Host.Admin.V2","Citrix.MachineCreation.Admin.V2"

## Note - To use templateSpec as a source for machine profile

# [User Input Required] Set parameters for Set-ProvVM
$provisioningSchemeName = "demo-provScheme"
$hostingUnitName = "demo-hostingUnit"
$resourceGroupName = "demo-resourceGroup"
$templateSpecName = "demo-templateSpec"
$templateSpecVersion = "demo-templateSpecVersion"
$vmName = "demo-vm"
$startTime = "3/12/2022 3am"
$durationInMinutes = 60 # The default duration is 120 minutes, and a value less than 0 signifies that there is no specified end time.

# Update the MachineProfile parameter to point to a template spec source
$updatedMachineProfile = "XDHyp:\HostingUnits\$hostingUnitName\machineprofile.folder\$resourceGroupName.resourcegroup\$templateSpecName.templatespec\$templateSpecVersion.templatespecversion"

#############################
# Step 1: Modify the ProvVM #
#############################

Set-ProvVM -ProvisioningSchemeName $provisioningSchemeName -VMName $vmName -MachineProfile $updatedMachineProfile

##########################################################################################
# Step 2: Schedules the VM to be updated with the new configuration on the next power on #
##########################################################################################

Set-ProvVmUpdateTimeWindow -ProvisioningSchemeName $provisioningSchemeName -VMName $vmName -StartTimeInUTC $startTime -DurationInMinutes $durationInMinutes
# You need to reboot the machine within the specified time window to get the above updates on the machine.