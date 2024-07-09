<#
.SYNOPSIS
    Creation of a hosting unit with IntelliCache.
.DESCRIPTION
    The `Add-HostingUnit-IntelliCache.ps1` script facilitates the creation of a hosting unit with IntelliCache
    The original version of this script is compatible with Citrix Virtual Apps and Desktops 7 2203 Long Term Service Release (LTSR).
.INPUTS
    N/A
.OUTPUTS
    A Hosting Unit with IntelliCache
.NOTES
    Version      : 1.0.0
    Author       : Citrix Systems, Inc.
.EXAMPLE
    .\Add-HostingUnit-IntelliCache.ps1
#>

# /*************************************************************************
# * Copyright © 2024. Cloud Software Group, Inc. All Rights Reserved.
# * This file is subject to the license terms contained
# * in the license file that is distributed with this file.
# *************************************************************************/

# Enable Citrix PowerShell Cmdlets
Add-PSSnapin citrix*

# Example Configuration.
$ConnectionName = "MyConnectionName"
$jobGroup = [Guid]::NewGuid()
$networkPath = "XDHyp:\Connections\MyConnectionName\MyNetwork.network"
$hostingUnitPath = "XDHyp:\HostingUnits\MyHostingUnitName"
$connectionPath = "XDHyp:\Connections\MyConnectionName"
$storagePath = "XDHyp:\Connections\MyConnectionName\MyStorage.storage"

# Create a hosting unit utilizing IntelliCache.
# The parameter -UseLocalStorageCaching is a flag to enable IntelliCache (local storage caching).
New-Item `
    -HypervisorConnectionName $ConnectionName `
    -JobGroup $jobGroup `
    -NetworkPath $networkPath `
    -Path $hostingUnitPath `
    -RootPath $connectionPath[0] `
    -StoragePath $storagePath `
    -UseLocalStorageCaching