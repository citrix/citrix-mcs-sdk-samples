<#
.SYNOPSIS
    Adds a VirtualMachine in a MCS catalog. Applicable for Citrix DaaS and on-prem.
.DESCRIPTION
    New-ProvVM.ps1 helps to add the VM on an existing MCS catalog.
    The original version of this script is compatible with Citrix Virtual Apps and Desktops 7 2203 Long Term Service Release (LTSR).
#>

# /*************************************************************************
# * Copyright © 2024. Cloud Software Group, Inc.
# * This file is subject to the license terms contained
# * in the license file that is distributed with this file.
# *************************************************************************/

# Add Citrix snap-ins
Add-PSSnapin -Name "Citrix.Host.Admin.V2","Citrix.MachineCreation.Admin.V2","Citrix.Broker.Admin.V2","Citrix.ADIdentity.Admin.V2"

# [User Input Required] Set parameters for New-ProvVM
$provisioningSchemeName = "demo-provScheme"
$numberOfVms = 5
$userName = "demo-username"
$identityPoolName = "demo-identityPoolName"
$catalogName = "demo-catalog"

$brokerCatalogs = Get-BrokerCatalog -Name $catalogName

##########################################################################################
# Step 1: Adds a Active Directory (AD) computer accounts in the specified identity pool. #
##########################################################################################

$secureUserInput = Read-Host 'Please enter your AD password' -AsSecureString
$encryptedInput = ConvertFrom-SecureString -SecureString $secureUserInput
$adPassword = ConvertTo-SecureString -String $encryptedInput

$accounts = New-AcctADAccount -ADUserName $userName -ADPassword $adPassword -Count $numberOfVms -IdentityPoolName $identityPoolName
if ($accounts.FailedAccounts.Count -ge 1)
{
    $failedAccounts = $accounts.FailedAccounts.Count
    $errorReason = $adAccounts.FailedAccounts.DiagnosticInformation
    throw "$failedAccounts AD accounts failed to be created, with the failure attributed to $errorReason."
}

############################################################################
# Step 2: Creates virtual machines in the provided ProvisioningSchemeName. #
############################################################################

$newProvVms = New-ProvVM -ProvisioningSchemeName $provisioningSchemeName -ADAccountName $accounts.SuccessfulAccounts.ADAccountName
if($newProvVms.VirtualMachinesCreatedCount -ne $numberOfVms)
{
    $failedProvVms = $newProvVms.VirtualMachinesCreationFailedCount
    $diagnosticInfo = $newProvVms.FailedVirtualMachines
    throw "$failedProvVms virtual machines failed to be created, with the failure attributed to $diagnosticInfo."
}

#############################################################################
# Step 3: Creates Broker machines to the above created VMs inside a Catalog #
#############################################################################

$newProvVMSids = @($newProvVms.CreatedVirtualMachines | Select-Object ADAccountSid)
$newBrokerMachines = $newProvVMSids | ForEach-Object { New-BrokerMachine -CatalogUid $brokerCatalogs[0].Uid -MachineName $_.ADAccountSid }
$newBrokerMachines