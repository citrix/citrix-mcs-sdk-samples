<#
.SYNOPSIS
    Sets or changes Catalog Zone(s) of an existing MCS catalog.
	The updated zone(s) will be applicable to new machines post-operation, not to the existing machines. Updating zone of existing machines is not supported.
	Applicable for Citrix DaaS and on-prem.
.DESCRIPTION
    This script changes the zone configuration on an existing MCS catalog via CatalogZones custom property.
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
$Region = "us-central1"
$ProjectId = "project-id" # This is ID of the GCP project (not project name)
# Zones should be in the format 'projectId:region:zoneName'. In a multi-zone scenario, separate zone IDs with commas e.g. $Zones = "$($ProjectId):$($Region):b,$($ProjectId):$($Region):c"
$Zones = "$($ProjectId):$($Region):c"

# Set the Zones custom property.
# If only one zone is specified, the resources will be provisioned in that zone.
# If multiple zones are specified, machines are randomly provisioned into given zones.
$CustomProperties = '<CustomProperties xmlns="http://schemas.citrix.com/2014/xd/machinecreation" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">' `
					+ '<Property xsi:type="StringProperty" Name="CatalogZones" Value="' + $Zones +'"/>' `
					+ '</CustomProperties>'

# Modify the ProvisioningScheme
Set-ProvScheme `
-ProvisioningSchemeName $provisioningSchemeName `
-CustomProperties $customProperties