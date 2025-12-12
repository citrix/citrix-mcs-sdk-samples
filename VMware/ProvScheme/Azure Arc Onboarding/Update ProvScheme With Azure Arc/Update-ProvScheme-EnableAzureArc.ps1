<#
.SYNOPSIS
    Enable Azure Arc Onboarding on an existing MCS catalog. It also involves setting up ServiceAccount with AzureArcResourceManagement capability. This change is only applicable to the new machines added after the operation. The existing machines in the catalog are not affected. Applicable for Citrix DaaS and on-prem.
.DESCRIPTION
    Update-ProvScheme-EnableAzureArc.ps1 helps sets the Azure Arc Onboarding parameters on an existing MCS catalog.
    The original version of this script is compatible with Citrix Virtual Apps and Desktops 7 2511.
#>

# /*************************************************************************
# * Copyright © 2025. Cloud Software Group, Inc. All Rights Reserved.
# * This file is subject to the license terms contained
# * in the license file that is distributed with this file.
# *************************************************************************/

# Add Citrix snap-ins
Add-PSSnapin -Name "Citrix.Host.Admin.V2","Citrix.MachineCreation.Admin.V2","Citrix.Broker.Admin.V2"

#------------------------------ Enable AzureArc on existing ProvisioningScheme -------------------------------------#

# [User Input Required] Set parameters for Set-ProvScheme
$provisioningSchemeName = "demo-provScheme"
$enabledAzureArcOnboarding = $true
$azureArcSubscription = "subscriptionId-guid"
$azureArcRegion = "eastus"
$azureArcResourceGroup = "arc-resource-group"

# [User Input Required] Set parameters for New-AcctServiceAccount
$tenantId = "tenantId-guid"
$applicationId = "applicationId-guid"
$applicationSecret = "applicationSecret-guid"
$secretExpiryTime = 2025-09-09
$identityProviderType = "AzureAD"

# Enable Azure Arc Onboarding on existing catalog
Set-ProvScheme -ProvisioningSchemeName $provisioningSchemeName -EnableAzureArcOnboarding $EnableAzureArcOnboarding -AzureArcSubscriptionId $AzureArcSubscription -AzureArcRegion $AzureArcRegion -AzureArcResourceGroup $AzureArcResourceGroup

# Check or create the service account with 'AzureArcResourceManagement' Capability
$serviceAccount = Get-AcctServiceAccount
if ($serviceAccount -eq $null -or $serviceAccount.IdentityProviderIdentifier -ne $tenantId) {
    $secureString = ConvertTo-SecureString -String $applicationSecret -AsPlainText -Force
    $serviceAccount = New-AcctServiceAccount -IdentityProviderType $identityProviderType -IdentityProviderIdentifier $tenantId -AccountId $applicationId -AccountSecret $secureString -SecretExpiryTime $secretExpiryTime -Capabilities "AzureArcResourceManagement"
}
else {
	Set-AcctServiceAccount -ServiceAccountUid $serviceAccount.ServiceAccountUid -Capabilities "AzureArcResourceManagement"
}

# Assign ServiceAccountUid to existing AcctIdentityPool of the provisioning scheme.
Set-AcctIdentityPool -IdentityPoolName $provisioningSchemeName -ServiceAccountUid $ServiceAccount.ServiceAccountUid