<#
.SYNOPSIS
    Delete a configuration version about MCS catalog. Applicable for Citrix DaaS and on-prem.
.DESCRIPTION
	Each time when Set-ProvScheme is run to modify MCS catalog, the configuration change is saved as a new version.
	Remove-ProvSchemeVersion command allow users to clean up any configurations that are no longer needed.
	The original version of this script is compatible with Citrix Virtual Apps and Desktops 7 2402 Long Term Service Release (LTSR).
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
$provisioningSchemeVersion = 1

# Remove the very first configuration
Remove-ProvSchemeVersion -ProvisioningSchemeName $provisioningSchemeName -Version $provisioningSchemeVersion