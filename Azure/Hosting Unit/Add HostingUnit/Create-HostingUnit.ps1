<#
.SYNOPSIS
    Creates the HostingUnit.
.DESCRIPTION
    Create-HostingUnit.ps1 creates the HostingUnit when ConnectionName, AzureRegion, AzureSubnet, HostingUnitName, and AzureResourceGroup are provided.
    The original version of this script is compatible with Citrix Virtual Apps and Desktops 7 2203 Long Term Service Release (LTSR).
#>

# /*************************************************************************
# * Copyright © 2024. Cloud Software Group, Inc.
# * This file is subject to the license terms contained
# * in the license file that is distributed with this file.
# *************************************************************************/

# [User Input Required]
$ConnectionName = "AzureConnection"
$AzureRegion = "AzureRegion"
$AzureNetwork = "AzureNetwork"
$AzureSubnet ="AzureSubnet"
$HostingUnitName ="AzureHostingUnitName"
$AzureResourceGroup = "AzureResourceGroup"

# Enable Citrix PowerShell Cmdlets
Add-PSSnapin -Name "Citrix.Host.Admin.V2","Citrix.MachineCreation.Admin.V2"

$RootPath = "XDHyp:\Connections\$($ConnectionName)\" + $AzureRegion + ".region"
#Note - To multi-network scenario, please add more subtnet path with the same format and put comma as separator. 
$NetworkPath = "XDHyp:\Connections\" + $ConnectionName + "\" + $AzureRegion + ".region\virtualprivatecloud.folder\" + $AzureResourceGroup + ".resourcegroup\" + `
$AzureNetwork + ".virtualprivatecloud\" + $AzureSubnet + ".network"
$HostingUnitPath = "XDHyp:\HostingUnits\$HostingUnitName"


####################################
# Step 1: Create the hosting unit. #
####################################

New-Item   -HypervisorConnectionName  $ConnectionName `
	-NetworkPath @($NetworkPath) `
	-Path @($HostingUnitPath) `
	-PersonalvDiskStoragePath @() `
	-RootPath $RootPath `
	-StoragePath @()