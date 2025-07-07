<#
.SYNOPSIS
    Creates an MCS Image Definition and Image Version. Applicable for Citrix DaaS and on-prem.
.DESCRIPTION
    CreateImageVersion creates an MCS Image Defintion and an Image Version in AWS.
    This script is similar to the "Image" button in Citrix Studio. It creates the Image Definition and Image Version in AWS.
    The original version of this script is compatible with Citrix DaaS July 2025 Release (DDC 125).
#>

# /*************************************************************************
# * Copyright © 2025. Cloud Software Group, Inc. All Rights Reserved.
# * This file is subject to the license terms contained
# * in the license file that is distributed with this file.
# *************************************************************************/

# Add Citrix snap-ins
Add-PSSnapin -Name "Citrix.Host.Admin.V2","Citrix.MachineCreation.Admin.V2"

#####################################################
# Step 1: Create the Image Definition
#####################################################
$ImageDefinitionName = "TestImages"
$HypervisorConnectionName = "TestConnection"
$OsType = "Windows"

New-ProvImageDefinition -ImageDefinitionName $ImageDefinitionName -OsType $OsType -VDASessionSupport MultiSession
Add-ProvImageDefinitionConnection -ImageDefinitionName $ImageDefinitionName -HypervisorConnectionName $HypervisorConnectionName

#####################################################
# Step 2: Create the Image Version
#####################################################
$MasterImagePath = 'XDHyp:\HostingUnits\TestHostingUnit\WindowsTestImage-2403 (ami-05f34ffc7766dfc58).template'
$MachineProfilePath = 'XDHyp:\HostingUnits\TestHostingUnit\us-east-1a.availabilityzone\WindowsTestVm-2403 (i-097e6e571837e4493).vm'
$HostingUnitName = "TestHostingUnit"

New-ProvImageVersion -ImageDefinitionName $ImageDefinitionName
$MasterImageVersion = Add-ProvImageVersionSpec `
    -ImageDefinitionName $ImageDefinitionName `
    -ImageVersionNumber 1 `
    -HostingUnitName $HostingUnitName `
    -MasterImagePath $MasterImagePath

$ImageVersion = New-ProvImageVersionSpec `
    -MachineProfile $MachineProfilePath `
    -SourceImageVersionSpecUid $MasterImageVersion.ImageVersionSpecUid

#####################################################
# Use the returned ImageVersionSpecUid with
# New-ProvScheme -ImageVersionSpecUid parameter
# rather than the -MasterImageVm
#####################################################
Write-Output "New Image Version UID for use in creating Provisioning Scheme: " $ImageVersion.ImageVersionSpecUid
