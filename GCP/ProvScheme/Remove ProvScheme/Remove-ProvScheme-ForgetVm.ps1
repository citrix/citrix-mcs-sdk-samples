<#
.SYNOPSIS
    Remove a provisioning Scheme. Applicable for Citrix DaaS and on-prem.
.DESCRIPTION
    Remove-ProvScheme-ForgetVM keeps catalog VMs and related resources (network interface, OsDisk, etc.) in the hypervisor.
	Tags created by provisioning process and associated with the provisioning scheme will be removed.
    It also removes the provisioning Scheme data from the Citrix site database.
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

# ForgetVM option can only be applied to persistent VMs
# ForgetVM option cannot be used with “PurgeDBOnly”.
Remove-ProvScheme -ProvisioningSchemeName $provisioningSchemeName -ForgetVM