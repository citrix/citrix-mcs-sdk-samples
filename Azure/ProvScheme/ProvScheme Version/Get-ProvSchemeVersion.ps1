<#
.SYNOPSIS
    Get the list of saved configuration versions about MCS catalog. Applicable for Citrix DaaS and on-prem.
.DESCRIPTION
	Each time when Set-ProvScheme is run to modify MCS catalog, the configuration change is saved as a new version.
	Get-ProvSchemeVersion command allow users to review the list of saved provisioning scheme configuration versions.
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

# Get the list of saved configuration versions about a specific Provisioning Scheme
Get-ProvSchemeVersion -ProvisioningSchemeName $provisioningSchemeName