<#
.SYNOPSIS
    Resets the OS Disk of a Provisioned VM. Applicable for Citrix DaaS and on-prem.
.DESCRIPTION
    Reset-ProvVM-OSDisk helps reset the OS Disk of a Provisioned VM.
    The original version of this script is compatible with Citrix Virtual Apps and Desktops 7 2402 Long Term Service Release (LTSR).
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

# [User Input Required] Set parameters for Reset-ProvVMDisk
$provisioningSchemeName = "demo-provScheme"
$VMName = "demo-provVM1"

#############################
# Step 1: Reset the OS disk #
#############################
Reset-ProvVMDisk -ProvisioningSchemeName $provisioningSchemeName -VMName $VMName -OS