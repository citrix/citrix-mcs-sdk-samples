<#
.SYNOPSIS
    Sets or changes storge types of an existing MCS catalog.
	The updated encryption will be applicable to new machines post operation, not to the existing machines. Updating encryption keys on existing machines is currently not supported.
	Applicable for Citrix DaaS and on-prem.
.DESCRIPTION
    This script changes the encryption on an existing MCS catalog.
    In this example, encryption of a catalog is changed to 'my-key-2' from keyring 'my-key-ring' via custom property 'CryptoKeyId'.
    The original version of this script is compatible with Citrix Virtual Apps and Desktops 7 2402 Long Term Service Release (LTSR).
#>

# /*************************************************************************
# * Copyright © 2024. Cloud Software Group, Inc. All Rights Reserved.
# * This file is subject to the license terms contained
# * in the license file that is distributed with this file.
# *************************************************************************/

# Add Citrix snap-ins
Add-PSSnapin -Name "Citrix.Host.Admin.V2","Citrix.MachineCreation.Admin.V2"

#------------------------------------------------- Set parameters for an existing ProvisioningScheme -----------------------------------------------------#
# [User Input Required] Set parameters for Set-ProvScheme
$provisioningSchemeName = "demo-provScheme"
$ProjectId = "my-project-id" # This is the id of the GCP project (not project name)
$Region = "global" # If the encryption key is global, this value should be set to 'global'
$KeyRingName = "key-ring-global"
$CryptoKeyName = "global-key"

# Set the custom properties
$CryptoKey = "$($ProjectId):$($Region):$($KeyRingName):$($CryptoKeyName)"
$CustomProperties = '<CustomProperties xmlns="http://schemas.citrix.com/2014/xd/machinecreation" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">' `
					+ '<Property xsi:type="StringProperty" Name="CryptoKeyId" Value="' + $CryptoKey +'"/>' `
					+ '</CustomProperties>'


# Modify the ProvisioningScheme
Set-ProvScheme `
-ProvisioningSchemeName $provisioningSchemeName `
-CustomProperties $customProperties