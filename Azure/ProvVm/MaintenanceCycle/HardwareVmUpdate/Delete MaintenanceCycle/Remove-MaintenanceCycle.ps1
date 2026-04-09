<#
.SYNOPSIS
    Removes a MCS Maintenance Cycle. Applicable for Citrix DaaS and on-prem.
.DESCRIPTION
    Remove-MaintenanceCycle removes a MCS Maintenance Cycle
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
#Real Guid needs to be passed in
$maintenanceCycleId = "00000000-0000-0000-0000-000000000000"

####################################################
# Removes a Provisioning Maintenance Cycle
####################################################
Remove-ProvMaintenanceCycle -MaintenanceCycleId $maintenanceCycleId