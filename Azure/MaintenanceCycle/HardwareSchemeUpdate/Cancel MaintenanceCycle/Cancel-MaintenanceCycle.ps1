<#
.SYNOPSIS
    Cancels a MCS Maintenance Cycle. Applicable for Citrix DaaS and on-prem.
.DESCRIPTION
    Cancel-MaintenanceCycle cancels a MCS Maintenance Cycle
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
#Should provide with real guid
$maintenanceCycleId = "00000000-0000-0000-0000-000000000000"

####################################################
# Cancel Provisioning Maintenance Cycle
####################################################
Cancel-ProvMaintenanceCycle -MaintenanceCycleId $maintenanceCycleId