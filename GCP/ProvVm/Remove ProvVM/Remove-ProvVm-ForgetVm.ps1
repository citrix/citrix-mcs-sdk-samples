<#
.SYNOPSIS
    Remove a provisioning Scheme. Applicable for Citrix DaaS and on-prem.
.DESCRIPTION
    Remove-ProvVM-ForgetVm.ps1 only removes the VM object from the Machine Creation Services database;
    VM-related resources (network interface, OsDisk, etc.) shall remain in the hypervisor.
    However, the VM tags/identifiers added by MCS and associated with the provisioning scheme will be removed.
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
$identityPoolName = "demo-identityPoolName"
$machineName = "DOMAIN\demo-vm"

########################################
# Step 1: Get the ProvVM ID to remove. #
########################################

$vmIDToRemove = Get-ProvVM -ProvisioningSchemeName $provisioningSchemeName -VMName $vmName | Select-Object VMId

##############################
# Step 2: Unlock the ProvVM. #
##############################

Unlock-ProvVM -ProvisioningSchemeName $provisioningSchemeName -VMID $vmIDToRemove

##############################################
# Step 3: Remove the ProvVM from the Broker. #
##############################################

Remove-BrokerMachine -MachineName $machineName

# ForgetVM option can only be applied to persistent VMs & cannot be used with “PurgeDBOnly”.
##############################
# Step 4: Forget the ProvVM. #
##############################

Remove-ProvVM -ProvisioningSchemeName $provisioningSchemeName -VMName $vmName -ForgetVM

##########################################
# Step 5: Remove the ProvVM from the AD. #
##########################################

Remove-AcctADAccount -IdentityPoolName $identityPoolName -ADAccountName $machineName -RemovalOption "None"