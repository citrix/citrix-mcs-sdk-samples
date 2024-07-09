<#
.SYNOPSIS
    Creates an MCS catalog using a Launch Template Version as the MachineProfile source. Applicable for Citrix DaaS and on-prem.
.DESCRIPTION
    Create-MachineProfile-LaunchTemplateVersion creates an MCS ProvisioningScheme using a VM as the MachineProfile source.
    VMs created from this provisioning scheme will be based on the provided Launch Template Version.
    The original version of this script is compatible with Citrix Virtual Apps and Desktops 7 2402 Long Term Service Release (LTSR).
#>

# /*************************************************************************
# * Copyright © 2024. Cloud Software Group, Inc. All Rights Reserved.
# * This file is subject to the license terms contained
# * in the license file that is distributed with this file.
# *************************************************************************/

##########################
# Step 0: Set parameters #
##########################
# Add Citrix snap-ins
Add-PSSnapin -Name "Citrix.Host.Admin.V2","Citrix.MachineCreation.Admin.V2"

# [User Input Required] Setup the parameters for New-ProvScheme
$isCleanOnBoot = $false
$provisioningSchemeName = "demo-provScheme"
$availabilityZone = "us-east-1a.availabilityzone"
$subnet = "0.0.0.0``/0 (vpc-12345678910).network"
$identityPoolName = $provisioningSchemeName
$hostingUnitName = "demo-hostingunit"
$machineProfile = "XDHyp:\HostingUnits\$hostingUnitName\demo-lt (lt-00000000000000000).launchtemplate\lt-00000000000000000 (1).launchtemplateversion"
$networkMapping = @{"0"="XDHyp:\HostingUnits\$hostingUnitName\$availabilityZone\$subnet"}
$numberOfVms = 1
$serviceOffering = "XDHyp:\HostingUnits\$hostingUnitName\T2 Medium Instance.serviceoffering"
$customProperties = "AwsCaptureInstanceProperties,false;AwsOperationalResourcesTagging,True"
$masterImageVm = "XDHyp:\HostingUnits\$hostingUnitName\demo-master-image (ami-12345678910).template"
$securityGroupPath = "XDHyp:\HostingUnits\$hostingUnitName\default.securitygroup"

# [User Input Required] Setup the parameters for New-BrokerCatalog
$allocationType = "Random"
$description = "This is meant to be use as placeholders"
$persistUserChanges = "Discard"
$sessionSupport = "MultiSession"

######################################
# Step 1: Create Provisioning Scheme #
######################################
# Create Provisioning Scheme
$createdProvScheme = New-ProvScheme -ProvisioningSchemeName $provisioningSchemeName `
    -CleanOnBoot:$isCleanOnBoot `
    -CustomProperties $customProperties `
    -HostingUnitName $hostingUnitName `
    -IdentityPoolName $identityPoolName `
    -InitialBatchSizeHint $numberOfVms `
    -MachineProfile $machineProfile `
    -MasterImageVm $masterImageVm `
    -NetworkMapping $networkMapping `
    -SecurityGroup $securityGroupPath `
    -ServiceOffering $serviceOffering

#################################
# Step 2: Create Broker Catalog #
#################################
# Create the Broker Catalog. This allows you to see the catalog in Studio
New-BrokerCatalog -Name $provisioningSchemeName `
    -ProvisioningSchemeId $createdProvScheme.ProvisioningSchemeUid `
    -AllocationType $allocationType  `
    -Description $description `
    -IsRemotePC $False `
    -PersistUserChanges $persistUserChanges `
    -ProvisioningType "MCS" `
    -Scope @() `
    -SessionSupport $sessionSupport