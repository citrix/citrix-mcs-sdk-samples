﻿<#
.SYNOPSIS
    Creates a provisioning scheme and a broker catalog.
.DESCRIPTION
    Create-ProvScheme.ps1 creates an MCS Provisioning Scheme.
    The original version of this script is compatible with Citrix Virtual Apps and Desktops 7 2203 Long Term Service Release (LTSR).
#>

# /*************************************************************************
# * Copyright © 2024. Cloud Software Group, Inc. All Rights Reserved.
# * This file is subject to the license terms contained
# * in the license file that is distributed with this file.
# *************************************************************************/

# Add Citrix snap-ins
Add-PSSnapin -Name "Citrix.Host.Admin.V2","Citrix.MachineCreation.Admin.V2","Citrix.Broker.Admin.V2"

#------------------------------------------------- Create a ProvisioningScheme -----------------------------------------------------#
# [User Input Required] Set parameters for New-ProvScheme
$isCleanOnBoot = $true
$provisioningSchemeName = "demo-provScheme"
$identityPoolName = $provisioningSchemeName
$hostingUnitName = "demo-hostingUnit"
$masterImageResourceGroupName = "demo-masterImageResourceGroup"
$masterImage = "demo-snapshot.snapshot"
$networkMappingResourceGroupName = "demo-networkMappingResourceGroup"
$region = "East US"
$vNet = "MyVnet"
$subnet = "subnet1"
$numberOfVms = 1

# [User Input Required] Setup the parameters for New-BrokerCatalog
$allocationType = "Random"
$description = "This is meant to be use as placeholders"
$persistUserChanges = "Discard"
$sessionSupport = "MultiSession"

# Set serviceOffering, masterImagePath and networkMapping parameters
$masterImagePath = "XDHyp:\HostingUnits\$hostingUnitName\image.folder\$masterImageResourceGroupName.resourcegroup\$masterImage"
$networkMapping = @{"0"="XDHyp:\HostingUnits\$hostingUnitName\$region.region\virtualprivatecloud.folder\$networkMappingResourceGroupName.resourcegroup\$vNet.virtualprivatecloud\$subnet.network"}
$serviceOffering = "XDHyp:\HostingUnits\$hostingUnitName\serviceoffering.folder\Standard_B2als_v2.serviceoffering"


# Create the ProvisioningScheme
$createdProvScheme = New-ProvScheme -CleanOnBoot:$isCleanOnBoot `
-ProvisioningSchemeName $provisioningSchemeName `
-HostingUnitName $hostingUnitName `
-IdentityPoolName $identityPoolName `
-InitialBatchSizeHint $numberOfVms `
-MasterImageVM $masterImagePath `
-NetworkMapping $networkMapping `
-ServiceOffering $serviceOffering


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