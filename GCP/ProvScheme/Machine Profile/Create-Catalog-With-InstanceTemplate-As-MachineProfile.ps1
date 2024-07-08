<#
.SYNOPSIS
    Creates an MCS catalog using an Instance template as the MachineProfile source. Applicable for Citrix DaaS and on-prem.
.DESCRIPTION
    This script creates an MCS ProvisioningScheme and Broker catalog using an Instance Template as the MachineProfile source.
    VMs created from this provisioning scheme will be based on the provided instance template.
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
$IsCleanOnBoot = $false
$ProvisioningSchemeName = "demo-provScheme"
$IdentityPoolName = $ProvisioningSchemeName # Identity pool must be created before running this script. You can refer to the sample scripts in "GCP\Identity\Create IdentityPool" to create one.
$HostingUnitName = "GcpHostingUnitName"
$MasterImageVmName = "vm-name-to-be-used-as-masterimage"
$MasterImageSnapshotName = "name-of-master-image-snapshot"  # Snapshot of a VM assigned to $MasterImageVmName that will be used as a master image.
$InstanceTemplateName = "instance-template-name" # Name of the instance template to be used as a machine profile.
$VpcName = "vpc-name"  # Name of the VPC to be used. It should be one of the VPCs used while creating Hosting Unit.
$SubnetName = "subnet-name" # Name of the subnet to be used. It should be one of the subnets used while creating Hosting Unit.
$NumberOfVms = 1

# [User Input Required] Set parameters for New-BrokerCatalog
$AllocationType = "Random"
$Description = "Sample description for catalog"
$PersistUserChanges = "Discard"
$SessionSupport = "MultiSession"

# Set paths for master image and network mapping
$masterImageVm = "XDHyp:\HostingUnits\$HostingUnitName\$MasterImageVmName.vm\$MasterImageSnapshotName.snapshot"
$networkMapping = @{"0"="XDHyp:\HostingUnits\$HostingUnitName\$VpcName.virtualprivatecloud\$SubnetName.network"}

# Set custom properties
$customProperties = '<CustomProperties xmlns="http://schemas.citrix.com/2014/xd/machinecreation" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"></CustomProperties>'

# Set the MachineProfile parameter
$machineProfile = "XDHyp:\HostingUnits\$HostingUnitName\instanceTemplates.folder\$InstanceTemplateName.template"

# Create ProvisioningScheme
$createdProvScheme = New-ProvScheme -CleanOnBoot:$IsCleanOnBoot `
-ProvisioningSchemeName $ProvisioningSchemeName `
-HostingUnitName $HostingUnitName `
-IdentityPoolName $IdentityPoolName `
-InitialBatchSizeHint $NumberOfVms `
-MasterImageVM $masterImageVm `
-NetworkMapping $networkMapping `
-CustomProperties $customProperties `
-MachineProfile $machineProfile


# Create Broker catalog. This allows you to see and manage the catalog from Studio
New-BrokerCatalog -Name $ProvisioningSchemeName `
    -ProvisioningSchemeId $createdProvScheme.ProvisioningSchemeUid `
    -AllocationType $AllocationType `
    -Description $Description `
    -IsRemotePC $False `
    -PersistUserChanges $PersistUserChanges `
    -ProvisioningType "MCS" `
    -Scope @() `
    -SessionSupport $SessionSupport