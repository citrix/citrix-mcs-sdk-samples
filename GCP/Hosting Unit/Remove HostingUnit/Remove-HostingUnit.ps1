<#
.SYNOPSIS
    Removes the given HostingUnits.
.DESCRIPTION
    Remove-HostingUnit.ps1 removes the HostingUnits when the HostingUnitNames are provided.
    The original version of this script is compatible with Citrix Virtual Apps and Desktops 7 2203 Long Term Service Release (LTSR).
#>

# /*************************************************************************
# * Copyright © 2024. Cloud Software Group, Inc. All Rights Reserved.
# * This file is subject to the license terms contained
# * in the license file that is distributed with this file.
# *************************************************************************/

# [User Input Required]
$HostingUnitNames =  @("GcpHostingUnitName")

# Enable Citrix PowerShell Cmdlets
Add-PSSnapin -Name "Citrix.Host.Admin.V2","Citrix.MachineCreation.Admin.V2"

##############################
# Remove the Hosting Unit #
##############################

# Ensure all catalogs associated with the hosting units are removed before running this script.
$HostingUnitNames | ForEach-Object { Remove-Item -LiteralPath "XDHyp:\HostingUnits\$_" -Force }