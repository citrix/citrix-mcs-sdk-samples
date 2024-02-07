<#
.SYNOPSIS
    Gets the HostingConnection.
.DESCRIPTION
    Get-HostingConnection.ps1 gets the HostingConnection when HostingConnectionName is provided.
    The original version of this script is compatible with Citrix Virtual Apps and Desktops 7 2203 Long Term Service Release (LTSR).
#>

# /*************************************************************************
# * Copyright © 2024. Cloud Software Group, Inc.
# * This file is subject to the license terms contained
# * in the license file that is distributed with this file.
# *************************************************************************/

# [User Input Required]
$ConnectionName = "AzureConnection"

# Enable Citrix PowerShell Cmdlets
Add-PSSnapin -Name "Citrix.Host.Admin.V2","Citrix.MachineCreation.Admin.V2","Citrix.Broker.Admin.V2"

#####################################################
# Step 1: Get the detail of the hosting connection. #
#####################################################

Get-BrokerHypervisorConnection -Name $ConnectionName

############################################################
# Step 2: Get the host details of the hosting connection. #
############################################################

Get-Item -LiteralPath @("XDHyp:\Connections\" + $ConnectionName)