<#
.SYNOPSIS
    Edit the HostingUnit.
.DESCRIPTION
    Edit-HostingUnit.ps1 edits the HostingUnit properties.
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

# [User Input Required] Setup parameters for editting the hosting unit
$hostingUnitName = "demo-hostingunit"
$renameHostingUnitName = "demo-renamehostingunit"
$hostingUnitPath = "XDHyp:\HostingUnits\" + $HostingUnitName
$hostingUnitObject = $null

# Check if hosting unit is there
try
{
    $hostingUnitObject = Get-Item -LiteralPath $hostingUnitPath -ErrorAction stop
}
catch
{
    throw "Hosting unit does not exist"
}

$availabilityZonePath = "$($hostingUnitObject.RootPath)\$($hostingUnitObject.AvailabilityZones[0].AvailabilityZoneId).availabilityzone"
$networkPaths = (Get-ChildItem $availabilityZonePath | Where ObjectType -eq "Network") | Select-Object -ExpandProperty FullPath # will select all the networks in the availability zone

##################################
# Step 1: Set the network paths. #
##################################

Set-Item -NetworkPath $networkPaths -Path $hostingUnitPath

####################################
# Step 2: Rename the Hosting Unit. #
####################################

Rename-Item -NewName $renameHostingUnitName -Path $hostingUnitPath