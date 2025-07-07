<#
.SYNOPSIS
    Sets or changes the property on an existing MCS catalog.
    The updated properties will be applicable to new machines post operation, not to the existing machines.
    Applicable for Citrix DaaS and on-prem.
.DESCRIPTION
    Set-ProvScheme helps sets or change the property on an existing MCS catalog.
    The original version of this script is compatible with Citrix DaaS July 2025 Release (DDC 125).
#>

# /*************************************************************************
# * Copyright © 2025. Cloud Software Group, Inc. All Rights Reserved.
# * This file is subject to the license terms contained
# * in the license file that is distributed with this file.
# *************************************************************************/

################################
# Step 0: Setup the parameters #
################################
# Add Citrix snap-ins
Add-PSSnapin -Name "Citrix.Host.Admin.V2","Citrix.MachineCreation.Admin.V2"

# [User Input Required] Setup the parameters for Set-ProvScheme
$provisioningSchemeName = "demo-provScheme"
$hostingUnitName = "demo-hostingunit"
$serviceOffering = "XDHyp:\HostingUnits\$hostingUnitName\T3 Medium Instance.serviceoffering"
$subnet = "1.1.1.1``/0 (vpc-12345678910).network"
$availabilityZone = "us-east-1a.availabilityzone"
$networkMapping = @{"0"="XDHyp:\HostingUnits\$hostingUnitName\$availabilityZone\$subnet"}

#####################################################
# Step 1: Change the Provisioning Scheme properties #
#####################################################
# Change the provisioining scheme properties
Set-ProvScheme -ProvisioningSchemeName $provisioningSchemeName `
    -ServiceOffering $serviceOffering `
    -NetworkMapping $networkMapping `
