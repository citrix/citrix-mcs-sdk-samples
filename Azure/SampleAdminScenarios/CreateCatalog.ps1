<#
.SYNOPSIS
    Creates an MCS catalog and provisions VMs. Applicable for Citrix DaaS and on-prem. If running OnPrem, you may need to provide the -AdminAddress parameter to your commands.
.DESCRIPTION
    CreateCatalog creates an MCS catalog and VMs in Azure.
    This script is similar to the "Create Machine Catalog" button in Citrix Studio. It creates the identity pool, ProvScheme, Broker Catalog, AD Accounts, and ProvVms. It also creates a Hosting Connection and Hosting Unit, which are prerequisites for creating an MCS catalog.
    The original version of this script is compatible with Citrix Virtual Apps and Desktops 7 2203 Long Term Service Release (LTSR).
#>

# /*************************************************************************
# * Copyright © 2024. Cloud Software Group, Inc. All Rights Reserved.
# * This file is subject to the license terms contained
# * in the license file that is distributed with this file.
# *************************************************************************/

# Add Citrix snap-ins
Add-PSSnapin -Name "Citrix.Host.Admin.V2","Citrix.MachineCreation.Admin.V2","Citrix.Broker.Admin.V2"

#####################################################
# Step 0: Set parameters #
#####################################################
# [User Input Required] Set parameters for new hypervisor connection
$ConnectionName = "AzureConnection"
$UserName = "AppId" 					# Azure application ID
$SubscriptionId = "SubscriptionId"		# Azure subscription ID
$TenantId = "TenantId"					# Azure AD Directory ID
$ResourceLocation = "ResourceLocation"					# Zone/resource location
$secureUserInput = Read-Host 'Please enter your application secret' -AsSecureString
$encryptedInput = ConvertFrom-SecureString -SecureString $secureUserInput
$SecureApplicationPassword = ConvertTo-SecureString -String $encryptedInput

# [User Input Required] Set parameters for new hosting unit
$AzureRegion = "AzureRegion"
$AzureNetwork = "AzureNetwork"
$AzureSubnet ="AzureSubnet"
$HostingUnitName ="AzureHostingUnitName"
$AzureResourceGroupForNetwork = "AzureResourceGroup"

# [User Input Required] Set parameters for New-AcctIdentityPool
$identityPoolName = "demo-identitypool"
$namingScheme = "demo-###"
$domain = "demo.local"

# [User Input Required] Set parameters for New-ProvScheme
$isCleanOnBoot = $false
$provisioningSchemeName = "demo-provScheme"
$machineProfileResourceGroupName = "demo-machineProfileResourceGroupName"
$masterImageResourceGroupName = "demo-masterImageResourceGroupName"
$masterImageSnapshotName = "demo-snapshot"
$machineProfileVmName = "demo-machineProfile"
$numberOfVms = 2
$nicDevicePosition = "0"

# [User Input Required] Set parameters for New-BrokerCatalog
$allocationType = "Static"          # AllocationType determines if a user gets the same machine each time the attempt to access a machine via a delivery group. Can be 'Random' or 'Static'
$persistUserChanges = "OnLocal"     # PersistUserChanges determines if the machine is "reset" after the user logs off. Can be 'Discard' or 'OnLocal'
$sessionSupport = "SingleSession"   # SingleSession implies a Desktop experience and MultiSession implies a Server

# [User Input Required] Set parameters for New-AcctADAccount
# AD credentials are required to add machines to the catalog. These should be the domain credentials used to create AD Accounts
$adUsername = "demo-username"
$secureUserInput = Read-Host 'Please enter your AD password' -AsSecureString
$encryptedInput = ConvertFrom-SecureString -SecureString $secureUserInput
$adPassword = ConvertTo-SecureString -String $encryptedInput

# Find the Zone Uid
$zone = Get-ConfigZone -Name $ResourceLocation -ErrorAction 'SilentlyContinue'
$zoneUid = $zone.Uid
if($null -eq $zoneUid)
{
    throw "Could not find the zone (resourceLocation): $($ResourceLocation). Verify the resourceLocation exists or try the default 'Primary.'"
}


#####################################################
# Step 1: Create the Hosting Connection #
#####################################################
Write-Output "Step 1 Create the Hosting Connection"

$HypervisorAddress = "https://management.azure.com/"
$Metadata = @{
    "Citrix_Broker_MaxAbsoluteNewActionsPerMinute"="2000";
    "Citrix_Broker_MaxPowerActionsPercentageOfDesktops"="100";
    "Citrix_Broker_MaxAbsolutePvDPowerActions"="50";
    "Citrix_Broker_MaxAbsoluteActiveActions"="500";
    "Citrix_Broker_MaxPvdPowerActionsPercentageOfDesktops"="25";
	"Citrix_Broker_ExtraSpinUpTime"="240"
}

$CustomProperties = '<CustomProperties xmlns="http://schemas.citrix.com/2014/xd/machinecreation" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">' `
+ '<Property xsi:type="StringProperty" Name="SubscriptionId" Value="' + $SubscriptionId + '" />'`
+ '<Property xsi:type="StringProperty" Name="ManagementEndpoint" Value="https://management.azure.com/" />'`
+ '<Property xsi:type="StringProperty" Name="AuthenticationAuthority" Value="https://login.microsoftonline.com/" />'`
+ '<Property xsi:type="StringProperty" Name="StorageSuffix" Value="core.windows.net" />'`
+ '<Property xsi:type="StringProperty" Name="TenantId" Value="' + $TenantId + '" />'`
+ '</CustomProperties>'


$connection = New-Item -ConnectionType "Custom" `
	-CustomProperties $CustomProperties `
	-HypervisorAddress @($HypervisorAddress) `
	-Path @("XDHyp:\Connections\$($ConnectionName)") `
	-Metadata $Metadata `
	-Persist `
	-PluginId "AzureRmFactory" `
	-Scope @() `
	-SecurePassword $SecureApplicationPassword `
	-UserName $UserName `
	-ZoneUid $zoneUid

New-BrokerHypervisorConnection -HypHypervisorConnectionUid $connection.HypervisorConnectionUid

#####################################################
# Step 2: Create the Hosting Unit #
#####################################################
Write-Output "Step 2 Create the Hosting Unit"

$RootPath = "XDHyp:\Connections\$($ConnectionName)\" + $AzureRegion + ".region"
# Note - For this example, a single network is used. For a multi-network scenario, add more subnet paths with the same format and put a comma as separator.
$NetworkPath = "XDHyp:\Connections\" + $ConnectionName + "\" + $AzureRegion + ".region\virtualprivatecloud.folder\" + $AzureResourceGroupForNetwork + ".resourcegroup\" + `
$AzureNetwork + ".virtualprivatecloud\" + $AzureSubnet + ".network"
$HostingUnitPath = "XDHyp:\HostingUnits\$HostingUnitName"

New-Item -HypervisorConnectionName  $ConnectionName `
	-NetworkPath @($NetworkPath) `
	-Path @($HostingUnitPath) `
	-PersonalvDiskStoragePath @() `
	-RootPath $RootPath `
	-StoragePath @()

#####################################################
# Step 3: Create the Identity Pool #
#####################################################
Write-Output "Step 3 Create the Identity Pool"
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

#####################################################
# Step 4: Create the ProvScheme #
#####################################################
Write-Output "Step 4 Create the Provisioning Scheme"
$isValidProvSchemeName = Test-ProvSchemeNameAvailable -ProvisioningSchemeName $provisioningSchemeName
if (-not $isValidProvSchemeName.Available) {
    throw "ProvScheme with name '$($provisioningSchemeName)' already exists. Please use another name."
}

$masterImageVm = "XDHyp:\HostingUnits\$HostingUnitName\image.folder\$masterImageResourceGroupName.resourcegroup\$masterImageSnapshotName.snapshot"
$networkMapping = @{$nicDevicePosition="XDHyp:\HostingUnits\$HostingUnitName\$AzureRegion.region\virtualprivatecloud.folder\$AzureResourceGroupForNetwork.resourcegroup\$AzureNetwork.virtualprivatecloud\$AzureSubnet.network"}
$machineProfilePath = "XDHyp:\HostingUnits\$HostingUnitName\machineprofile.folder\$machineProfileResourceGroupName.resourcegroup\$machineProfileVmName.vm"

$customProperties = @"
<CustomProperties xmlns="http://schemas.citrix.com/2014/xd/machinecreation" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">
<Property xsi:type="StringProperty" Name="UseManagedDisks" Value="true"/>
</CustomProperties>
"@

$provisioningScheme = New-ProvScheme -CleanOnBoot:$isCleanOnBoot `
-ProvisioningSchemeName $provisioningSchemeName `
-HostingUnitName $HostingUnitName `
-IdentityPoolName $identityPoolName `
-InitialBatchSizeHint $numberOfVms `
-MasterImageVM $masterImageVm `
-NetworkMapping $networkMapping `
-CustomProperties $customProperties `
-MachineProfile $machineProfilePath

# Return if New-ProvScheme failed.
if ($provisioningScheme.TaskState -ne "Finished"){
    Write-Output "New-ProvScheme Failed."
    $provisioningScheme
    return
}

#####################################################
# Step 5: Create the Broker Catalog #
#####################################################
Write-Output "Step 5 Create the Broker Catalog"
$isValidBrokerCatalogName = Test-BrokerCatalogNameAvailable -Name $provisioningSchemeName
if (-not $isValidBrokerCatalogName.Available) {
    throw "BrokerCatalog with name '$($provisioningSchemeName)' already exists. Please use another name."
}

$brokerCatalog = New-BrokerCatalog -AllocationType $allocationType -IsRemotePC $False -Name $provisioningSchemeName -PersistUserChanges $persistUserChanges -ProvisioningType "MCS" -Scope @() -SessionSupport $sessionSupport -ProvisioningSchemeId $provisioningScheme.ProvisioningSchemeUid -ZoneUid $zoneUid

# Return if New-BrokerCatalog failed.
if ($null -eq $brokerCatalog) {
    Write-Output "New-BrokerCatalog Failed."
    return
}

# Set Broker Catalog Metadata
$brokerCatalogMetadataName = "Citrix_DesktopStudio_IdentityPoolUid"
Set-BrokerCatalogMetadata -CatalogId $brokerCatalog.Uid -Name $brokerCatalogMetadataName -Value $identityPool.IdentityPoolUid

#####################################################
# Step 6: Create the AD Account(s) #
#####################################################
Write-Output "Step 6 Create the AD Account(s)"
$adAccounts = New-AcctADAccount -Count $numberOfVms -IdentityPoolName $identityPoolName -ADUserName $adUsername -ADPassword $adPassword

# Return if New-AcctADAccount failed.
if ($adAccounts.SuccessfulAccountsCount -lt $numberOfVms)
{
    Write-Output "Failure creating AD Accounts. Attempted to make $numberOfVms AD accounts but only made $($adAccounts.SuccessfulAccountsCount)"
    $adAccounts
    return
}

#####################################################
# Step 7: Create the ProvVM(s) #
#####################################################
Write-Output "Step 7 Create the ProvVM(s)"
$newProvVmResult = New-ProvVM -ADAccountName $adAccounts.SuccessfulAccounts.ADAccountName -ProvisioningSchemeName $provisioningScheme.ProvisioningSchemeName

# Return if New-ProvVM failed.
if ($newProvVmResult.FailedVirtualMachines) {
    Write-Output "New-ProvVM Failed."
    return
}

# Lock the new ProvVMs
$newProvVMIds = @($newProvVmResult.CreatedVirtualMachines | Select-Object VMId)
Lock-ProvVM -ProvisioningSchemeName $provisioningSchemeName -Tag "Brokered" -VMID $newProvVMIds

####################################
# Step 8: Create Broker Machine(s) #
####################################
Write-Output "Step 8 Create Broker Machine(s)"
# Get the SIDs of the new ProvVMs
$newProvVMSids = @($newProvVmResult.CreatedVirtualMachines | Select-Object ADAccountSid)

# Create Broker Machines of the new ProvVMs
$newProvVMSids | ForEach-Object { New-BrokerMachine -CatalogUid $brokerCatalog.Uid -MachineName $_.ADAccountSid }