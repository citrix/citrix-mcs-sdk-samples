<#
.SYNOPSIS
    Supersede a storage from an existing hosting unit.
.DESCRIPTION
    The `Supersede-Storage.ps1` script is designed to supersede a storage from an existing hosting unit.
    The original version of this script is compatible with Citrix Virtual Apps and Desktops 7 2203 Long Term Service Release (LTSR).
.INPUTS
    1. ConnectionName: The name of the hosting connection associated with the storage.
    2. HostingUnitName: The name of the hosting unit from which the storage will be superseded.
    3. StoragePaths: The paths of the stroage to be superseded from the hosting unit.
    4. StorageType: The storage type to be superseded from the hosting unit.
    5. Superseded: Flag to indicate if the storage of the hosting unit is to be superseded.
    6. AdminAddress: The primary DDC address.
.OUTPUTS
.NOTES
    Version      : 1.0.0
    Author       : Citrix Systems, Inc.
.EXAMPLE
    .\Supersede-Storage.ps1 `
        -ConnectionName "MyConnection" `
        -HostingUnitName "MyHostingUnit" `
        -StoragePaths "/Datacenter.datacenter/0.0.0.0.computeresource/MyStorage.storage", "/Datacenter.datacenter/0.0.0.0.computeresource/MyStorage2.storage" `
        -StorageType "OSStorage" `
        -Superseded $true `
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
    [bool] $Superseded = $false,
    [string] $AdminAddress = $null
)

# Enable Citrix PowerShell Cmdlets
Add-PSSnapin citrix*

# Convert the inputs into array formats.
$StoragePaths = @($StoragePaths)

#####################################################
# Step 1: Supersede the Storage of the Hosting Unit #
#####################################################
Write-Output "Step 1: Supersede the Storage of the Hosting Unit."

# Build and clean the storage path.
$connectionPath = "XDHyp:\Connections\" + $ConnectionName
$fullStoragePath = $StoragePaths | ForEach-Object { $connectionPath + "\" + $_ }
$fullStoragePath = $fullStoragePath -replace '[/\\]+', '\'

$fullStoragePath | ForEach-Object {
    # Configure the common parameters for Set-Item.
    $setHypHostingUnitStorageParameters = @{
        LiteralPath = "XDHyp:\HostingUnits\" + $HostingUnitName
        StoragePath = $_
        StorageType = $StorageType
        Superseded = $Superseded
    }

    # If operating in an On-Prem environment, configure the AdminAddress.
    if ($AdminAddress) { $setHypHostingUnitStorageParameters['AdminAddress'] = $AdminAddress }

    # Supersede the Storage of the Hosting Unit
    try { & Set-HypHostingUnitStorage @setHypHostingUnitStorageParameters }
    catch {
        Write-Output $_
        exit
    }
}
