<#
.SYNOPSIS
    Get information about MCS catalog machine. Applicable for Citrix DaaS and on-prem.
.DESCRIPTION
    Get-ProvVM.ps1 emulates the behavior of the Get-ProvVM command.
    It gets a speccific VM by name.
    The original version of this script is compatible with Citrix Virtual Apps and Desktops 7 2203 Long Term Service Release (LTSR).
#>

# /*************************************************************************
# * Copyright © 2024. Cloud Software Group, Inc. All Rights Reserved.
# * This file is subject to the license terms contained
# * in the license file that is distributed with this file.
# *************************************************************************/

# Add Citrix snap-ins
Add-PSSnapin -Name "Citrix.MachineCreation.Admin.V2"

# [User Input Required]
$provisioningSchemeName = "demo-provScheme"
$vmName = "demo-vm"

####################################################################
# Get information about a specific MCS catalog machine by its name #
####################################################################

Get-ProvVM -ProvisioningSchemeName $provisioningSchemeName -VMName $vmName