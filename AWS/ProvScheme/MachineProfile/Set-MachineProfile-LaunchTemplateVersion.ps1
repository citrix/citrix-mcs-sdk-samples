<#
.SYNOPSIS
    Sets or changes the MachineProfile parameter on an existing MCS catalog.
    The updated machine profile will be applicable to new machines post operation, not to the existing machines.
    Applicable for Citrix DaaS and on-prem.
.DESCRIPTION
    Set-MachineProfile-LaunchTemplateVersion.ps1 helps change the MachineProfile configuration on an existing MCS catalog.
    In this example, the MachineProfile parameter is updated on the ProvScheme.
    The original version of this script is compatible with Citrix Virtual Apps and Desktops 7 2402 Long Term Service Release (LTSR).
#>

# /*************************************************************************
# * Copyright © 2024. Cloud Software Group, Inc.
# * This file is subject to the license terms contained
# * in the license file that is distributed with this file.
# *************************************************************************/

##########################
# Step 0: Set parameters #
##########################
# Add Citrix snap-ins
Add-PSSnapin -Name "Citrix.Host.Admin.V2","Citrix.MachineCreation.Admin.V2"

# [User Input Required] Setup the parameters for Set-ProvScheme
$provisioningSchemeName = "demo-provScheme"
$availabilityZone = "us-east-1a.availabilityzone"
$subnet = "0.0.0.0``/0 (vpc-12345678910).network"
$hostingUnitName = "demo-hostingunit"
$machineProfile = "XDHyp:\HostingUnits\$hostingUnitName\demo-lt (lt-00000000000000000).launchtemplate\lt-00000000000000000 (1).launchtemplateversion"
$networkMapping = @{"0"="XDHyp:\HostingUnits\$hostingUnitName\$availabilityZone\$subnet"}
$serviceOffering = "XDHyp:\HostingUnits\$hostingUnitName\T2 Medium Instance.serviceoffering"
$customProperties = "AwsCaptureInstanceProperties,false;AwsOperationalResourcesTagging,True"
$securityGroupPath = "XDHyp:\HostingUnits\$hostingUnitName\default.securitygroup"

#####################################################
# Step 1: Change the Provisioning Scheme Properties #
#####################################################

Set-ProvScheme -ProvisioningSchemeName $provisioningSchemeName -MachineProfile $machineProfile -CustomProperties $customProperties -NetworkMapping $networkMapping -SecurityGroup $securityGroupPath -ServiceOffering $serviceOffering