<#
.SYNOPSIS
    Removes entire HostingConnection along with HostingUnits.
.DESCRIPTION
    Remove-HostingConnection.ps1 removes the HostingConnection along with HostingUnits when HostingConnectionName is provided.
    The original version of this script is compatible with Citrix Virtual Apps and Desktops 7 2203 Long Term Service Release (LTSR).
#>

# /*************************************************************************
# * Copyright © 2024. Cloud Software Group, Inc. All Rights Reserved.
# * This file is subject to the license terms contained
# * in the license file that is distributed with this file.
# *************************************************************************/

# [User Input Required]
$ConnectionName = "SCVMMConnection"

# Enable Citrix PowerShell Cmdlets
Add-PSSnapin -Name "Citrix.Host.Admin.V2","Citrix.MachineCreation.Admin.V2"

##########################################################
# Step 1: Remove the Resources of the Hosting Connection #
##########################################################

#Note - Make sure that all the catalogs associated with hosting units are removed before removing the hosting units.
$resources = Get-ChildItem "XDHyp:\HostingUnits\" | Where-Object { $_.HypervisorConnection.HypervisorConnectionName -eq $ConnectionName }
$resources | ForEach-Object { Remove-Item -LiteralPath ("XDHyp:\HostingUnits\"+$_.HostingUnitName) -Force }

#########################################
# Step 2: Remove the Hosting Connection #
#########################################

Remove-BrokerHypervisorConnection -Name $ConnectionName
Remove-Item -LiteralPath @("XDHyp:\Connections\" + $ConnectionName)