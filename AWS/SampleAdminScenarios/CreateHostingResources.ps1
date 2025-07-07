<#
.SYNOPSIS
    Creates the HostingConnection and Hosting Unit.
.DESCRIPTION
    Creates a Hosting Connection and Hosting Unit within the specified availability zone, cloud region, config zone, and VPC
    The original version of this script is compatible with Citrix DaaS July 2025 Release (DDC 125).
#>

# /*************************************************************************
# * Copyright © 2025. Cloud Software Group, Inc. All Rights Reserved.
# * This file is subject to the license terms contained
# * in the license file that is distributed with this file.
# *************************************************************************/

# Add Citrix snap-ins
Add-PSSnapin -Name "Citrix.Host.Admin.V2","Citrix.MachineCreation.Admin.V2"

########################################
# Step 1: Create a Hosting Connection. #
########################################
# [User Input Required] Setup parameters for creating hosting connection
$connectionName = "demo-hostingconnection"
$cloudRegion = "us-east-1"
$apiKey = "aaaaaaaaaaaaaaaaaaaa"
$zoneUid = "00000000-0000-0000-0000-000000000000"

$secureUserInput = Read-Host 'Please enter your secret key' -AsSecureString
$encryptedInput = ConvertFrom-SecureString -SecureString $secureUserInput
$secureKey = ConvertTo-SecureString -String $encryptedInput

$connectionPath = "XDHyp:\Connections\" + $connectionName

$connection = New-Item -Path $connectionPath -ConnectionType "AWS" -HypervisorAddress "https://ec2.$($cloudRegion).amazonaws.com" -Persist -Scope @() -UserName $apiKey -SecurePassword $secureKey -ZoneUid $zoneUid

New-BrokerHypervisorConnection -HypHypervisorConnectionUid $connection.HypervisorConnectionUid

##################################
# Step 2: Create a Hosting Unit. #
##################################
# [User Input Required] Setup parameters for creating hosting unit
$hostingUnitName = "demo-hostingunit"
$availabilityzone = "us-east-1a"
$vpcName = "Default VPC"

$jobGroup = [Guid]::NewGuid()
$hostingUnitPath = "XDHyp:\HostingUnits\" + $HostingUnitName
$rootPath = $connectionPath + "\" + $vpcName + ".virtualprivatecloud\"
$availabilityZonePath = @($rootPath + $availabilityzone + ".availabilityzone")
$networkPaths = (Get-ChildItem $availabilityZonePath[0] | Where-Object ObjectType -eq "Network") | Select-Object -ExpandProperty FullPath # will select all the networks in the availability zone

New-Item -Path $hostingUnitPath -AvailabilityZonePath $availabilityZonePath -HypervisorConnectionName $connectionName -JobGroup $jobGroup -PersonalvDiskStoragePath @() -RootPath $rootPath -NetworkPath $networkPaths