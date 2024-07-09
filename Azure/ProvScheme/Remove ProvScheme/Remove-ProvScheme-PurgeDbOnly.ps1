<#
.SYNOPSIS
    Remove a provisioning Scheme from Citrix site database only. Applicable for Citrix DaaS and on-prem.
.DESCRIPTION
    Remove-ProvScheme-PurgeDBOnly.ps1 only removes the provisioning Scheme from the Citrix site database.
	Catalog VMs and related resources created still remain in the hypervisor.
    The original version of this script is compatible with Citrix Virtual Apps and Desktops 7 2402 Long Term Service Release (LTSR).
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

# PurgeDBOnly option cannot be used with “ForgetVM”
Remove-ProvScheme -ProvisioningSchemeName $provisioningSchemeName -PurgeDBOnly