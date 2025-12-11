<#
.SYNOPSIS
    Creates a provisioning scheme and a broker catalog with Azure Arc Onboarding enabled.
.DESCRIPTION
    Create-ProvScheme-WithAzureArc.ps1 creates an MCS Provisioning Scheme.
    The original version of this script is compatible with Citrix Virtual Apps and Desktops 7 2511 and VDA 2311 and up.
#>

# /*************************************************************************
# * Copyright © 2025. Cloud Software Group, Inc. All Rights Reserved.
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
$masterVmName= "demo-master"
$masterVmSnapshot= "demo-snapshot"
$masterImage = "XDHyp:\HostingUnits\$hostingUnitName\$masterVmName.vm\$masterVmSnapshot.snapshot"
$deviceID=((Get-SCVirtualMachine -Name $masterVmName|Get-SCVirtualNetworkAdapter).DeviceID).Split("\")[1]
$network = "demo-network-adapter.network"
$networkMapping =  @{$deviceID = "XDHyp:\HostingUnits\"+$hostingUnitName+"\"+$network}
$numberOfVms = 1

# [User Input Required] Set Arc parameters for New-ProvScheme
$azureArcSubscription = "subscriptionId-guid"
$azureArcRegion = "eastus"
$azureArcResourceGroup = "arc-resource-group"

# [User Input Required] Set the parameters for New-BrokerCatalog
$allocationType = "Random"
$description = "This is meant to be use as placeholders"
$persistUserChanges = "Discard"
$sessionSupport = "MultiSession"

# [User Input Required] Set parameters for New-AcctServiceAccount/Set-AcctServiceAccount
$tenantId = "tenantId-guid"
$applicationId = "applicationId-guid"
$applicationSecret = "applicationSecret-guid"
$secretExpiryTime = 2025-09-09
$identityProviderType = "AzureAD"

# Assign Service Account with 'AzureArcResourceManagement' Capability to Catalog IdentityPool
$identityPool = Get-AcctIdentityPool -IdentityPoolName $identityPoolName
if($identityPool -eq $null) {
	throw "IdentityPool does not exist"
}
$serviceAccount = Get-AcctServiceAccount
if ($serviceAccount -eq $null -or $serviceAccount.IdentityProviderIdentifier -ne $tenantId) {
    $secureString = ConvertTo-SecureString -String $applicationSecret -AsPlainText -Force
    $serviceAccount = New-AcctServiceAccount -IdentityProviderType $identityProviderType -IdentityProviderIdentifier $tenantId -AccountId $applicationId -AccountSecret $secureString -SecretExpiryTime $secretExpiryTime -Capabilities "AzureArcResourceManagement"
}
else {
	Set-AcctServiceAccount -ServiceAccountUid $serviceAccount.ServiceAccountUid -Capabilities "AzureArcResourceManagement"
}
Set-AcctIdentityPool -IdentityPoolUid $identityPool.IdentityPoolUid -ServiceAccountUid $serviceAccount.ServiceAccountUid

# Create the ProvisioningScheme
Write-Output "Creating the ProvisioningScheme"
$createdProvScheme = New-ProvScheme `
	-ProvisioningSchemeType "MCS" `
	-VMCpuCount 2 -VMMemoryMB 4096 `
	-CleanOnBoot:$isCleanOnBoot `
	-ProvisioningSchemeName $provisioningSchemeName `
	-HostingUnitName $hostingUnitName `
	-IdentityPoolName $identityPoolName `
	-InitialBatchSizeHint $numberOfVms `
	-MasterImageVM $masterImage `
	-NetworkMapping $networkMapping `
	-EnableAzureArcOnboarding `
	-AzureArcSubscription $azureArcSubscription `
	-AzureArcResourceGroup $azureArcResourceGroup `
	-AzureArcRegion $azureArcRegion

# Create the Broker Catalog. This allows you to see the catalog in Studio
Write-Output "Creating the BrokerCatalog"
New-BrokerCatalog -Name $provisioningSchemeName `
    -ProvisioningSchemeId $createdProvScheme.ProvisioningSchemeUid `
    -AllocationType $allocationType  `
    -Description $description `
    -IsRemotePC $False `
    -PersistUserChanges $persistUserChanges `
    -ProvisioningType "MCS" `
    -Scope @() `
    -SessionSupport $sessionSupport
	
