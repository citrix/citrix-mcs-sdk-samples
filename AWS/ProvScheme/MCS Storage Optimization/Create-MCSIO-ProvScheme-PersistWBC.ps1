<#
.SYNOPSIS
    Creates an MCS catalog with MCS/IO using WriteBackCache Disk. Applicable for Citrix DaaS and on-prem.
.DESCRIPTION
    Create-MCSIO-ProvScheme creates an MCS Provisioning Scheme with Write-back cache enabled and enables persisting the write-back cache disk between power cycles.
    The original version of this script is compatible with Citrix Virtual Apps and Desktops 7 2507 Long Term Service Release (LTSR).
#>

# /*************************************************************************
# * Copyright © 2025. Cloud Software Group, Inc. All Rights Reserved.
# * This file is subject to the license terms contained
# * in the license file that is distributed with this file.
# *************************************************************************/

##########################
# Step 0: Set parameters #
##########################
# Add Citrix snap-ins
Add-PSSnapin -Name "Citrix.Host.Admin.V2","Citrix.MachineCreation.Admin.V2"

# [User Input Required] Setup the parameters for New-ProvScheme
$isCleanOnBoot = $true
$provisioningSchemeName = "demo-provScheme"
$availabilityZone = "us-east-1a.availabilityzone"
$subnet = "0.0.0.0``/0 (vpc-12345678910).network"
$identityPoolName = $provisioningSchemeName
$hostingUnitName = "demo-hostingunit"
$machineProfile = "XDHyp:\HostingUnits\$hostingUnitName\$availabilityZone\Demo Machine Profile VM (i-012345678910).vm"
$networkMapping = @{"0"="XDHyp:\HostingUnits\$hostingUnitName\$availabilityZone\$subnet"}
$numberOfVms = 1
$serviceOffering = "XDHyp:\HostingUnits\$hostingUnitName\T2 Medium Instance.serviceoffering"
$masterImageVm = "XDHyp:\HostingUnits\$hostingUnitName\demo-master-image (ami-12345678910).template"

#Setting WriteBackCache properties
$usesWritebackCache = $true
$writeBackCacheDiskSize = 16
$writeBackCacheMemorySize = 128

# Setting custom properties to optimize storage for MCS/IO Persistent Write Back Cache Disk Properties, Persistent WBC and Persistent OS Disk
# PersistOsDisk: True - Persist the OS disk between reboots
# PersistWBC: True - Persist the Write Back Cache disk between reboots
# WBCDiskStorageType: gp3:3000:135 - Use gp3 storage with 3000 IOPS and 135 MB/s throughput for the Write Back Cache disk
$customProperties = "AwsCaptureInstanceProperties,false;AwsOperationalResourcesTagging,True;PersistOsDisk,True;PersistWBC,True;WBCDiskStorageType,gp3:3000:135;"

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
    -ServiceOffering $serviceOffering `
    -UseWriteBackCache:$usesWritebackCache `
    -WriteBackCacheDiskSize $writeBackCacheDiskSize `
    -WriteBackCacheMemorySize $writeBackCacheMemorySize

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