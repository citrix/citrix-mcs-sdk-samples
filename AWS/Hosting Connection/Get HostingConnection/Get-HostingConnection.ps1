<#
.SYNOPSIS
    Gets the HostingConnection.
.DESCRIPTION
    Get-HostingConnection.ps1 gets the HostingConnection when connectionName is provided.
    The original version of this script is compatible with Citrix Virtual Apps and Desktops 7 2203 Long Term Service Release (LTSR).
#>

# /*************************************************************************
# * Copyright © 2024. Cloud Software Group, Inc.
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

##########################################################
#  Step 1: Get information about the hosting connection. #
##########################################################

Get-Item -Path ("XDHyp:\Connections\" + $connectionName)
Get-BrokerHypervisorConnection -Name $connectionName