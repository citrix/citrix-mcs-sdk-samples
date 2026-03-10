<#
.SYNOPSIS
    Gets a MCS Maintenance Cycle VM instances. Applicable for Citrix DaaS and on-prem.
.DESCRIPTION
    Get-MaintenanceCycleVM gets a MCS Maintenance Cycle virtual machine factory instances
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
#real virtual machine sid should be passed in
$virtualMachineSid = "00000000-0000-0000-0000-000000000000"
$operationType = HardwareVmUpdate
$Status = "Completed"

#####################################################################################
# Gets Provisioning Maintenance Cycle virtual machine info for maintenance cycle id
#####################################################################################
Get-ProvMaintenanceCycleVM -MaintenanceCycleId $maintenanceCycleId -VirtualMachineSid $virtualMachineSid -MaintenanceOperation $operationType -MaintenanceStatus $Status