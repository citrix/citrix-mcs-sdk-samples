<#
.SYNOPSIS
    Creates an MCS catalog. Applicable for Citrix DaaS and on-prem.
.DESCRIPTION
    Create-ProvScheme creates an MCS ProvisioningScheme and Broker Catalog.
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

# [User Input Required] Setup the parameters for New-ProvScheme
$isCleanOnBoot = $true
$provisioningSchemeName = "demo-provScheme"
$availabilityZone = "us-east-1a.availabilityzone"
$identityPoolName = $provisioningSchemeName
$hostingUnitName = "demo-hostingunit"

# The ImageVersionSpecUid is returned when creating a prepared image (See 'Image Management')
$imageVersionSpecUid = "00000000-0000-0000-0000-000000000000"

$machineProfile = "XDHyp:\HostingUnits\$hostingUnitName\$availabilityZone\Demo Machine Profile VM (i-012345678910).vm"

# [User Input Optional] The optional parameters
$numberOfVms = 1

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
    -HostingUnitName $hostingUnitName `
    -IdentityPoolName $identityPoolName `
    -InitialBatchSizeHint $numberOfVms `
    -ImageVersionSpecUid $imageVersionSpecUid `
    -MachineProfile $machineProfile

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