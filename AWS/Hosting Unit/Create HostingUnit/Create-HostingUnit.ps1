﻿<#
.SYNOPSIS
    Creates the HostingUnit.
.DESCRIPTION
    Create-HostingUnit.ps1 creates the HostingUnit when connectionName, hostingUnitName, availabilityzone, vpcName, and networkPaths are provided.
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
$connectionName = "demo-hostingconnection"
$hostingUnitName = "demo-hostingunit"
$availabilityzone = "us-east-1a"
$vpcName = "Default VPC"

$jobGroup = [Guid]::NewGuid()
$connectionPath = "XDHyp:\Connections\" + $connectionName
$hostingUnitPath = "XDHyp:\HostingUnits\" + $HostingUnitName
$rootPath = $connectionPath + "\" + $vpcName + ".virtualprivatecloud\"
$availabilityZonePath = @($rootPath + $availabilityzone + ".availabilityzone")
$networkPaths = (Get-ChildItem $availabilityZonePath[0] | Where-Object ObjectTypeName -eq "network") | Select-Object -ExpandProperty FullPath # will select all the networks in the availability zone

########################################
# Step 1: Create a Hosting Resources.  #
########################################

New-Item -Path $hostingUnitPath -AvailabilityZonePath $availabilityZonePath -HypervisorConnectionName $connectionName -JobGroup $jobGroup -RootPath $rootPath -NetworkPath $networkPaths