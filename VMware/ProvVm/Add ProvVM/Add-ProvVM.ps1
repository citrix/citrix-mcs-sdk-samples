<#
.SYNOPSIS
    Adds VMs to a machine catalog.
.DESCRIPTION
    The `Add-ProvVM.ps1` script adds VMs to a machine catalog.
    The original version of this script is compatible with Citrix Virtual Apps and Desktops 7 2203 Long Term Service Release (LTSR).
.INPUTS
    1. ProvisioningSchemeName: The name of the provisioning scheme where VMs will be added.
    2. Count: Specifies the number of VMs to be added.
    3. AdminAddress: The primary DDC address.
.OUTPUTS
    N/A
.NOTES
    Version      : 1.0.0
    Author       : Citrix Systems, Inc.
.EXAMPLE
    .\Add-ProvVM.ps1 `
        -ProvisioningSchemeName "MyCatalog" `
        -Count 2 `
        -AdminAddress "MyDDC.MyDomain.local"
#>

# /*************************************************************************
# * Copyright © 2024. Cloud Software Group, Inc. All Rights Reserved.
# * This file is subject to the license terms contained
# * in the license file that is distributed with this file.
# *************************************************************************/

param(
    [string] $ProvisioningSchemeName,
    [int] $Count,
    [guid] $AdminAddress
)

# Enable Citrix PowerShell Cmdlets
Add-PSSnapin citrix*

#######################################
# Step 1: Create new AcctADAccount(s) #
#######################################
Write-Output "Step 1: Create new AcctADAccount(s)."

# Step 1: Create new AcctADAccounts
$identityPoolName = $ProvisioningSchemeName

# Get the IdentityPool
$identityPool = Get-AcctIdentityPool -IdentityPoolName $identityPoolName -MaxRecordCount 2147483647

# Configure the common parameters for New-AcctADAccount.
$newAcctADAccountPoolParameters = @{
    IdentityPoolUid = $identityPool.IdentityPoolUid
    Count  = $Count
}

# If operating in an On-Prem environment, configure the AdminAddress.
if ($AdminAddress) { $newAcctADAccountPoolParameters['AdminAddress'] = $AdminAddress }

# Add new ADAccounts to the IdentityPool for New ProvVMs
$newAccounts = & New-AcctADAccount @newAcctADAccountPoolParameters

if ($newAccounts.FailedAccounts) {
    Write-Output "New-AcctADAccount failed."
    exit
}

# Get the new account names
$newAccountsNames = @($newAccounts.SuccessfulAccounts | Select-Object ADAccountName)

################################
# Step 2: Create new ProvVM(s) #
################################
Write-Output "Step 2: Create new ProvVM(s)."

# Configure the common parameters for New-ProvVM.
$newProvVMParameters = @{
    ProvisioningSchemeName = $ProvisioningSchemeName
    ADAccountName  = $newAccountsNames
}

# If operating in an On-Prem environment, configure the AdminAddress.
if ($AdminAddress) { $newProvVMParameters['AdminAddress'] = $AdminAddress }

# Create NewProvVMs
$newProvVMsTask = & New-ProvVM @newProvVMParameters


# Get the new VM Ids to lock
$newProvVMIds = @($newProvVMsTask.CreatedVirtualMachines | Select-Object VMId)

# Configure the common parameters for Lock-ProvVM.
$lockProvVMParameters = @{
    ProvisioningSchemeName = $ProvisioningSchemeName
    VMID = $newProvVMIds
    Tag  = "Brokered"
}

# If operating in an On-Prem environment, configure the AdminAddress.
if ($AdminAddress) { $lockProvVMParameters['AdminAddress'] = $AdminAddress }

# Lock the new ProvVMs
& Lock-ProvVM @lockProvVMParameters


########################################
# Step 3: Create new Broker Machine(s) #
########################################
Write-Output "Step 3: Create new Broker Machine(s)."

# Get the broker catalog
$catalog = Get-BrokerCatalog -CatalogName $ProvisioningSchemeName

# Get the SIDs of the new ProvVMs
$newProvVMSids = @($newProvVMsTask.CreatedVirtualMachines | Select-Object ADAccountSid)

# Create Broker Machines of the new ProvVMs
$newProvVMSids | ForEach-Object {
    # Configure the common parameters for New-BrokerMachine.
    $newBrokerMachineParameters = @{
        CatalogUid = $catalog.Uid
        MachineName = $_.ADAccountSid
    }

    # If operating in an On-Prem environment, configure the AdminAddress.
    if ($AdminAddress) { $newBrokerMachineParameters['AdminAddress'] = $AdminAddress }

    # Create Broker Machines of the new ProvVMs
    & New-BrokerMachine @newBrokerMachineParameters
}


##############################
# Step 4: Remove ProvTask(s) #
##############################
Write-Output "Step 4: # Remove ProvTask(s)."

# Configure the common parameters for Remove-ProvTask.
$removeProvTaskParameters = @{
    TaskId = $newProvVMsTask.TaskId
}

# If operating in an On-Prem environment, configure the AdminAddress.
if ($AdminAddress) { $removeProvTaskParameters['AdminAddress'] = $AdminAddress }

# Remove the New-ProvVM task
& Remove-ProvTask @removeProvTaskParameters