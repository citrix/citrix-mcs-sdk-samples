<#
.SYNOPSIS
    Removes an MCS catalog and the resources that is associated it (ex. identity pool, provisioned vm, etc). Applicable for Citrix DaaS and on-prem.
.DESCRIPTION
    RemoveCatalog creates an MCS catalog and VMs in SCVMM.
    This script is similar to the "Delete Machine Catalog" button in Citrix Studio. It removes the identity pool, ProvScheme, Broker Catalog, AD Accounts, and ProvVms.
#>

# /*************************************************************************
# * Copyright © 2024. Cloud Software Group, Inc.
# * This file is subject to the license terms contained
# * in the license file that is distributed with this file.
# *************************************************************************/

# Add Citrix snap-ins
Add-PSSnapin -Name "Citrix.Host.Admin.V2","Citrix.MachineCreation.Admin.V2"

##########################
# Step 0: Set parameters #
##########################
# [User Input Required] Set parameters for New-AcctIdentityPool
$provisioningSchemeName = "demo-provScheme"
$identityPoolName = "demo-identitypool"

#####################################################
# Step 1: Remove Broker Machine(s) #
#####################################################
# Get the all the machines' names in the catalog
$machineNames = Get-BrokerMachine -CatalogName $provisioningSchemeName | Select-Object -ExpandProperty MachineName

foreach($machineName in $machineNames)
{
    # Remove the broker machines
    Remove-BrokerMachine -MachineName $machineName
}

# Return if Remove-BrokerMachine failed.
if ($null -ne (Get-BrokerMachine -CatalogName $ProvisioningSchemeName)) {
    Write-Output "Remove-BrokerMachine Failed."
    return
}

#####################################################
# Step 2: Remove Prov VM(s) #
#####################################################
# [User Input Required] Setup the parameter for Remove-ProvVM
$forgetVM = $false
$VMNames = Get-ProvVM -ProvisioningSchemeName $provisioningSchemeName | Select-Object -ExpandProperty VMName
foreach($vmName in $VMNames)
{
    Remove-ProvVM -ProvisioningSchemeName $provisioningSchemeName -VMName $vmName -ForgetVM:$forgetVM
}

# Return if Remove-ProvVM failed.
if ($null -ne (Get-ProvVM -ProvisioningSchemeName $ProvisioningSchemeName)) {
    Write-Output "Remove-ProvVM Failed."
    return
}

#####################################################
# Step 3: Remove the Broker Catalog #
#####################################################
Remove-BrokerCatalog -Name $provisioningSchemeName

#####################################################
# Step 4: Remove the ProvScheme #
#####################################################
Remove-ProvScheme -ProvisioningSchemeName $provisioningSchemeName -ForgetVM:$forgetVM

#####################################################
# Step 5: Remove the AD Account(s) #
#####################################################
# Get the all the AD Accounts in the identity pool
$adAccountNames = Get-AcctADAccount -IdentityPoolName $identityPoolName | Select-Object -ExpandProperty ADAccountName

Remove-AcctADAccount -IdentityPoolName $identityPoolName -ADAccountName $adAccountNames

####################################
# Step 6: Remove the Identity Pool #
####################################

Remove-AcctIdentityPool -IdentityPoolName $identityPoolName