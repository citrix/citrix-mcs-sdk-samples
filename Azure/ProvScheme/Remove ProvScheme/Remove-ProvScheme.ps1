<#
.SYNOPSIS
    Remove a provisioning Scheme. Applicable for Citrix DaaS and on-prem.
.DESCRIPTION
    Remove-ProvScheme.ps1 emulates the behavior of the Remove-ProvScheme command.
    It removes all remaining catalog level resources (such as basedisk, citrix povisioned resource group) from hypervisor,
	and also the internal data related to the provisioning scheme from the Citrix site database.
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

# Remove a Provisioning Scheme
# The provisioning scheme must not contain any VMs.
Remove-ProvScheme -ProvisioningSchemeName $provisioningSchemeName