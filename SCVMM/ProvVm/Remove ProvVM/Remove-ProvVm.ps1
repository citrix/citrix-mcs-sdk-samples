<#
.SYNOPSIS
    Remove virtual machine created by Machine Creation Services. Applicable for Citrix DaaS and on-prem.
.DESCRIPTION
    Remove-ProvVM.ps1 emulates the behavior of the Remove-ProvVM command.
    It removes the VM resources (such as basedisk, citrix povisioned resource group) from hypervisor,
	and also the internal data related to the VM from the Citrix site database.
    The original version of this script is compatible with Citrix Virtual Apps and Desktops 7 2203 Long Term Service Release (LTSR).
#>

# /*************************************************************************
# * Copyright © 2024. Cloud Software Group, Inc. All Rights Reserved.
# * This file is subject to the license terms contained
# * in the license file that is distributed with this file.
# *************************************************************************/

# Add Citrix snap-ins
Add-PSSnapin -Name "Citrix.Host.Admin.V2","Citrix.MachineCreation.Admin.V2","Citrix.Broker.Admin.V2","Citrix.ADIdentity.Admin.V2"

# [User Input Required]
$provisioningSchemeName = "demo-provScheme"
$vmName = "demo-vm"
$machineName = "DOMAIN\demo-vm"
$identityPoolName = "demo-identityPoolName"
$adIdentityRemoveAccountOption = "Delete" #could be Delete, Disable, None (leaves the computer account in AD)

###################################
# Step 1: Get ProvVM ID to remove #
###################################

$vmIDToRemove = Get-ProvVM -ProvisioningSchemeName $provisioningSchemeName -VMName $vmName | Select-Object VMId

#############################
# Step 2: Unlock the ProvVM #
#############################

Unlock-ProvVM -ProvisioningSchemeName $provisioningSchemeName -VMID $vmIDToRemove

#############################
# Step 3: Remove the ProvVM #
#############################

Remove-BrokerMachine -MachineName $machineName
Remove-ProvVM -ProvisioningSchemeName $provisioningSchemeName  -VMName $vmName
Remove-AcctADAccount -IdentityPoolName $identityPoolName -ADAccountName $machineName -RemovalOption $adIdentityRemoveAccountOption