﻿<#
.SYNOPSIS
    Creates a ProvScheme using Full Clone.
.DESCRIPTION
    Create-ProvScheme-FullClone.ps1 creates a ProvScheme that utilizes Full Clone.
    The original version of this script is compatible with Citrix Virtual Apps and Desktops 7 2203 Long Term Service Release (LTSR).
.INPUTS
    N/A
.OUTPUTS
    A New Provisioning Scheme Object
.NOTES
    Version      : 1.1.0
    Author       : Citrix Systems, Inc.
.EXAMPLE
    .\Create-ProvScheme-FullClone.ps1
#>

# /*************************************************************************
# * Copyright © 2024. Cloud Software Group, Inc. All Rights Reserved.
# * This file is subject to the license terms contained
# * in the license file that is distributed with this file.
# *************************************************************************/

# Example Configuration for New-ProvScheme.
$ProvisioningSchemeName  = "MyMachineCatalog"
$IdentityPoolName        = "MyMachineCatalog"
$HostingUnitName         = "MyHostingUnit"
$ProvisioningSchemeType  = "MCS"
$MasterImageVM           = "XDHyp:\HostingUnits\MyHostingUnit\MyVM.vm\MySnapshot.snapshot"
$NetworkMapping          = @{"0"="XDHyp:\HostingUnits\MyHostingUnit\MyNetwork.network"}
$VMCpuCount              = 1
$VMemoryMB              = 1024
$InitialBatchSizeHint    = 1
$Scope                   = @()
$CustomProperties        = ""

# Create a Provisoning Scheme
# The parameter -UseFullDiskCloneProvisioning is a flag to enable the Full Clone feature.
New-ProvScheme `
    -ProvisioningSchemeName $ProvisioningSchemeName `
    -IdentityPoolName $IdentityPoolName `
    -HostingUnitName $HostingUnitName `
    -ProvisioningSchemeName $ProvisioningSchemeType `
    -MasterImageVM $MasterImageVM `
    -NetworkMapping $NetworkMapping `
    -VMCpuCount $VMCpuCount `
    -VMMemoryMB $VMemoryMB `
    -InitialBatchSizeHint $InitialBatchSizeHint `
    -Scope $Scope `
    -CustomProperties $CustomProperties `
    -CleanOnBoot:$false `
    -UseFullDiskCloneProvisioning
