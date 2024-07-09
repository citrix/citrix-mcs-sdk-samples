<#
.SYNOPSIS
    Creation of a hosting unit with vGPUs.
.DESCRIPTION
    The `Add-HostingUnit-vGPUs.ps1` script facilitates the creation of a hosting unit with vGPUs.
    The original version of this script is compatible with Citrix Virtual Apps and Desktops 7 2203 Long Term Service Release (LTSR).
.INPUTS
    N/A
.OUTPUTS
    A Hosting Unit Object
.NOTES
    Version      : 1.0.0
    Author       : Citrix Systems, Inc.
.EXAMPLE
    .\Add-HostingUnit-vGPUs.ps1
#>

# /*************************************************************************
# * Copyright © 2024. Cloud Software Group, Inc. All Rights Reserved.
# * This file is subject to the license terms contained
# * in the license file that is distributed with this file.
# *************************************************************************/

# Example Configuration.
$ConnectionName = "MyConnectionName"
$jobGroup = [Guid]::NewGuid()
$networkPath = "XDHyp:\Connections\MyConnectionName\MyNetwork.network"
$hostingUnitPath = "XDHyp:\HostingUnits\MyHostingUnitName"
$connectionPath = "XDHyp:\Connections\MyConnectionName"
$storagePath = "XDHyp:\Connections\MyConnectionName\MyStorage.storage"
$GpuTypePath = "XDHyp:\Connections\MyConnectionName\Group of Intel Corporation Iris Pro Graphics P580 GPUs.gpugroup\Intel GVT-g.vgputype"

# Create a hosting unit utilizing vGPUs.
# By Specifying the parameter -GpuTypePath, vGPUs are enalbed.
New-Item `
    -HypervisorConnectionName $ConnectionName `
    -JobGroup $jobGroup `
    -NetworkPath $networkPath `
    -Path $hostingUnitPath `
    -RootPath $connectionPath `
    -StoragePath $storagePath `
    -GpuTypePath $GpuTypePath
