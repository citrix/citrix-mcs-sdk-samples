<#
.SYNOPSIS
    Creates an MCS catalog using JSON-format custom properties on Amazon WorkSpaces Core.
    Applicable for Citrix DaaS and on-prem.
.DESCRIPTION
    Create-ProvScheme-With-JSON-CustomProperties.ps1 creates an MCS Provisioning Scheme
    using the JSON custom properties format instead of the legacy semicolon-delimited format.
    JSON custom properties support nested structures for complex property values such as
    BackupVmConfiguration and WBCDiskStorageType.
    JSON custom properties are supported only on Amazon WorkSpaces Core, not on AWS EC2.
    The original version of this script is compatible with Citrix DaaS July 2026 Release (DDC 130).
    Keywords: New-ProvScheme, CustomProperties, JSON, Amazon WorkSpaces Core, WSC
#>

# /*************************************************************************
# * Copyright © 2026. Cloud Software Group, Inc. All Rights Reserved.
# * This file is subject to the license terms contained
# * in the license file that is distributed with this file.
# *************************************************************************/

# ======================
# Step 0: Set parameters
# ======================
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

# The ImageVersionSpecUid is returned when creating a prepared image (See 'Image Management')
$imageVersionSpecUid = "00000000-0000-0000-0000-000000000000"

# Setting WriteBackCache properties
$usesWritebackCache = $true
$writeBackCacheDiskSize = 16
$writeBackCacheMemorySize = 128

# [User Input Required] Custom properties in JSON format
# JSON custom properties use a structured JSON object instead of the legacy "Key,Value;" format.
# Nested objects and arrays are supported for complex properties.
#
# Supported custom properties for Amazon WorkSpaces Core:
#   BillingMode          - "Monthly" or "Hourly" (default: Hourly)
#   PersistWBC           - "True" or "False" - persist Write Back Cache disk between reboots
#   PersistOsDisk        - "True" or "False" - persist the OS disk between reboots
#   WBCDiskStorageType   - object with StorageType, optional Iops and Throughput
#   BackupVmConfiguration - array of objects with InstanceType
#
# WBCDiskStorageType uses a nested object:
#   "WBCDiskStorageType": {"StorageType": "gp3", "Iops": 3000, "Throughput": 135}
#
# BackupVmConfiguration uses an array of objects:
#   "BackupVmConfiguration": [{"InstanceType": "t3.medium"}, {"InstanceType": "t3.large"}]
#
# Legacy format equivalent: "PersistOsDisk,False;PersistWBC,False;WBCDiskStorageType,gp3:3000:135;BillingMode,Monthly;"
$customProperties = @'
{
    "BillingMode": "Monthly",
    "WBCDiskStorageType": {
        "StorageType": "gp3",
        "Iops": 3000,
        "Throughput": 135
    },
    "PersistWBC": "false",
    "PersistOsDisk": "false"
}
'@

# [User Input Required] Setup the parameters for New-BrokerCatalog
$allocationType = "Random"
$description = "This is meant to be use as placeholders"
$persistUserChanges = "Discard"
$sessionSupport = "MultiSession"

# ==================================
# Step 1: Create Provisioning Scheme
# ==================================
# Create Provisioning Scheme with JSON custom properties
$createdProvScheme = New-ProvScheme -ProvisioningSchemeName $provisioningSchemeName `
    -CleanOnBoot:$isCleanOnBoot `
    -CustomProperties $customProperties `
    -HostingUnitName $hostingUnitName `
    -IdentityPoolName $identityPoolName `
    -InitialBatchSizeHint $numberOfVms `
    -MachineProfile $machineProfile `
    -ImageVersionSpecUid $imageVersionSpecUid `
    -NetworkMapping $networkMapping `
    -ServiceOffering $serviceOffering `
    -UseWriteBackCache:$usesWritebackCache `
    -WriteBackCacheDiskSize $writeBackCacheDiskSize `
    -WriteBackCacheMemorySize $writeBackCacheMemorySize

# =============================
# Step 2: Create Broker Catalog
# =============================
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
