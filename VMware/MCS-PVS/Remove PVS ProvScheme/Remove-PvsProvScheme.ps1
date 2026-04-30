# /*************************************************************************
# * Copyright © Citrix Systems, Inc. All Rights Reserved.
# * This file is subject to the license terms contained
# * in the license file that is distributed with this file.
# *************************************************************************/

<#
.SYNOPSIS
    Removes a PVS machine catalog including all VMs, AD accounts, and the provisioning scheme on VMware.

.DESCRIPTION
    Remove-PvsProvScheme.ps1 performs a complete teardown of a PVS-backed MCS catalog on VMware:
      1. Unlocks and removes ProvVM(s) from MCS
      2. Removes AD computer accounts
      3. Removes the AcctIdentityPool
      4. Removes Broker Machine(s) from the delivery group/catalog
      5. Removes the BrokerCatalog
      6. Removes the ProvScheme
      7. Cleans up ProvTask(s)

    The original version of this script is compatible with
    Citrix Virtual Apps and Desktops 7 2402 Long Term Service Release (LTSR) or later.

    IMPORTANT:
    - Review and update ALL parameters before running.
    - Run from a Delivery Controller (DDC) with the Citrix PowerShell SDK installed.
    - This is a DESTRUCTIVE operation. VMs and AD accounts will be permanently deleted
      unless -PurgeDBOnly or -ForgetVM is specified.

.PARAMETER ProvisioningSchemeName
    Name of the PVS provisioning scheme / machine catalog to remove.

.PARAMETER IdentityPoolName
    Name of the identity pool associated with the catalog. Defaults to ProvisioningSchemeName if not specified.

.PARAMETER Domain
    The AD domain name (e.g. "corp.local").

.PARAMETER UserName
    The AD user name with permissions to delete computer accounts.

.PARAMETER AdminAddress
    (Optional) The Delivery Controller address for on-prem environments.

.PARAMETER PurgeDBOnly
    Remove VM records from the MCS database without deleting the actual VMs from the hypervisor.

.PARAMETER ForgetVM
    Disassociate VMs from Citrix management while retaining them on the hypervisor.

.EXAMPLE
    .\Remove-PvsProvScheme.ps1 `
        -ProvisioningSchemeName "MyCatalog" `
        -Domain "corp.local" `
        -UserName "admin1"

.EXAMPLE
    # Remove catalog but keep VMs on the hypervisor
    .\Remove-PvsProvScheme.ps1 `
        -ProvisioningSchemeName "MyCatalog" `
        -Domain "corp.local" `
        -UserName "admin1" `
        -ForgetVM
#>

param(
    [Parameter(Mandatory = $true)]
    [string] $ProvisioningSchemeName,

    [string] $IdentityPoolName = "",

    [Parameter(Mandatory = $true)]
    [string] $Domain,

    [Parameter(Mandatory = $true)]
    [string] $UserName,

    [string] $AdminAddress = $null,

    [switch] $PurgeDBOnly = $false,

    [switch] $ForgetVM = $false
)

# Enable Citrix PowerShell Cmdlets
Add-PSSnapin -Name "Citrix.ADIdentity.Admin.V2","Citrix.Host.Admin.V2","Citrix.MachineCreation.Admin.V2","Citrix.Broker.Admin.V2" -ErrorAction SilentlyContinue

if (-not $IdentityPoolName) { $IdentityPoolName = $ProvisioningSchemeName }

if ($PurgeDBOnly -and $ForgetVM) {
    Write-Error "Please specify either -PurgeDBOnly or -ForgetVM, but not both. Specifying both parameters simultaneously is not supported."
    exit
}

############################
# Step 1: Remove ProvVM(s) #
############################
Write-Output "Step 1: Remove ProvVM(s)"

# Unlock the ProvVMs
$vmIds = @(Get-ProvVM -ProvisioningSchemeName $ProvisioningSchemeName | Select-Object VMId)

if ($vmIds.Count -gt 0) {
    $unlockProvVMParameters = @{
        ProvisioningSchemeName = $ProvisioningSchemeName
        VMID                   = $vmIds.VMId
    }
    if ($AdminAddress) { $unlockProvVMParameters['AdminAddress'] = $AdminAddress }

    Unlock-ProvVM @unlockProvVMParameters

    # Get the VM Names to remove
    $vmNames = @(Get-ProvVM -ProvisioningSchemeName $ProvisioningSchemeName | Select-Object -ExpandProperty VMName)

    $removeProvVMParameters = @{
        ProvisioningSchemeName = $ProvisioningSchemeName
        VMName                 = $vmNames
        PurgeDBOnly            = $PurgeDBOnly
        ForgetVM               = $ForgetVM
    }
    if ($AdminAddress) { $removeProvVMParameters['AdminAddress'] = $AdminAddress }

    $removeProvVMResult = Remove-ProvVM @removeProvVMParameters
    $removeProvVMResult
}

###################################
# Step 2: Remove AcctADAccount(s) #
###################################
Write-Output "Step 2: Remove AcctADAccount(s)"

$adAccountSid = @(Get-AcctADAccount -IdentityPoolName $IdentityPoolName | Select-Object -ExpandProperty ADAccountSid)

if ($adAccountSid.Count -gt 0) {
    $adUserName = "$Domain\$UserName"

    $SecurePasswordInput = Read-Host "Please enter the Active Directory password for the user $UserName" -AsSecureString
    $EncryptedPasswordInput = $SecurePasswordInput | ConvertFrom-SecureString
    $securedPassword = ConvertTo-SecureString -String $EncryptedPasswordInput

    $removeAcctADAccountParameters = @{
        IdentityPoolName = $IdentityPoolName
        ADUserName       = $adUserName
        ADPassword       = $securedPassword
        ADAccountSid     = $adAccountSid
        RemovalOption    = "Delete"
        Force            = $true
    }
    if ($AdminAddress) { $removeAcctADAccountParameters['AdminAddress'] = $AdminAddress }

    Remove-AcctADAccount @removeAcctADAccountParameters
}

###################################
# Step 3: Remove AcctIdentityPool #
###################################
Write-Output "Step 3: Remove AcctIdentityPool"

$removeAcctIdentityPoolParameters = @{
    IdentityPoolName = $IdentityPoolName
}
if ($AdminAddress) { $removeAcctIdentityPoolParameters['AdminAddress'] = $AdminAddress }

Remove-AcctIdentityPool @removeAcctIdentityPoolParameters

####################################
# Step 4: Remove Broker Machine(s) #
####################################
Write-Output "Step 4: Remove Broker Machine(s)"

$brokerMachines = Get-BrokerMachine -CatalogName $ProvisioningSchemeName

$brokerMachines | ForEach-Object {
    $removeBrokerMachineParameters = @{
        MachineName = $_.MachineName
        Force       = $true
    }
    if ($AdminAddress) { $removeBrokerMachineParameters['AdminAddress'] = $AdminAddress }

    Remove-BrokerMachine @removeBrokerMachineParameters
}

##########################################
# Step 5: Remove the Provisioning Scheme #
##########################################
Write-Output "Step 5: Remove the Provisioning Scheme"

$removeProvSchemeParameters = @{
    ProvisioningSchemeName = $ProvisioningSchemeName
}
if ($AdminAddress) { $removeProvSchemeParameters['AdminAddress'] = $AdminAddress }

if ($PurgeDBOnly) {
    $removeProvSchemeParameters['PurgeDBOnly'] = $true
} elseif ($ForgetVM) {
    $removeProvSchemeParameters['ForgetVM'] = $true
}

$removeProvSchemeResult = Remove-ProvScheme @removeProvSchemeParameters
$removeProvSchemeResult

#################################
# Step 6: Remove Broker Catalog #
#################################
Write-Output "Step 6: Remove Broker Catalog"

$removeBrokerCatalogParameters = @{
    Name = $ProvisioningSchemeName
}
if ($AdminAddress) { $removeBrokerCatalogParameters['AdminAddress'] = $AdminAddress }

Remove-BrokerCatalog @removeBrokerCatalogParameters

##############################
# Step 7: Remove ProvTask(s) #
##############################
Write-Output "Step 7: Remove ProvTask(s)"

if ($removeProvVMResult) {
    Remove-ProvTask -TaskId $removeProvVMResult.TaskId -ErrorAction SilentlyContinue | Out-Null
}
if ($removeProvSchemeResult) {
    Remove-ProvTask -TaskId $removeProvSchemeResult.TaskId -ErrorAction SilentlyContinue | Out-Null
}

Write-Output "Catalog '$ProvisioningSchemeName' removal complete."
