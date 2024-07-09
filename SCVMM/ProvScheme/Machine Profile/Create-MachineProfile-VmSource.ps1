<#
.SYNOPSIS
    Creates an MCS catalog using a VM as the MachineProfile source. Applicable for Citrix DaaS and on-prem.
.DESCRIPTION
    Create-ProvScheme creates an MCS ProvisioningScheme using a VM as the MachineProfile source.
    VMs created from this provisioning scheme will be based on the provided VM.
    The original version of this script is compatible with Citrix Virtual Apps and Desktops 7 2402 Long Term Service Release (LTSR).
#>

# /*************************************************************************
# * Copyright © 2024. Cloud Software Group, Inc. All Rights Reserved.
# * This file is subject to the license terms contained
# * in the license file that is distributed with this file.
# *************************************************************************/

################################
# Step 0: Setup the parameters #
################################
# Add Citrix snap-ins
Add-PSSnapin -Name "Citrix.Host.Admin.V2","Citrix.MachineCreation.Admin.V2"

# [User Input Required] Setup the parameters for New-ProvScheme
$isCleanOnBoot = $false
$provisioningSchemeName = "demo-provScheme"
$masterVmName= "demo-master"
$machineProfileVmName= "demo-machineprofile"
$masterVmSnapshot= "demo-snapshot"
$deviceID=((Get-SCVirtualMachine -Name $masterVmName|Get-SCVirtualNetworkAdapter).DeviceID).Split("\")[1]
$identityPoolName = $provisioningSchemeName
$hostingUnitName = "demo-hostingunit"
$network = "demo-network.network"
$networkMapping =  @{$deviceID = "XDHyp:\HostingUnits\"+$hostingUnitName+"\"+$network}
$numberOfVms = 1
$masterImage = "XDHyp:\HostingUnits\$hostingUnitName\$masterVmName.vm\$masterVmSnapshot.snapshot"
$machineProfile=  "XDHyp:\HostingUnits\$hostingUnitName\$machineProfileVmName.vm"


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
    -MasterImageVm $masterImage `
    -MachineProfile $machineProfile `
    -NetworkMapping $networkMapping `

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