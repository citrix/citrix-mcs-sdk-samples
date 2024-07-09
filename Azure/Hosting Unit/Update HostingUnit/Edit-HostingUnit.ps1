<#
.SYNOPSIS
    Edit the HostingUnit.
.DESCRIPTION
    Edit-HostingUnit.ps1 edits the HostingUnit when HostingUnitName is provided.
        1. RenameHostingUnitName rename the HostingUnit when RenameHostingUnitName is provided.
        2. Adds more subnets to the HostingUnit when AzureNetwork, AzureResourceGroup, AzureRegion, NetworkNames are provided
    The original version of this script is compatible with Citrix Virtual Apps and Desktops 7 2203 Long Term Service Release (LTSR).
#>

# /*************************************************************************
# * Copyright © 2024. Cloud Software Group, Inc. All Rights Reserved.
# * This file is subject to the license terms contained
# * in the license file that is distributed with this file.
# *************************************************************************/

# [User Input Required]
$HostingUnitName ="AzureHostingUnitName"
$RenameHostingUnitName = "RenameHostingUnitName"
$AzureNetwork = "AzureNetwork"
$AzureResourceGroup = "AzureResourceGroup"
$AzureRegion = "AzureRegion"
$NetworkNames = @("AzureSubnet")

# Enable Citrix PowerShell Cmdlets
Add-PSSnapin -Name "Citrix.Host.Admin.V2","Citrix.MachineCreation.Admin.V2"

$HostingUnitPath = "XDHyp:\HostingUnits\" + $HostingUnitName

$HostingUnit = Get-Item -Path $HostingUnitPath
if($null -eq $HostingUnit)
{
    throw "Provided HostingUnitName is not valid. Please give the right HostingUnitName"
}

#########################################
# To update subnets in HostingUnit #
#########################################

if($NetworkNames.Count -ne 0)
{
    $networkPaths  = $NetworkNames | ForEach-Object {
    "XDHyp:\HostingUnits\" + $HostingUnitName + "\" + $AzureRegion + ".region\virtualprivatecloud.folder\" + $AzureResourceGroup + ".resourcegroup\" + `
    $AzureNetwork + ".virtualprivatecloud\" + $_ + ".network"
    }
    Set-Item -NetworkPath $networkPaths -Path $HostingUnitPath
}

#########################################
# To rename the HostingUnit #
#########################################

if($RenameHostingUnitName -ne "")
{
    Rename-Item -NewName $RenameHostingUnitName -Path $HostingUnitPath
}