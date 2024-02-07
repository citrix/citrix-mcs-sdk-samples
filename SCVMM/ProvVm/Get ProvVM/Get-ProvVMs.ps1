<#
.SYNOPSIS
    Get information about MCS catalog machine. Applicable for Citrix DaaS and on-prem.
.DESCRIPTION
    Get-ProvVMs.ps1 emulates the behavior of the Get-ProvVM command.
    It gets all VMs created with the same Provisioning scheme name.
    The original version of this script is compatible with Citrix Virtual Apps and Desktops 7 2203 Long Term Service Release (LTSR).
#>

# /*************************************************************************
# * Copyright © 2024. Cloud Software Group, Inc.
# * This file is subject to the license terms contained
# * in the license file that is distributed with this file.
# *************************************************************************/

# Add Citrix snap-ins
Add-PSSnapin -Name "Citrix.MachineCreation.Admin.V2"

# [User Input Required]
$provisioningSchemeName = "demo-provScheme"

#############################################################################################
# Get all the Virtual Machines that were provisioned using the specific Provisioning Scheme #
#############################################################################################

Get-ProvVM -ProvisioningSchemeName $provisioningSchemeName