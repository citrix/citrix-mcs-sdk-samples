<#
.SYNOPSIS
    Creates an MCS catalog and provisions VMs. Applicable for Citrix DaaS and on-prem. If running OnPrem, you may need to provide the -AdminAddress parameter to your commands.
.DESCRIPTION
    CreateCatalog.ps1 creates an MCS catalog and VMs in GCP.
    This script is similar to the "Create Machine Catalog" button in Citrix Studio. It creates the identity pool, ProvScheme, Broker Catalog, AD Accounts, and ProvVms.
    The original version of this script is compatible with Citrix Virtual Apps and Desktops 7 2203 Long Term Service Release (LTSR).
#>

# /*************************************************************************
# * Copyright © 2024. Cloud Software Group, Inc. All Rights Reserved.
# * This file is subject to the license terms contained
# * in the license file that is distributed with this file.
# *************************************************************************/

# Add Citrix snap-ins
Add-PSSnapin -Name "Citrix.Host.Admin.V2","Citrix.MachineCreation.Admin.V2"

# [User Input Required] Set parameters for New-AcctIdentityPool
$identityPoolName = "demo-identitypool"
$namingScheme = "demo-###"
$domain = "demo.local"
$zoneName = "gcp-zone"

# [User Input Required] Set parameters for New-ProvScheme
$isCleanOnBoot = $false
$provisioningSchemeName = "demo-provScheme"
$hostingUnitName = "GcpHostingUnitName"
$masterImageVmName = "demo-masterimage"
$masterImageSnapshotName = "demo-snapshot"
$vpcName = "vpc-name"
$subnetName = "subnet-name"
$machineProfileVmName = "demo-machineProfile"
$numberOfVms = 1

# [User Input Required] Set parameters for New-BrokerCatalog
$AllocationType = "Random"
$Description = "Sample description for catalog"
$PersistUserChanges = "Discard"
$SessionSupport = "MultiSession"

# [User Input Required] Set parameters for New-AcctADAccount
# AD credentials are required to add machines to the catalog. These should be the domain credentials used to create AD Accounts
$adUsername = "demo-username"
$secureUserInput = Read-Host 'Please enter your AD password' -AsSecureString
$encryptedInput = ConvertFrom-SecureString -SecureString $secureUserInput
$adPassword = ConvertTo-SecureString -String $encryptedInput

# Set paths for master image, network mapping and MachineProfile parameter
$masterImageVm = "XDHyp:\HostingUnits\$hostingUnitName\$masterImageVmName.vm\$masterImageSnapshotName.snapshot"
$networkMapping = @{"0"="XDHyp:\HostingUnits\$hostingUnitName\$vpcName.virtualprivatecloud\$subnetName.network"}
$machineProfile = "XDHyp:\HostingUnits\$hostingUnitName\$machineProfileVmName.vm"

##########################
# Step 1: Find Zone Uid. #
##########################
# [User Input Required]

$zone = Get-ConfigZone -Name $zoneName -ErrorAction 'SilentlyContinue'
# Gets the UID that corresponds to the Zone in which these AD accounts will be created.
$zoneUid = $zone.Uid
if($null -eq $zoneUid)
{
    throw "Could not find the zone (zoneName): $($zoneName). Verify that the zone exists."
}

####################################
# Step 2: Create the Identity Pool #
###################################

$isValidIdentityPoolName = Test-AcctIdentityPoolNameAvailable -IdentityPoolName $identityPoolName
if (-not $isValidIdentityPoolName.Available) {
    throw "IdentityPool with name '$($identityPoolName)' already exists. Please use another name."
}

$identityPool = New-AcctIdentityPool -IdentityPoolName $identityPoolName -NamingScheme $namingScheme -Domain $domain -NamingSchemeType Numeric -ZoneUid $zoneUid

# Return if New-AcctIdentityPool failed.
if ($null -eq $identityPool) {
    Write-Output "New-AcctIdentityPool Failed."
    return
}

#################################
# Step 3: Create the ProvScheme #
#################################

$isValidProvSchemeName = Test-ProvSchemeNameAvailable -ProvisioningSchemeName $provisioningSchemeName
if (-not $isValidProvSchemeName.Available) {
    throw "ProvScheme with name '$($provisioningSchemeName)' already exists. Please use another name."
}

# Set custom properties
$customProperties = '<CustomProperties xmlns="http://schemas.citrix.com/2014/xd/machinecreation" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"></CustomProperties>'

$provisioningScheme = New-ProvScheme -CleanOnBoot:$isCleanOnBoot `
-ProvisioningSchemeName $provisioningSchemeName `
-HostingUnitName $hostingUnitName `
-IdentityPoolName $identityPoolName `
-InitialBatchSizeHint $numberOfVms `
-MasterImageVM $masterImageVm `
-NetworkMapping $networkMapping `
-CustomProperties $customProperties `
-MachineProfile $machineProfile

# Return if New-ProvScheme failed.
if ($provisioningScheme.TaskState -ne "Finished") {
    Write-Output "New-ProvScheme Failed."
    $provisioningScheme
    return
}

#####################################
# Step 4: Create the Broker Catalog #
#####################################

$isValidBrokerCatalogName = Test-BrokerCatalogNameAvailable -Name $provisioningSchemeName
if (-not $isValidBrokerCatalogName.Available) {
    throw "BrokerCatalog with name '$($provisioningSchemeName)' already exists. Please use another name."
}

# Create Broker catalog. This allows you to see and manage the catalog from Studio
$brokerCatalog = New-BrokerCatalog -Name $ProvisioningSchemeName `
    -ProvisioningSchemeId $provisioningScheme.ProvisioningSchemeUid `
    -AllocationType $AllocationType `
    -Description $Description `
    -IsRemotePC $False `
    -PersistUserChanges $PersistUserChanges `
    -ProvisioningType "MCS" `
    -Scope @() `
    -SessionSupport $SessionSupport

# Return if New-BrokerCatalog failed.
if ($null -eq $brokerCatalog) {
    Write-Output "New-BrokerCatalog Failed."
    return
}

# Set Broker Catalog Metadata
$brokerCatalogMetadataName = "Citrix_DesktopStudio_IdentityPoolUid"
Set-BrokerCatalogMetadata -CatalogId $brokerCatalog.Uid -Name $brokerCatalogMetadataName -Value $identityPool.IdentityPoolUid

####################################
# Step 5: Create the AD Account(s) #
####################################

$adAccounts = New-AcctADAccount -Count $numberOfVms -IdentityPoolName $identityPoolName -ADUserName $adUsername -ADPassword $adPassword

# Return if New-AcctADAccount failed.
if ($adAccounts.SuccessfulAccountsCount -lt $numberOfVms)
{
    Write-Output "Failure creating AD Accounts. Attempted to make $numberOfVms AD accounts but only made $($adAccounts.SuccessfulAccountsCount)"
    $adAccounts
    return
}

################################
# Step 6: Create the ProvVM(s) #
################################

$newProvVmResult = New-ProvVM -ADAccountName $adAccounts.SuccessfulAccounts.ADAccountName -ProvisioningSchemeName $provisioningScheme.ProvisioningSchemeName

# Return if New-ProvVM failed.
if ($newProvVmResult.FailedVirtualMachines) {
    Write-Output "New-ProvVM Failed."
    return
}

##################################
# Step 7: Lock virtual machines. #
##################################

$newProvVMIds = @($newProvVmResult.CreatedVirtualMachines | Select-Object VMId)
Lock-ProvVM -ProvisioningSchemeName $provisioningSchemeName -Tag "Brokered" -VMID $newProvVMIds

####################################
# Step 8: Create Broker Machine(s) #
####################################

# Get the SIDs of the new ProvVMs
$newProvVMSids = @($newProvVmResult.CreatedVirtualMachines | Select-Object ADAccountSid)

# Create Broker Machines of the new ProvVMs
$newProvVMSids | ForEach-Object { New-BrokerMachine -CatalogUid $brokerCatalog.Uid -MachineName $_.ADAccountSid }