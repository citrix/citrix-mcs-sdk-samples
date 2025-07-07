<#
.SYNOPSIS
    Gets the HostingUnit.
.DESCRIPTION
    Get-HostingUnit.ps1 gets the HostingUnit when hostingUnitName is provided.
    The original version of this script is compatible with Citrix DaaS July 2025 Release (DDC 125).
#>

# /*************************************************************************
# * Copyright © 2025. Cloud Software Group, Inc. All Rights Reserved.
# * This file is subject to the license terms contained
# * in the license file that is distributed with this file.
# *************************************************************************/

# Add Citrix snap-ins
Add-PSSnapin -Name "Citrix.Host.Admin.V2","Citrix.MachineCreation.Admin.V2"

#######################################
# Get the detail of the hosting unit. #
#######################################
$hostingUnitName = "demo-hostingUnit"

Get-Item -Path "XDHyp:\HostingUnits\$($hostingUnitName)"