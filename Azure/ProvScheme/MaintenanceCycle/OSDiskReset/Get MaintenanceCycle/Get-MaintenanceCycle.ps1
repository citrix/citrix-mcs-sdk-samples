<#
.SYNOPSIS
    Gets a MCS Maintenance Cycle. Applicable for Citrix DaaS and on-prem.
.DESCRIPTION
    Get-MaintenanceCycle gets a MCS Maintenance Cycle
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
#real provisioning scheme guid should be passed in
$provisioningSchemeUid = "00000000-0000-0000-0000-000000000000"
$provisioningSchemeName = "ScaleTest"

###############################################################
# Gets Provisioning Maintenance Cycle for maintenance cycle id
###############################################################
Get-ProvMaintenanceCycle -MaintenanceCycleId $maintenanceCycleId -ProvisioningSchemeName $provisioningSchemeName -ProvisioningSchemeUid $provisioningSchemeUid