<#
.SYNOPSIS
    Removes the given HostingUnit.
.DESCRIPTION
    Remove-HostingUnit.ps1 removes the HostingUnits when the hostingUnitName are provided.
    The original version of this script is compatible with Citrix DaaS July 2025 Release (DDC 125).
#>

# /*************************************************************************
# * Copyright © 2025. Cloud Software Group, Inc. All Rights Reserved.
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