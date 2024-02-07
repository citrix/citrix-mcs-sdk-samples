<#
.SYNOPSIS
    Removes the given HostingUnit.
.DESCRIPTION
    Remove-HostingUnit.ps1 removes the HostingUnits when the hostingUnitName are provided.
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

# [User Input Required] Setup parameters for creating hosting unit
$hostingUnitName = "demo-hostingunit"
$hostingUnitPath = "XDHyp:\HostingUnits\" + $hostingUnitName

###################################
# Step 1: Remove the Hosting Unit #
###################################

# Remove the hosting unit.
Remove-Item -LiteralPath $hostingUnitPath