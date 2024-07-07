<#
.SYNOPSIS
    Creates an MCS catalog and provisions VMs into customer-supplied zones. Applicable for Citrix DaaS and on-prem.
.DESCRIPTION
    This script creates an MCS catalog and provisions VMs into a given zone(s).
    VMs and their resources will be provisioned into the zone specified by the CatalogZones custom property.
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
$masterImageSnapshotName = "snapshot-name"
$vpcName = "vpc-name"
$subnetName = "subnet-name"
$numberOfVms = 1
$Region = "us-central1"
$ProjectId = "project-id" # This is the id of the GCP project (not project name)
# Zones should be in the format 'projectId:region:zoneName'. In multi-zone scenario, separate zone IDs with comma e.g. $Zones = "$($ProjectId):$($Region):b,$($ProjectId):$($Region):c"
$Zones = "$($ProjectId):$($Region):b"

# [User Input Required] Set parameters for New-BrokerCatalog
$AllocationType = "Random"
$Description = "Sample description for catalog"
$PersistUserChanges = "Discard"
$SessionSupport = "MultiSession"

# Set paths for master image and network mapping
$masterImageVm = "XDHyp:\HostingUnits\$hostingUnitName\$masterImageVmName.vm\$masterImageSnapshotName.snapshot"
$networkMapping = @{"0"="XDHyp:\HostingUnits\$hostingUnitName\$vpcName.virtualprivatecloud\$subnetName.network"}

# Set the Zones custom property.
# You are allowed to specify more than one catalog zone in a comma separated format. In this case, MCS will internally pick a zone for the resources.
# If only one zone is specified, all the VMs in the catalog and respective resources will be provisioned in that zone.
# If no zone is specified, VMs will be provisioned in all zones randomly.
$CustomProperties = '<CustomProperties xmlns="http://schemas.citrix.com/2014/xd/machinecreation" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">' `
					+ '<Property xsi:type="StringProperty" Name="CatalogZones" Value="' + $Zones +'"/>' `
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
