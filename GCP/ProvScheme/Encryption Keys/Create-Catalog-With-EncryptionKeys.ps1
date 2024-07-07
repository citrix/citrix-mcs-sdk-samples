<#
.SYNOPSIS
    Creates an MCS catalog with provided encryption keys using CryptoKeyId custom property. Applicable for Citrix DaaS and on-prem.
.DESCRIPTION
    This script creates a Machine catalog with machines encrypted using the CryptoKeyId custom property.
    In this example, the provisioned machines will be encrypted with provided crypto key 'my-key' from the key ring 'my-key-ring'.
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
$vpcName = "vpc-name"
$subnetName = "subnet-name"
$numberOfVms = 1
$ProjectId = "my-project-id" # This is the id of the GCP project (not project name)
$Region = "us-central1" # If the encryption key is global, this value should be set to 'global'
$CryptoKeyName = "my-regional-key"
$KeyRingName = "my-regional-ring"

# [User Input Required] Set parameters for New-BrokerCatalog
$AllocationType = "Random"
$Description = "Sample description for catalog"
$PersistUserChanges = "Discard"
$SessionSupport = "MultiSession"

# Set paths for master image and network mapping
$masterImageVm = "XDHyp:\HostingUnits\$hostingUnitName\$masterImageVmName.vm\$masterImageSnapshotName.snapshot"
$networkMapping = @{"0"="XDHyp:\HostingUnits\$hostingUnitName\$vpcName.virtualprivatecloud\$subnetName.network"}

# Set the custom properties
$CryptoKey = "$($ProjectId):$($Region):$($KeyRingName):$($CryptoKeyName)"
$CustomProperties = '<CustomProperties xmlns="http://schemas.citrix.com/2014/xd/machinecreation" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">' `
					+ '<Property xsi:type="StringProperty" Name="CryptoKeyId" Value="' + $CryptoKey +'"/>' `
					+ '</CustomProperties>'

# Create the ProvisioningScheme
$createdProvScheme = New-ProvScheme -CleanOnBoot:$isCleanOnBoot `
    -ProvisioningSchemeName $provisioningSchemeName `
    -HostingUnitName $hostingUnitName `
    -IdentityPoolName $identityPoolName `
    -InitialBatchSizeHint $numberOfVms `
    -MasterImageVM $masterImageVm `
    -NetworkMapping $networkMapping `
    -CustomProperties $customProperties

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