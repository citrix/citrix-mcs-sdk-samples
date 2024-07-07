<#
.SYNOPSIS
    Creates an MCS catalog using a VM as the MachineProfile source. Applicable for Citrix DaaS and on-prem.
.DESCRIPTION
    Create-MachineProfile-Instance creates an MCS ProvisioningScheme using a GCP Instance (VM) as a MachineProfile.
    VMs created from this provisioning scheme will be based on the provided VM.
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
$identityPoolName = $provisioningSchemeName # Identity pool must be created before running this script. You can refer to the sample scripts in "GCP\Identity\Create IdentityPool" to create one.
$hostingUnitName = "GcpHostingUnitName"
$masterImageVmName = "vm-name-to-be-used-as-masterimage"
$masterImageSnapshotName = "name-of-master-image-snapshot" # Snapshot of a VM assigned to $masterImageVmName which will be used as a master image
$machineProfileVmName = "machine-profile-vm" # Name of the VM to be used as a MachineProfile
$vpcName = "vpc-name" # Name of the VPC to be used. It should be one of the VPCs that was used while creating the Hosting Unit.
$subnetName = "subnet-name" # Name of the subnet to be used. It should be one of the subnets that was used while creating the Hosting Unit.
$numberOfVms = 1

# [User Input Required] Set parameters for New-BrokerCatalog
$AllocationType = "Random"
$Description = "Sample description for catalog"
$PersistUserChanges = "Discard"
$SessionSupport = "MultiSession"

# Set paths for master image and network mapping
$masterImageVm = "XDHyp:\HostingUnits\$hostingUnitName\$masterImageVmName.vm\$masterImageSnapshotName.snapshot"
$networkMapping = @{"0"="XDHyp:\HostingUnits\$hostingUnitName\$vpcName.virtualprivatecloud\$subnetName.network"}

# Set custom properties
$customProperties = '<CustomProperties xmlns="http://schemas.citrix.com/2014/xd/machinecreation" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"></CustomProperties>'

# Set the MachineProfile parameter
$machineProfile = "XDHyp:\HostingUnits\$hostingUnitName\$machineProfileVmName.vm"

# Create the ProvisioningScheme
$createdProvScheme = New-ProvScheme -CleanOnBoot:$isCleanOnBoot `
-ProvisioningSchemeName $provisioningSchemeName `
-HostingUnitName $hostingUnitName `
-IdentityPoolName $identityPoolName `
-InitialBatchSizeHint $numberOfVms `
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