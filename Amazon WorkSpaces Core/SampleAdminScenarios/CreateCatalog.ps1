<#
.SYNOPSIS
    Creates an MCS catalog and provisions VMs. Applicable for Citrix DaaS and on-prem.
.DESCRIPTION
    CreateCatalog creates an MCS catalog and VMs in AWS.
    This script is similar to the "Create Machine Catalog" button in Citrix Studio. It creates the identity pool, ProvScheme, Broker Catalog, AD Accounts, and ProvVms.
    The original version of this script is compatible with Citrix DaaS July 2025 Release (DDC 125).
#>

# /*************************************************************************
# * Copyright © 2025. Cloud Software Group, Inc. All Rights Reserved.
# * This file is subject to the license terms contained
# * in the license file that is distributed with this file.
# *************************************************************************/

# Add Citrix snap-ins
Add-PSSnapin -Name "Citrix.Host.Admin.V2","Citrix.MachineCreation.Admin.V2"

#####################################################
# Step 1: Create the Identity Pool #
#####################################################
# [User Input Required] Set parameters for New-AcctIdentityPool
$identityPoolName = "demo-identitypool"
$namingScheme = "demo-###"
$domain = "demo.local"
$namingSchemeType = "Numeric"
$zoneUid = "00000000-0000-0000-0000-000000000000"

# Create Identity Pool
Write-Output "Step 1 Create the Identity Pool"
$isValidIdentityPoolName = Test-AcctIdentityPoolNameAvailable -IdentityPoolName $identityPoolName
if (-not $isValidIdentityPoolName.Available) {
    throw "IdentityPool with name '$($identityPoolName)' already exists. Please use another name."
}
New-AcctIdentityPool -IdentityPoolName $identityPoolName -NamingScheme $namingScheme -NamingSchemeType $namingSchemeType -Domain $domain -ZoneUid $zoneUid

# Return if New-AcctIdentityPool failed.
if ($null -eq (Get-AcctIdentityPool -IdentityPoolName $identityPoolName))
{
    Write-Output "New-AcctIdentityPool Failed."
    return
}

#####################################################
# Step 2: Create the ProvScheme #
#####################################################
# [User Input Required] Setup parameters for New-ProvScheme
$isCleanOnBoot = $true
$provisioningSchemeName = "demo-provScheme"
$availabilityZone = "us-east-1a.availabilityzone"
$hostingUnitName = "demo-hostingunit"
$numberOfVms = 5

# The ImageVersionSpecUid is returned when creating a prepared image (See 'Image Management')
$imageVersionSpecUid = "00000000-0000-0000-0000-000000000000"

$machineProfile = "XDHyp:\HostingUnits\$hostingUnitName\$availabilityZone\Demo Machine Profile VM (i-012345678910).vm"

# Create Provisioning Scheme
Write-Output "Step 2 Create the Provisioning Scheme"
$isValidProvSchemeName = Test-ProvSchemeNameAvailable -ProvisioningSchemeName $provisioningSchemeName
if (-not $isValidProvSchemeName.Available) {
    throw "ProvScheme with name '$($provisioningSchemeName)' already exists. Please use another name."
}
$createdProvScheme = New-ProvScheme -ProvisioningSchemeName $provisioningSchemeName `
    -CleanOnBoot:$isCleanOnBoot `
    -HostingUnitName $hostingUnitName `
    -IdentityPoolName $identityPoolName `
    -InitialBatchSizeHint $numberOfVms `
    -ImageVersionSpecUid $imageVersionSpecUid `
    -MachineProfile $machineProfile

# Return if New-ProvScheme failed.
if ($createdProvScheme.TaskState -ne "Finished"){
    Write-Output "New-ProvScheme Failed."
    $createdProvScheme
    return
}

#####################################
# Step 3: Create the Broker Catalog #
#####################################
# [User Input Required] Setup parameters for New-BrokerCatalog
$allocationType = "Random"
$description = "This is meant to be use as placeholders"
$persistUserChanges = "Discard"
$sessionSupport = "MultiSession"

# Create the Broker Catalog. This will allow you to see the catalog in Studio
Write-Output "Step 3 Create the Broker Catalog"
$brokerCatalog = New-BrokerCatalog -Name $ProvisioningSchemeName `
    -ProvisioningSchemeId $createdProvScheme.ProvisioningSchemeUid `
    -AllocationType $allocationType  `
    -Description $description `
    -IsRemotePC $False `
    -PersistUserChanges $persistUserChanges `
    -ProvisioningType "MCS" `
    -Scope @() `
    -SessionSupport $sessionSupport

# Return if New-BrokerCatalog failed.
if ($null -eq (Get-BrokerCatalog -Name $ProvisioningSchemeName)) {
    Write-Output "New-BrokerCatalog Failed."
    return
}

#####################################################
# Step 4: Create the AD Account(s) #
#####################################################
# [User Input Required] Set parameters for New-AcctADAccount
# AD credentials are required to add machines to the catalog. These should be the domain credentials used to create AD Accounts
$adUsername = "demo-username"
$secureUserInput = Read-Host 'Please enter your AD password' -AsSecureString
$encryptedInput = ConvertFrom-SecureString -SecureString $secureUserInput
$adPassword = ConvertTo-SecureString -String $encryptedInput

Write-Output "Step 4 Create the AD Account(s)"
$adAccounts = New-AcctADAccount -Count $numberOfVms -IdentityPoolName $identityPoolName -ADUserName $adUsername -ADPassword $adPassword

# Return if New-AcctADAccount failed.
if ($adAccounts.SuccessfulAccountsCount -lt $numberOfVms)
{
    Write-Output "Failure creating AD Accounts. Attempted to make $numberOfVms AD accounts but only made $($adAccounts.SuccessfulAccountsCount)"
    $adAccounts
    return
}

#####################################################
# Step 5: Create the ProvVM(s) #
#####################################################
# With the AD accounts, create ProvVMs
Write-Output "Step 5 Create the ProvVM(s)"
$newProvVmResult = New-ProvVM -ProvisioningSchemeName $provisioningSchemeName -ADAccountName $adAccounts.SuccessfulAccounts.ADAccountName

# Return if New-ProvVM failed.
if ($newProvVmResult.FailedVirtualMachines) {
    Write-Output "New-ProvVM Failed."
    return
}

####################################
# Step 6: Create Broker Machine(s) #
####################################
# Create Broker Machines of the new ProvVMs
Write-Output "Step 6 Create the Broker Machine(s)"
$newProvVMSids = @($newProvVmResult.CreatedVirtualMachines | Select-Object ADAccountSid)
$newProvVMSids | ForEach-Object { New-BrokerMachine -CatalogUid $brokerCatalog.Uid -MachineName $_.ADAccountSid }