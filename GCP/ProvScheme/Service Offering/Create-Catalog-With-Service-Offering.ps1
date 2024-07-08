<#
.SYNOPSIS
    Creates an MCS catalog and provisions VMs with specified service offering. Applicable for Citrix DaaS and on-prem.
.DESCRIPTION
    This script creates an MCS catalog with specified machine type (also known as a service offering) using the ServiceOffering parameter of New-ProvScheme cmdlet.
    In this example, ServiceOffering is set to 'n1-standard-1'. All the VMs in the catalog will use n1-standard-1 machine type.
    The original version of this script is compatible with Citrix Virtual Apps and Desktops 7 2203 Long Term Service Release (LTSR).
#>

# /*************************************************************************
# * Copyright © 2024. Cloud Software Group, Inc. All Rights Reserved.
# * This file is subject to the license terms contained
# * in the license file that is distributed with this file.
# *************************************************************************/

# Add Citrix snap-ins
Add-PSSnapin -Name "Citrix.Host.Admin.V2","Citrix.MachineCreation.Admin.V2"

# [User Input Required] Set parameters for New-ProvScheme
$isCleanOnBoot = $false
$provisioningSchemeName = "demo-provScheme"
$identityPoolName = $provisioningSchemeName
$hostingUnitName = "GcpHostingUnitName"
$masterImageVmName = "master-image-vm"
$masterImageSnapshotName = "master-image-snapshot"
$vpcName = "my-vpc"
$subnetName = "my-vpc-sub"
$numberOfVms = 1
$ServiceOffering = "n1-standard-1"

# [User Input Required] Set parameters for New-BrokerCatalog
$AllocationType = "Random"
$Description = "Sample description for catalog"
$PersistUserChanges = "Discard"
$SessionSupport = "MultiSession"

# Set paths for master image and network mapping
$masterImageVm = "XDHyp:\HostingUnits\$hostingUnitName\$masterImageVmName.vm\$masterImageSnapshotName.snapshot"
$networkMapping = @{"0"="XDHyp:\HostingUnits\$hostingUnitName\$vpcName.virtualprivatecloud\$subnetName.network"}

# Set service offering path
$ServiceOfferingPath = "XDHyp:\HostingUnits\$hostingUnitName\machineTypes.folder\$ServiceOffering.serviceoffering"

# Create the ProvisioningScheme
$createdProvScheme = New-ProvScheme -CleanOnBoot:$isCleanOnBoot `
    -ProvisioningSchemeName $provisioningSchemeName `
    -HostingUnitName $hostingUnitName `
    -IdentityPoolName $identityPoolName `
    -InitialBatchSizeHint $numberOfVms `
    -MasterImageVM $masterImageVm `
    -NetworkMapping $networkMapping `
    -ServiceOffering $ServiceOfferingPath

# Create a Broker catalog. This allows you to see and manage the catalog from Studio
New-BrokerCatalog -Name $ProvisioningSchemeName `
    -ProvisioningSchemeId $createdProvScheme.ProvisioningSchemeUid `
    -AllocationType $AllocationType `
    -Description $Description `
    -IsRemotePC $False `
    -PersistUserChanges $PersistUserChanges `
    -ProvisioningType "MCS" `
    -Scope @() `
    -SessionSupport $SessionSupport