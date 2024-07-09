<#
.SYNOPSIS
    Creates an MCS catalog. Applicable for Citrix DaaS and on-prem.
.DESCRIPTION
    Create-ProvScheme creates an MCS ProvisioningScheme and Broker Catalog.
    The original version of this script is compatible with Citrix Virtual Apps and Desktops 7 2203 Long Term Service Release (LTSR).
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
$masterVmSnapshot= "demo-snapshot"
$deviceID=((Get-SCVirtualMachine -Name $masterVmName|Get-SCVirtualNetworkAdapter).DeviceID).Split("\")[1]
$identityPoolName = $provisioningSchemeName
$network = "demo-network-adapter.network"
$hostingUnitName = "demo-hostingunit"
$networkMapping =  @{$deviceID = "XDHyp:\HostingUnits\"+$hostingUnitName+"\"+$network}
$numberOfVms = 1
$masterImage = "XDHyp:\HostingUnits\$hostingUnitName\$masterVmName.vm\$masterVmSnapshot.snapshot"


# [User Input Required] Setup the parameters for New-BrokerCatalog
$allocationType = "Random"
$description = "This is meant to be used as placeholders"
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