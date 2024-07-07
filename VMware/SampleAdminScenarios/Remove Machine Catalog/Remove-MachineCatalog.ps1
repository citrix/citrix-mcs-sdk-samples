<#
.SYNOPSIS
    Deletes a machine catalog.
.DESCRIPTION
    The `Remove-MachineCatalog.ps1` script returns the detail of an identity pool.
    The original version of this script is compatible with Citrix Virtual Apps and Desktops 7 2203 Long Term Service Release (LTSR).
.INPUTS
    1. ProvisioningSchemeName: Name of the Machine Catalog to be deleted.
    2. Domain: The AD Domain name.
    3. UserName: The User Name for Authentication
    4. AdminAddress: The primary DDC address.

    Additionally, the script supports these optional parameters:

    5. PurgeDBOnly: A flag to remove VM records from the Machine Creation Services database without deleting the actual VMs and hard disk copies from the hypervisor.
    6. ForgetVM: A flag to disassociate VMs from Citrix management, removing Citrix-specific tags/identifiers, while retaining the VMs and hard disk copies in the hypervisor.

.OUTPUTS
    N/A
.NOTES
    Version      : 1.0.0
    Author       : Citrix Systems, Inc.
.EXAMPLE
    # Delete a ProvScheme with AD Domain Credentials.
    .\Remove-MachineCatalog.ps1 `
        -ProvisioningSchemeName "MyIdentityPool" `
        -Domain "MyDomain.local" `
        -UserName "MyUserName" `
        -AdminAddress "MyDDC.MyDomain.local"

    # Delete a ProvScheme with PurgeDBOnly
    .\Remove-MachineCatalog.ps1 `
        -ProvisioningSchemeName "MyIdentityPool" `
        -Domain "MyDomain.local" `
        -UserName "MyUserName" `
        -AdminAddress "MyDDC.MyDomain.local" `
        -PurgeDBOnly $True

    # Delete a ProvScheme with ForgetVM
    .\Remove-MachineCatalog.ps1 `
        -ProvisioningSchemeName "MyIdentityPool" `
        -Domain "MyDomain.local" `
        -UserName "MyUserName" `
        -AdminAddress "MyDDC.MyDomain.local" `
        -ForgetVM $True
#>

# /*************************************************************************
# * Copyright © 2024. Cloud Software Group, Inc. All Rights Reserved.
# * This file is subject to the license terms contained
# * in the license file that is distributed with this file.
# *************************************************************************/

param(
    [string] $ProvisioningSchemeName,
    [string] $Domain,
    [string] $UserName,
    [string] $AdminAddress = $null,
    [switch] $PurgeDBOnly = $false,
    [switch] $ForgetVM = $false
)

# Enable Citrix PowerShell Cmdlets
Add-PSSnapin citrix*

if ($PurgeDBOnly -and $ForgetVM) {
    Write-Output "Please specify either $PurgeDBOnly or $ForgetVM, but not both. Specifying both parameters simultaneously is not supported."
    exit
}

####################################
# Step 1: Remove Broker Machine(s) #
####################################
Write-Output "Step 1: Remove Broker Machine(s)"

# Get the broker machines to remove
$brokerMachines = Get-BrokerMachine -CatalogName $ProvisioningSchemeName

# Remove Broker Machines
$brokerMachines | ForEach-Object {
    # Configure the common parameters for Remove-BrokerMachine.
    $removeBrokerMachineParameters = @{
        MachineName = $_.MachineName
        Force = $true
    }

    # If operating in an On-Prem environment, configure the AdminAddress.
    if ($AdminAddress) { $removeBrokerMachineParameters['AdminAddress'] = $AdminAddress }

    # Remove Broker Machines
    & Remove-BrokerMachine @removeBrokerMachineParameters
}

############################
# Step 2: Remove ProvVM(s) #
############################
Write-Output "Step 2: Remove ProvVM(s)"

# Unlock the ProvVM
$vmIds = @(Get-ProvVM -ProvisioningSchemeName $ProvisioningSchemeName | Select-Object VMId)

# Configure the common parameters for Unlock-ProvVM.
$unlockProvVMParameters = @{
    ProvisioningSchemeName = $ProvisioningSchemeName
    VMID = $vmIds.VMId
}

# If operating in an On-Prem environment, configure the AdminAddress.
if ($AdminAddress) { $unlockProvVMParameters['AdminAddress'] = $AdminAddress }

# Unlock the ProvVM
& Unlock-ProvVM @unlockProvVMParameters

# Get the VM Names to remove
$vmNames = @(Get-ProvVM -ProvisioningSchemeName $ProvisioningSchemeName | Select-Object -ExpandProperty VMName)

# Configure the parameters for Remove-ProvVM.
$removeProvVMParameters = @{
    ProvisioningSchemeName  = $ProvisioningSchemeName
    VMName = $vmNames
    PurgeDBOnly = $PurgeDBOnly
    ForgetVM = $ForgetVM
}

# If operating in an On-Prem environment, configure the AdminAddress.
if ($AdminAddress) { $removeProvVMParameters['AdminAddress'] = $AdminAddress }

# Remove ProvVMs.
$removeProvVMResult = & Remove-ProvVM @removeProvVMParameters
$removeProvVMResult

###################################
# Step 3: Remove AcctADAccount(s) #
###################################
Write-Output "Step 3: Remove AcctADAccount(s)"

# Get the SIds of AD Accounts.
$adAccountSid = @(Get-AcctADAccount -IdentityPoolName $ProvisioningSchemeName | Select-Object ADAccountSid)

# Build the AD Account User Name
$adUserName = "$Domain\$UserName"

# Build the secure password
$SecurePasswordInput = Read-Host $"Please enter the Active Directory password for the user $UserName" -AsSecureString
$EncryptedPasswordInput = $SecurePasswordInput | ConvertFrom-SecureString
$securedPassword = ConvertTo-SecureString -String $EncryptedPasswordInput

# Build the Parameters for Remove-AcctADAccount
$removeAcctADAccountParameters = @{
    IdentityPoolName = $ProvisioningSchemeName
    ADUserName = $adUserName
    ADPassword = $securedPassword
    ADAccountSid = $adAccountSid
    RemovalOption = "Delete"
    Force = $true
}

# If operating in an On-Prem environment, configure the AdminAddress.
if ($AdminAddress) { $removeAcctADAccountParameters['AdminAddress'] = $AdminAddress }

# Remove the AD Accounts.
& Remove-AcctADAccount @removeAcctADAccountParameters

###################################
# Step 4: Remove AcctIdentityPool #
###################################
Write-Output "Step 4: Remove AcctIdentityPool"

# Configure the common parameters for Remove-AcctIdentityPool.
$removeAcctIdentityPoolParameters = @{
    IdentityPoolName  = $ProvisioningSchemeName
}

# If operating in an On-Prem environment, configure the AdminAddress.
if ($AdminAddress) { $removeAcctIdentityPoolParameters['AdminAddress'] = $AdminAddress }

# Remove the AcctIdentityPool.
& Remove-AcctIdentityPool @removeAcctIdentityPoolParameters

#################################
# Step 5: Remove Broker Catalog #
#################################
Write-Output "Step 5: Remove Broker Catalog"

# Configure the common parameters for Remove-BrokerCatalog.
$removeBrokerCatalogParameters = @{
    Name  = $ProvisioningSchemeName
}

# If operating in an On-Prem environment, configure the AdminAddress.
if ($AdminAddress) { $removeBrokerCatalogParameters['AdminAddress'] = $AdminAddress }

# Remove the Broker Catalog
& Remove-BrokerCatalog @removeBrokerCatalogParameters

##########################################
# Step 6: Remove the Provisioning Scheme #
##########################################
Write-Output "Step 6: Remove the Provisioning Scheme"

# Configure the common parameters for Remove-ProvScheme.
$removeProvSchemeParameters = @{
    ProvisioningSchemeName  = $ProvisioningSchemeName
}

# If operating in an On-Prem environment, configure the AdminAddress.
if ($AdminAddress) { $removeProvSchemeParameters['AdminAddress'] = $AdminAddress }

# Configure additional parameters for Remove-ProvScheme, e.g., PurgeDBOnly or ForgetVM.
if ($PurgeDBOnly) {
    $removeProvSchemeParameters['PurgeDBOnly'] = $true
} elseif ($ForgetVM) {
    $removeProvSchemeParameters['ForgetVM'] = $true
}

# Remove ProvVMs.
$removeProvSchemeResult = & Remove-ProvScheme @removeProvSchemeParameters
$removeProvSchemeResult

##############################
# Step 7: Remove ProvTask(s) #
##############################
Write-Output "Step 7: # Remove ProvTask(s)."

# Delete completed tasks creating Provisioning Scheme and ProvVMs
Remove-ProvTask -TaskId $removeProvVMResult.TaskId | Out-Null
Remove-ProvTask -TaskId $removeProvSchemeResult.TaskId | Out-Null
