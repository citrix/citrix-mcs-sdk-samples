<#
.SYNOPSIS
    Remove provisioned VMs from a Provisioning Scheme
.DESCRIPTION
    `Remove-ProvVM.ps1` script removes a specific VM, or all the VMs from a Provisioning Scheme.
    The original version of this script is compatible with Citrix Virtual Apps and Desktops 7 2402 Long Term Service Release (LTSR).
.INPUTS
    1. ProvisioningSchemeName: The name of the provisioning scheme
    2. VMName: Names of the VMs to get
    3. Domain: Domain of AD accounts
    4. UserName: Username of AD accounts
    5. PurgeDBOnly: Remove VMs from database without deleting from hypervisor
    6. ForgetVM: Disassicate VMs from Citrix without deleting from hypervisor
    7. AdminAddress: DDC Address
.EXAMPLE
    # Get all VMs from a Provisioning Scheme
    .\Remove-ProvVM.ps1 `
        -ProvisioningSchemeName "myProvScheme" `
        -VMName myVM1,myVM2
        -Domain "myDomain"
        -UserName "myUser"
#>

# /*************************************************************************
# * Copyright © 2024. Cloud Software Group, Inc. All Rights Reserved.
# * This file is subject to the license terms contained
# * in the license file that is distributed with this file.
# *************************************************************************/

param(
    [Parameter(mandatory=$true)]
    [string] $ProvisioningSchemeName,
    [Parameter(mandatory=$true)]
    [string[]] $VmName,
    [Parameter(mandatory=$true)]
    [string] $Domain,
    [Parameter(mandatory=$true)]
    [string] $UserName,
    [switch] $PurgeDBOnly = $false,
    [switch] $ForgetVM = $false,
    [string] $AdminAddress = $null
)

# Enable Citrix PowerShell Cmdlets
Add-PSSnapin -Name "Citrix.Host.Admin.V2","Citrix.MachineCreation.Admin.V2" 

Write-Verbose "Get ID's of VM's to remove"
$vmIDsToRemove = @($VmName | ForEach-Object { Get-ProvVM -ProvisioningSchemeName $ProvisioningSchemeName -VMName $_ } | Select-Object VMId)

# Create params for Unlock-ProvVM.
$unlockProvVMParameters = @{
    ProvisioningSchemeName = $ProvisioningSchemeName
    VMID = $vmIDsToRemove
}

Write-Verbose "Unlock VM's before removing"
# Unlock the VMs
& Unlock-ProvVM @unlockProvVMParameters

# Configure the common parameters for Remove-ProvVM.
$removeProvVMParameters = @{
    ProvisioningSchemeName  = $ProvisioningSchemeName
    VMName = $VmName
}

if ($PurgeDBOnly) {
    $removeProvVMParameters['PurgeDBOnly'] = $true
} elseif ($ForgetVM) {
    $removeProvVMParameters['ForgetVM'] = $true
}

if ($AdminAddress) { $unlockProvVMParameters['AdminAddress'] = $AdminAddress }

Write-Verbose "Remove ProvVm"
# Remove VMs
$removeProvVMResult = & Remove-ProvVM @removeProvVMParameters
$removeProvVMResult

Write-Verbose "Remove Broker Machines"
# Get the broker machines to remove
$brokerMachines = $VmName | ForEach-Object { Get-BrokerMachine -CatalogName $ProvisioningSchemeName -HostedMachineName $_ }
$brokerMachines | ForEach-Object {
    $removeBrokerMachineParameters = @{
        MachineName = $_.MachineName
        Force = $true
    }

    # If operating in an On-Prem environment, configure the AdminAddress.
    if ($AdminAddress) { $removeBrokerMachineParameters['AdminAddress'] = $AdminAddress }
    # Remove Broker Machines
    & Remove-BrokerMachine @removeBrokerMachineParameters
}

Write-Verbose "Remove AcctADAccounts"
# Get the SIds of AD Accounts.
$adAccountSid = @(Get-AcctADAccount -IdentityPoolName $ProvisioningSchemeName | Select-Object ADAccountSid)
# Build the AD Account User Name
$adUserName = "$Domain\$UserName"

# Build the secure password
$SecurePasswordInput = Read-Host $"Enter the Active Directory password for the user $($UserName):" -AsSecureString
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

Write-Verbose "Remove ProvTasks"
# Delete completed tasks creating Provisioning Scheme and ProvVMs
Remove-ProvTask -TaskId $removeProvVMResult.TaskId | Out-Null
