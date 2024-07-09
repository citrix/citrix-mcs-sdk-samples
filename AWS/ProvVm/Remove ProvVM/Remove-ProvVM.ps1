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

################################
# Step 0: Setup the parameters #
################################
# Add Citrix snap-ins
Add-PSSnapin -Name "Citrix.Host.Admin.V2","Citrix.MachineCreation.Admin.V2"

# [User Input Required] Setup parameters for Remove-BrokerMachine
$machineName = "DOMAIN\demo-provVM1"

# [User Input Required] Setup parameters for Remove-ProvVM
$provisioningSchemeName = "demo-provScheme"
$VMName = "demo-provVM1"

# [User Input Required] Setup parameteres for RemoveAcctAdAccount
$identityPoolName = "demo-identitypool"
$provVM = Get-ProvVM -ProvisioningSchemeName $provisioningSchemeName -VMName $VMName

# Get the all the AD Accounts of the prov vms you want to delete
$adAccountSids = $provVM | Select-Object -ExpandProperty ADAccountSid

######################################
# Step 1: Remove the Broker Machines #
######################################
Remove-BrokerMachine -MachineName $machineName

########################################
# Step 2: Remove the Provisioned VM(s) #
########################################
# Unlock the VM
Unlock-ProvVM -ProvisioningSchemeName $provisioningSchemeName -VMID $provVM.VMId

Remove-ProvVM -ProvisioningSchemeName $provisioningSchemeName -VMName $VMName

####################################
# Step 3: Remove the AD Account(s) #
####################################
Remove-AcctADAccount -IdentityPoolName $identityPoolName -ADAccountSid $adAccountSids