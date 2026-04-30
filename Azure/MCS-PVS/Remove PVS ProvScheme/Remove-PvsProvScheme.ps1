# /*************************************************************************
# * Copyright © Citrix Systems, Inc. All Rights Reserved.
# * This file is subject to the license terms contained
# * in the license file that is distributed with this file.
# *************************************************************************/

<#
.SYNOPSIS
    Removes a PVS machine catalog including all VMs, AD accounts, and the provisioning scheme on Azure.

.DESCRIPTION
    Remove-PvsProvScheme.ps1 performs a complete teardown of a PVS-backed MCS catalog on Azure:
      1. Unlocks and removes ProvVM(s) from MCS
      2. Removes AD computer accounts
      3. Removes the AcctIdentityPool
      4. Removes Broker Machine(s) from the delivery group/catalog
      5. Removes the ProvScheme
      6. Removes the BrokerCatalog

    The original version of this script is compatible with
    Citrix Virtual Apps and Desktops 7 2402 Long Term Service Release (LTSR) or later.

    IMPORTANT:
    - Review and update ALL parameters before running.
    - This is a DESTRUCTIVE operation. VMs and AD accounts will be permanently deleted
      unless -ForgetVM is specified.

.PARAMETER ProvisioningSchemeName
    Name of the PVS provisioning scheme / machine catalog to remove.

.PARAMETER IdentityPoolName
    Name of the identity pool associated with the catalog.

.PARAMETER ForgetVM
    Disassociate VMs from Citrix management while retaining them in Azure.

.EXAMPLE
    .\Remove-PvsProvScheme.ps1 `
        -ProvisioningSchemeName "MyCatalog" `
        -IdentityPoolName "MyCatalog"

.EXAMPLE
    # Remove catalog but keep VMs in Azure
    .\Remove-PvsProvScheme.ps1 `
        -ProvisioningSchemeName "MyCatalog" `
        -IdentityPoolName "MyCatalog" `
        -ForgetVM
#>

param(
    [Parameter(Mandatory = $true)]
    [string] $ProvisioningSchemeName,

    [Parameter(Mandatory = $true)]
    [string] $IdentityPoolName,

    [switch] $ForgetVM = $false
)

# Enable Citrix PowerShell Cmdlets
Add-PSSnapin -Name "Citrix.Host.Admin.V2","Citrix.MachineCreation.Admin.V2","Citrix.Broker.Admin.V2","Citrix.ADIdentity.Admin.V2" -ErrorAction SilentlyContinue

############################
# Step 1: Remove ProvVM(s) #
############################
Write-Output "Step 1: Remove ProvVM(s)"

$provVMs = Get-ProvVM -ProvisioningSchemeName $ProvisioningSchemeName
foreach ($provVM in $provVMs) {
    Unlock-ProvVM -ProvisioningSchemeName $ProvisioningSchemeName -VMID $provVM.VMId
    Remove-ProvVM -ProvisioningSchemeName $ProvisioningSchemeName -VMName $provVM.VMName -ForgetVM:$ForgetVM
}

###################################
# Step 2: Remove AcctADAccount(s) #
###################################
Write-Output "Step 2: Remove AcctADAccount(s)"

$adAccountNames = Get-AcctADAccount -IdentityPoolName $IdentityPoolName | Select-Object -ExpandProperty ADAccountName
if ($adAccountNames) {
    Remove-AcctADAccount -IdentityPoolName $IdentityPoolName -ADAccountName $adAccountNames -RemovalOption Delete
}

###################################
# Step 3: Remove AcctIdentityPool #
###################################
Write-Output "Step 3: Remove AcctIdentityPool"

Remove-AcctIdentityPool -IdentityPoolName $IdentityPoolName

####################################
# Step 4: Remove Broker Machine(s) #
####################################
Write-Output "Step 4: Remove Broker Machine(s)"

$machineNames = Get-BrokerMachine -CatalogName $ProvisioningSchemeName | Select-Object -ExpandProperty MachineName
foreach ($machineName in $machineNames) {
    Remove-BrokerMachine -MachineName $machineName -Force
}

##########################################
# Step 5: Remove the Provisioning Scheme #
##########################################
Write-Output "Step 5: Remove the Provisioning Scheme"

Remove-ProvScheme -ProvisioningSchemeName $ProvisioningSchemeName -ForgetVM:$ForgetVM

#################################
# Step 6: Remove Broker Catalog #
#################################
Write-Output "Step 6: Remove Broker Catalog"

Remove-BrokerCatalog -Name $ProvisioningSchemeName

Write-Output "Catalog '$ProvisioningSchemeName' removal complete."
