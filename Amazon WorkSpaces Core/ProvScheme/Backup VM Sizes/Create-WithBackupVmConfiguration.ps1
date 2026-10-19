<#
.SYNOPSIS
    Creates an MCS catalog with BackupVmConfiguration custom property. Applicable for Citrix DaaS and on-prem.
.DESCRIPTION
    Create-WithBackupVmConfiguration.ps1 creates a MCS ProvisioningScheme and Broker Catalog with a list of
	backup VM sizes that MCS can fallback to in the case of capacity-related issues.
    The original version of this script is compatible with Citrix DaaS 130 and CVAD 2611 CR.
#>

# /*************************************************************************
# * Copyright © 2026. Cloud Software Group, Inc. All Rights Reserved.
# * This file is subject to the license terms contained
# * in the license file that is distributed with this file.
# *************************************************************************/

################################
# Step 0: Setup the parameters #
################################
# Add Citrix snap-ins
Add-PSSnapin -Name "Citrix.Host.Admin.V2","Citrix.MachineCreation.Admin.V2","Citrix.Broker.Admin.V2"

# [User Input Required] Setup the parameters for New-ProvScheme
$isCleanOnBoot = $false
$provisioningSchemeName = "demo-provScheme"
$availabilityZone = "us-east-1a.availabilityzone"
$subnet = "0.0.0.0``/0 (vpc-12345678910).network"
$identityPoolName = $provisioningSchemeName
$hostingUnitName = "demo-hostingunit"
$machineProfile = "XDHyp:\HostingUnits\$hostingUnitName\$availabilityZone\Demo Machine Profile VM (i-012345678910).vm"
$networkMapping = @{"0"="XDHyp:\HostingUnits\$hostingUnitName\$availabilityZone\$subnet"}
$numberOfVms = 1
$serviceOffering = "XDHyp:\HostingUnits\$hostingUnitName\T2 Medium Instance.serviceoffering"

# The ImageVersionSpecUid is returned when creating a prepared image (See 'Image Management')
$imageVersionSpecUid = "00000000-0000-0000-0000-000000000000"

# BackupVmConfiguration is an array of objects where each object consists of a required InstanceType and an optional MarketType (must be "spot" if present, case-insensitive)
# For more info on JSON format, see .\ProvScheme\JSON Custom Properties
$customProperties = @'
{
    "BackupVmConfiguration": [{"InstanceType": "t3.medium", "MarketType": "spot"}, {"InstanceType": "t3.large"}]
}
'@

# [User Input Required] Setup the parameters for New-BrokerCatalog
$allocationType = "Random"
$description = "This is meant to be use as placeholders"
$persistUserChanges = "Discard"
$sessionSupport = "MultiSession"

##########################################
# Step 1: Create the Provisioning Scheme #
##########################################
# Create Provisioning Scheme
$createdProvScheme = New-ProvScheme -ProvisioningSchemeName $provisioningSchemeName `
    -CleanOnBoot:$isCleanOnBoot `
    -CustomProperties $customProperties `
    -HostingUnitName $hostingUnitName `
    -IdentityPoolName $identityPoolName `
    -InitialBatchSizeHint $numberOfVms `
	-MachineProfile $machineProfile `
    -ImageVersionSpecUid $imageVersionSpecUid `
    -NetworkMapping $networkMapping `
    -ServiceOffering $serviceOffering

#####################################
# Step 2: Create the Broker Catalog #
#####################################
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