<#
.SYNOPSIS
    Removes VMs from a machine catalog.
.DESCRIPTION
    The `Remove-ProvVM.ps1` script removes VMs from a machine catalog.
    The original version of this script is compatible with Citrix Virtual Apps and Desktops 7 2203 Long Term Service Release (LTSR).
.INPUTS
    1. ProvisioningSchemeName: The name of the provisioning scheme where VMs will be removed.
    2. VmNamesToRemove: The names of VMs to be removed.
    3. Domain: The AD Domain name.
    4. UserName: The User Name for Authentication
    5. AdminAddress: The primary DDC address.

    Additionally, the script supports these optional parameters:

    6. PurgeDBOnly: A flag to remove VM records from the Machine Creation Services database without deleting the actual VMs and hard disk copies from the hypervisor.
    7. ForgetVM: A flag to disassociate VMs from Citrix management, removing Citrix-specific tags/identifiers, while retaining the VMs and hard disk copies in the hypervisor.
.OUTPUTS
    N/A
.NOTES
    Version      : 1.0.0
    Author       : Citrix Systems, Inc.
.EXAMPLE
    # Remove VMs with AD Credentials
    .\Remove-ProvVM.ps1 `
        -ProvisioningSchemeName "MyCatalog" `
        -VmNamesToRemove "MyVM001", "MyVM002" `
        -Domain "MyDomain.local" `
        -UserName "MyUserName" `
        -AdminAddress "MyDDC.MyDomain.local"

    # Remove VMs with PurgeDBOnly
    .\Remove-ProvVM.ps1 `
        -ProvisioningSchemeName "MyCatalog" `
        -VmNamesToRemove "MyVM001", "MyVM002" `
        -Domain "MyDomain.local" `
        -UserName "MyUserName" `
        -PurgeDBOnly $True `
        -AdminAddress "MyDDC.MyDomain.local"

    # Remove VMs with ForgetVM
    .\Remove-ProvVM.ps1 `
        -ProvisioningSchemeName "MyCatalog" `
        -VmNamesToRemove "MyVM001", "MyVM002" `
        -Domain "MyDomain.local" `
        -UserName "MyUserName" `
        -ForgetVM $True `
        -AdminAddress "MyDDC.MyDomain.local"
#>

# /*************************************************************************
# * Copyright © 2024. Cloud Software Group, Inc. All Rights Reserved.
# * This file is subject to the license terms contained
# * in the license file that is distributed with this file.
# *************************************************************************/

param(
    [string] $ProvisioningSchemeName,
    [string[]] $VmNamesToRemove,
    [string] $Domain,
    [string] $UserName,
    [switch] $PurgeDBOnly = $false,
    [switch] $ForgetVM = $false,
    [string] $AdminAddress = $null
)

# Enable Citrix PowerShell Cmdlets
Add-PSSnapin citrix*

############################
# Step 1: Remove ProvVM(s) #
############################
Write-Output "Step 1: Remove ProvVM(s)"

# Get ProvVM IDs to remove
$vmIDsToRemove = @($VmNamesToRemove | ForEach-Object { Get-ProvVM -ProvisioningSchemeName $ProvisioningSchemeName -VMName $_ } | Select-Object VMId)

# Configure the common parameters for Unlock-ProvVM.
$unlockProvVMParameters = @{
    ProvisioningSchemeName = $ProvisioningSchemeName
    VMID = $vmIDsToRemove
}

# If operating in an On-Prem environment, configure the AdminAddress.
if ($AdminAddress) { $unlockProvVMParameters['AdminAddress'] = $AdminAddress }

# Unlock the ProvVM
& Unlock-ProvVM @unlockProvVMParameters

# Configure the common parameters for Remove-ProvVM.
$removeProvVMParameters = @{
    ProvisioningSchemeName  = $ProvisioningSchemeName
    VMName = $VmNamesToRemove
}

# Configure additional parameters for Remove-ProvVM, e.g., PurgeDBOnly or ForgetVM.
if ($PurgeDBOnly) {
    $removeProvVMParameters['PurgeDBOnly'] = $true
} elseif ($ForgetVM) {
    $removeProvVMParameters['ForgetVM'] = $true
}

# If operating in an On-Prem environment, configure the AdminAddress.
if ($AdminAddress) { $unlockProvVMParameters['AdminAddress'] = $AdminAddress }

# Remove ProvVMs.
$removeProvVMResult = & Remove-ProvVM @removeProvVMParameters
$removeProvVMResult

####################################
# Step 2: Remove Broker Machine(s) #
####################################
Write-Output "Step 3: Remove Broker Machine(s)"

# Get the broker machines to remove
$brokerMachines = $VmNamesToRemove | ForEach-Object { Get-BrokerMachine -CatalogName $ProvisioningSchemeName -HostedMachineName $_ }
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

###################################
# Step 3: Remove AcctADAccount(s) #
###################################
Write-Output "Step 4: Remove AcctADAccount(s)"

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


##############################
# Step 4: Remove ProvTask(s) #
##############################
Write-Output "Step 7: # Remove ProvTask(s)."

# Delete completed tasks creating Provisioning Scheme and ProvVMs
Remove-ProvTask -TaskId $removeProvVMResult.TaskId | Out-Null
