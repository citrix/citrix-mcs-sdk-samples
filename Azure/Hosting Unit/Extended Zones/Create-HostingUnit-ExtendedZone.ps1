<#
.SYNOPSIS
    Creates a Hosting Unit for an Azure Extended Zone.
.DESCRIPTION
    Create-HostingUnit-ExtendedZone.ps1 creates a Hosting Unit pointing to an Azure Extended Zone location.
    The key difference when creating a Hosting Unit for an Extended Zone is using ".extendedzone"
    instead of ".region" in the root path.
    The original version of this script is compatible with Citrix Virtual Apps and Desktops 7 2603.
#>

# /*************************************************************************
# * Copyright © 2026. Cloud Software Group, Inc. All Rights Reserved.
# * This file is subject to the license terms contained
# * in the license file that is distributed with this file.
# *************************************************************************/

# [User Input Required]
$ConnectionName = "AzureConnection"               # The name of your existing Azure hosting connection
$AzureLocation = "Los Angeles"                    # The Extended Zone location name (ex: "Los Angeles", "Perth")
$AzureNetwork = "AzureNetwork-extendedzone"       # The name of your virtual network in the Extended Zone
$AzureSubnet = "AzureSubnet-extendedzone"         # The name of your subnet within the virtual network
$HostingUnitName = "AzureHostingUnitName"
$AzureResourceGroup = "AzureResourceGroup"

# Enable Citrix PowerShell Cmdlets
Add-PSSnapin -Name "Citrix.Host.Admin.V2"

# Key difference: Use ".extendedzone" instead of ".region" in the root path
# Region example: XDHyp:\Connections\$ConnectionName\$AzureRegion.region
# Extended Zone example: XDHyp:\Connections\$ConnectionName\$AzureLocation.extendedzone
$RootPath = "XDHyp:\Connections\$($ConnectionName)\" + $AzureLocation + ".extendedzone"

# Network path construction follows the same structure as regions but with .extendedzone
$NetworkPath = "XDHyp:\Connections\" + $ConnectionName + "\" + $AzureLocation + ".extendedzone\virtualprivatecloud.folder\" + $AzureResourceGroup + ".resourcegroup\" + `
$AzureNetwork + ".virtualprivatecloud\" + $AzureSubnet + ".network"
$HostingUnitPath = "XDHyp:\HostingUnits\$HostingUnitName"

####################################
# Step 1: Create the hosting unit. #
####################################

New-Item -HypervisorConnectionName  $ConnectionName `
	-NetworkPath @($NetworkPath) `
	-Path @($HostingUnitPath) `
	-RootPath $RootPath `
	-StoragePath @()