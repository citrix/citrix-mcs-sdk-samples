<#
.SYNOPSIS
    Add a storage to an existing hosting unit.
.DESCRIPTION
    The `Add-Storage.ps1` script is designed to add a storage to an existing hosting unit.
    The original version of this script is compatible with Citrix Virtual Apps and Desktops 7 2203 Long Term Service Release (LTSR).
.INPUTS
    1. ConnectionName: The name of the hosting connection associated with the storage.
    2. HostingUnitName: The name of the hosting unit which the storage will be added.
    3. StoragePaths: The paths of the stroage to be added to the hosting unit.
    4. StorageType: The storage type to be added to the hosting unit.
    5. AdminAddress: The primary DDC address.
.OUTPUTS
    N/A
.NOTES
    Version      : 1.0.0
    Author       : Citrix Systems, Inc.
.EXAMPLE
    .\Add-Storage.ps1 `
        -ConnectionName "MyConnection" `
        -HostingUnitName "MyHostingUnit" `
        -StoragePaths "MyStorage1.storage", "MyStorage2.storage" `
        -StorageType "OSStorage" `
        -AdminAddress "MyDDC.MyDomain.local"
#>

# /*************************************************************************
# * Copyright © 2024. Cloud Software Group, Inc. All Rights Reserved.
# * This file is subject to the license terms contained
# * in the license file that is distributed with this file.
# *************************************************************************/

param(
    [string] $ConnectionName,
    [string] $HostingUnitName,
    [string[]] $StoragePaths,
    [string] $StorageType,
    [string] $AdminAddress = $null
)

# Enable Citrix PowerShell Cmdlets
Add-PSSnapin citrix*

# Convert the inputs into array formats.
$StoragePaths = @($StoragePaths)

###############################################
# Step 1: Add the Storage to the Hosting Unit #
###############################################
Write-Output "Step 1: Add the Storage to the Hosting Unit."

# Build and clean the storage path.
$connectionPath = "XDHyp:\Connections\" + $ConnectionName
$fullStoragePath = $StoragePaths | ForEach-Object { $connectionPath + "\" + $_ }
$fullStoragePath = $fullStoragePath -replace '[/\\]+', '\'

$fullStoragePath | ForEach-Object {
    # Configure the common parameters for Set-Item.
    $addHypHostingUnitStorageeParameters = @{
        LiteralPath = "XDHyp:\HostingUnits\" + $HostingUnitName
        StoragePath = $_
        StorageType = $StorageType
    }

    # If operating in an On-Prem environment, configure the AdminAddress.
    if ($AdminAddress) { $addHypHostingUnitStorageeParameters['AdminAddress'] = $AdminAddress }

    # Supersede the Storage of the Hosting Unit
    try {
        # Add the storage to the hosting unit
        & Add-HypHostingUnitStorage @addHypHostingUnitStorageeParameters

        # Ensure the storage is not superseded.
        $addHypHostingUnitStorageeParameters['Superseded'] = $false
        & Set-HypHostingUnitStorage @addHypHostingUnitStorageeParameters
    }
    catch {
        Write-Output $_
        exit
    }
}
