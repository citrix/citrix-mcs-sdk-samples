<#
.SYNOPSIS
    Adds a VirtualMachine in a MCS catalog. Applicable for Citrix DaaS and on-prem.
.DESCRIPTION
    New-ProvVM.ps1 helps to add the VM on an existing MCS catalog.
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

# [User Input Required] Set parameters for New-AcctADAccount
# AD credentials are required to add machines to the catalog. These should be the domain credentials used to create AD Accounts
$adUsername = "demo-username"
$secureUserInput = Read-Host 'Please enter your AD password' -AsSecureString
$encryptedInput = ConvertFrom-SecureString -SecureString $secureUserInput
$adPassword = ConvertTo-SecureString -String $encryptedInput

$identityPoolName = "demo-identitypool"
$numberOfVms = 5

# [User Input Required] Set parameters for New-ProvVM
$provisioningSchemeName = "demo-provScheme"

# [User Input Required] Set parameters for New-BrokerMachine
$brokerCatalogs = Get-BrokerCatalog -Name $provisioningSchemeName

####################################
# Step 1: Create the AD Account(s) #
####################################
# Create the AD account(s)
$adAccounts = New-AcctADAccount -Count $numberOfVms -IdentityPoolName $identityPoolName -ADUserName $adUsername -ADPassword $adPassword

################################
# Step 5: Create the ProvVM(s) #
################################
# Create the ProvVM(s)
$newProvVmResult = New-ProvVM -ProvisioningSchemeName $provisioningSchemeName -ADAccountName $adAccounts.SuccessfulAccounts.ADAccountName

####################################
# Step 6: Create Broker Machine(s) #
####################################
# Get the VM ID(s)
$newProvVMSids = @($newProvVmResult.CreatedVirtualMachines | Select-Object ADAccountSid)

# Create Broker Machines of the new ProvVMs
$newBrokerMachines = $newProvVMSids | ForEach-Object { New-BrokerMachine -CatalogUid $brokerCatalogs[0].Uid -MachineName $_.ADAccountSid }