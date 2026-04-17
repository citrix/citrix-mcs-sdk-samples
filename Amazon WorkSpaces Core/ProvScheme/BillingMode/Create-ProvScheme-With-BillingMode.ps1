<#
.SYNOPSIS
    Creates an MCS catalog with BillingMode. Applicable for Citrix DaaS and on-prem.
.DESCRIPTION
    Create-ProvScheme-WithBillingMode.ps1  creates an MCS Provisioning Scheme with a specific BillingMode
    VMs created from this provisioning scheme would have a BillingMode set to Hourly or Monthly.
    The original version of this script is compatible with Citrix DaaS March 2026 Release (DDC 128).
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

#Setting WriteBackCache properties
$usesWritebackCache = $true
$writeBackCacheDiskSize = 16
$writeBackCacheMemorySize = 128

# Setting custom properties to set BillingMode to Monthly or Hourly. When no BillingMode specified, the VM would get created with BillingMode:Hourly by default
$customProperties = "BillingMode,Monthly;"

# [User Input Required] Setup the parameters for New-BrokerCatalog
$allocationType = "Random"
$description = "This is meant to be use as placeholders"
$persistUserChanges = "Discard"
$sessionSupport = "MultiSession"

# ==================================
# Step 1: Create Provisioning Scheme
# ==================================
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