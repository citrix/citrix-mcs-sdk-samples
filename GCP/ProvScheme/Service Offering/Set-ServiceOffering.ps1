	<#
.SYNOPSIS
    Sets or changes Service Offering (also called as machine type in GCP) on an existing MCS catalog.
	The updated machine type will be applicable to new machines post-operation, not to the existing machines.
	For applying to existing machines, run Set-ProvVmUpdateTimeWindow and restart the machines.
	Applicable for Citrix DaaS and on-prem.
.DESCRIPTION
    This script changes the Service Offering configuration on an existing MCS catalog to 'n2-standard-2' through parameter ServiceOffering of the cmdlet Set-ProvScheme.
    The original version of this script is compatible with Citrix Virtual Apps and Desktops 7 2402 Long Term Service Release (LTSR).
#>

# /*************************************************************************
# * Copyright © 2024. Cloud Software Group, Inc. All Rights Reserved.
# * This file is subject to the license terms contained
# * in the license file that is distributed with this file.
# *************************************************************************/

# Add Citrix snap-ins
Add-PSSnapin -Name "Citrix.Host.Admin.V2","Citrix.MachineCreation.Admin.V2"

# [User Input Required] Set parameters for Set-ProvScheme
$provisioningSchemeName = "demo-provScheme"
$hostingUnitName = "GcpHostingUnitName"
$serviceOffering = "n2-standard-2"

# Set Service Offering path
$ServiceOfferingPath = "XDHyp:\HostingUnits\$hostingUnitName\machineTypes.folder\$serviceOffering.serviceoffering"


# Modify the ProvisioningScheme
Set-ProvScheme `
-ProvisioningSchemeName $provisioningSchemeName `
-ServiceOffering $ServiceOfferingPath