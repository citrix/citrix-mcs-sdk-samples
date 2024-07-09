<#
.SYNOPSIS
    Get information about MCS catalog machine. Applicable for Citrix DaaS and on-prem.
.DESCRIPTION
    Get-ProvVM.ps1 emulates the behavior of the Get-ProvVM command.
    It gets a specific VM by name.
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

# [User Input Required] Set parameters for Get-ProvVM
$provisioningSchemeName = "demo-provScheme"
$VMName = "demo-provVM"
$filter = "{Domain -eq 'demo.local'}"
$sortBy = "-CpuCount"

#####################################
# Step 1: Get the Provisioned VM(s) #
#####################################
# Get the specific VM
Get-ProvVM -VMName $VMName

# Get a filtered list of VMs
Get-ProvVM -ProvisioningSchemeName $provisioningSchemeName -Filter $filter -SortBy $sortBy