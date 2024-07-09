<#
.SYNOPSIS
    Removes entire HostingConnection along with HostingUnits.
.DESCRIPTION
    Remove-HostingConnection.ps1 removes the HostingConnection along with HostingUnits when connectionName is provided.
    The original version of this script is compatible with Citrix Virtual Apps and Desktops 7 2203 Long Term Service Release (LTSR).
#>

# /*************************************************************************
# * Copyright © 2024. Cloud Software Group, Inc. All Rights Reserved.
# * This file is subject to the license terms contained
# * in the license file that is distributed with this file.
# *************************************************************************/

################################
# Step 0: Setup the parameters #
################################
# Add Citrix snap-ins
Add-PSSnapin -Name "Citrix.Host.Admin.V2","Citrix.MachineCreation.Admin.V2"

# [User Input Required] Setup parameters for creating hosting connection
$connectionName = "demo-hostingconnection"

##############################################################
# Step 1: Remove the Hosting Units of the Hosting Connection #
##############################################################

# Get the Hosting Units of the Hosting Connection
$hostingUnits = Get-ChildItem "XDHyp:\HostingUnits\" | Where-Object { $_.HypervisorConnection.HypervisorConnectionName -eq $connectionName }

# Remove the Hosting Units of the Hosting Connection
$hostingUnits | ForEach-Object { Remove-Item -LiteralPath ("XDHyp:\HostingUnits\"+$_.HostingUnitName) -Force }

#########################################
# Step 2: Remove the Hosting Connection #
#########################################

# Remove the Broker Hypervisor Connection.
Remove-BrokerHypervisorConnection -Name $connectionName

# Remove the connection item
Remove-Item -LiteralPath ("XDHyp:\Connections\" + $connectionName)