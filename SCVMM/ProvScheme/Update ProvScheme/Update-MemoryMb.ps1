<#
.SYNOPSIS
    Sets or changes the MemoryMb on an existing MCS catalog. This memory change is only applicable to the new machines added after the operation. The existing machines in the catalog are not affected. Applicable for Citrix DaaS and on-prem. Applicable for Citrix DaaS and on-prem.
.DESCRIPTION
    Update-MemoryMb helps sets or changes the an existing MCS catalog's VMMemoryMB.
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
$provisioningSchemeName = "demo-provScheme"
$memoryInMb=2

#####################################################
# Step 1: Change the Provisioning Scheme properties #
#####################################################
# Change the provisioining scheme properties
Set-ProvScheme -ProvisioningSchemeName $provisioningSchemeName -VMMemoryMB $memoryInMb