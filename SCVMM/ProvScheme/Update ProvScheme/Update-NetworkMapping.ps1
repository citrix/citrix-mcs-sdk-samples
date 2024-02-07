<#
.SYNOPSIS
    Sets or changes the network mapping on an existing MCS catalog. This network mapping change is only applicable to the new machines added after the operation. The existing machines in the catalog are not affected. Applicable for Citrix DaaS and on-prem. Applicable for Citrix DaaS and on-prem.
.DESCRIPTION
    Update-NetworkMapping helps sets or change the network mapping on an existing MCS catalog.
    The original version of this script is compatible with Citrix Virtual Apps and Desktops 7 2203 Long Term Service Release (LTSR).
#>

# /*************************************************************************
# * Copyright © 2024. Cloud Software Group, Inc.
# * This file is subject to the license terms contained
# * in the license file that is distributed with this file.
# *************************************************************************/

################################
# Step 0: Setup the parameters #
################################
# Add Citrix snap-ins
Add-PSSnapin -Name "Citrix.Host.Admin.V2","Citrix.MachineCreation.Admin.V2"

# [User Input Required] Setup the parameters for Set-ProvScheme
$newVmName= "demo-networkmapping-vm"
$provisioningSchemeName = "demo-provScheme"
$hostingUnitName = "demo-hostingunit"
$deviceID=((Get-SCVirtualMachine -Name $newVmName|Get-SCVirtualNetworkAdapter).DeviceID).Split("\")[1]
$network = "demo-network1.network"
$networkMapping =  @{$deviceID = "XDHyp:\HostingUnits\"+$hostingUnitName+"\"+$network}

#####################################################
# Step 1: Change the Provisioning Scheme properties #
#####################################################
# Change the provisioining scheme properties
Set-ProvScheme -ProvisioningSchemeName $provisioningSchemeName -NetworkMapping $networkMapping