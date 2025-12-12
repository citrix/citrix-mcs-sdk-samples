<#
.SYNOPSIS
    Creates a ProvScheme with Azure Arc Onboarding enabled.
.DESCRIPTION
    Create-ProvScheme-WriteAzureArc.ps1 creates a ProvScheme that has Azure Arc Onboarding enabled.
    The original version of this script is compatible with Citrix Virtual Apps and Desktops 7 2511.
.INPUTS
    N/A
.OUTPUTS
    A New Provisioning Scheme Object
.NOTES
    Version      : 1.0.0
    Author       : Citrix Systems, Inc.
.EXAMPLE
    .\Create-ProvScheme-WriteAzureArc.ps1
#>

# /*************************************************************************
# * Copyright © 2025. Cloud Software Group, Inc. All Rights Reserved.
# * This file is subject to the license terms contained
# * in the license file that is distributed with this file.
# *************************************************************************/

# [User Input Required] Set parameters for New-ProvScheme
$ProvisioningSchemeName  = "MyMachineCatalog"
$IdentityPoolName        = "MyMachineCatalog"
$HostingUnitName         = "MyHostingUnit"
$ProvisioningSchemeType  = "MCS"
$MasterImageVM           = "XDHyp:\HostingUnits\MyHostingUnit\MyVM.vm\MySnapshot.snapshot"
$NetworkMapping          = @{"0"="XDHyp:\HostingUnits\MyHostingUnit\MyNetwork.network"}
$VMCpuCount              = 1
$VMemoryMB              = 1024
$InitialBatchSizeHint    = 1
$Scope                   = @()
$CustomProperties        = ""
$WriteBackCacheDiskSize = 128
$WriteBackCacheMemorySize = 256
$WriteBackCacheDriveLetter = "W"

# [User Input Required] Set Arc parameters for New-ProvScheme
$azureArcSubscription = "subscriptionId-guid"
$azureArcRegion = "eastus"
$azureArcResourceGroup = "arc-resource-group"

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

# Create a Provisoning Scheme
# The parameter -EnableAzureArcOnboarding is a flag to enable Azure Arc Onboarding.
# The parameters -AzureArcSubscription, -AzureArcResourceGroup, and -AzureArcRegion configure the Arc Onboarding.
New-ProvScheme `
    -ProvisioningSchemeName $ProvisioningSchemeName `
    -IdentityPoolName $IdentityPoolName `
    -HostingUnitName $HostingUnitName `
    -ProvisioningSchemeName $ProvisioningSchemeType `
    -MasterImageVM $MasterImageVM `
    -NetworkMapping $NetworkMapping `
    -VMCpuCount $VMCpuCount `
    -VMMemoryMB $VMemoryMB `
    -InitialBatchSizeHint $InitialBatchSizeHint `
    -Scope $Scope `
    -CustomProperties $CustomProperties `
    -CleanOnBoot `
    -EnableAzureArcOnboarding `
	-AzureArcSubscription $azureArcSubscription `
	-AzureArcResourceGroup $azureArcResourceGroup `
	-AzureArcRegion $azureArcRegion
