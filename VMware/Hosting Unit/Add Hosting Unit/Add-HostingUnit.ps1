<#
.SYNOPSIS
    Creation of a hosting unit.
.DESCRIPTION
    The `Add-HostingUnit.ps1` script facilitates the creation of a hosting unit.
    The original version of this script is compatible with Citrix Virtual Apps and Desktops 7 2203 Long Term Service Release (LTSR).
.INPUTS
    1. ConnectionName: The name for the new hosting connection.
    2. ResourceName: The name for the network resource of the hosting connection.
    3. StoragePaths: Names of the storages available on the hypervisor.
    4. NetworkPaths: Names of the networks available on the hypervisor.
    5. RootPath: The Root Path of the networks available on the hypervisor.
    6. AdminAddress: The primary DDC address.
.OUTPUTS
    A Hosting Unit
.NOTES
    Version      : 1.0.0
    Author       : Citrix Systems, Inc.
.EXAMPLE
    .\Add-HostingUnit.ps1 `
        -ConnectionName "MyConnection" `
        -ResourceName "Myresource" `
        -ConnectionType "VCenter" `
        -StoragePaths "/Datacenter.datacenter/0.0.0.0.computeresource/MyStorage.storage", "/Datacenter.datacenter/0.0.0.0.computeresource/MyStorage2.storage" `
        -NetworkPaths "/Datacenter.datacenter/0.0.0.0.computeresource/VM Network.network" `
        -RootPath "/Datacenter.datacenter/0.0.0.0.computeresource" `
        -AdminAddress "MyDDC.MyDomain.local"
#>

param(
    [string] $ConnectionName,
    [string] $ResourceName,
    [string] $ConnectionType,
    [string[]] $StoragePaths = $null,
    [string[]] $NetworkPaths = $null,
    [string] $RootPath,
    [string] $AdminAddress = $null,
    [string[]] $AvailabilityZonePath = @()
)

# /*************************************************************************
# * Copyright © 2024. Cloud Software Group, Inc. All Rights Reserved.
# * This file is subject to the license terms contained
# * in the license file that is distributed with this file.
# *************************************************************************/

# Enable Citrix PowerShell Cmdlets
Add-PSSnapin citrix*

# Convert the inputs into array formats.
$StoragePaths = @($StoragePaths)
$NetworkPaths = @($NetworkPaths)
$AvailabilityZonePath = @($AvailabilityZonePath)

######################################
# Step 1: Create a Storage Resource. #
######################################
Write-Output "Step 1: Create a Storage Resource."

# Configure the Job Group
$jobGroup = [Guid]::NewGuid()

# Configure the Hosting Connection Path
$connectionPath = @("XDHyp:\Connections\$ConnectionName\")

if (($ConnectionType -eq "Custom") -or ($ConnectionType -eq "AWS")) {
    $fullStoragePath = @()
}
else {
    # Configure the storage path.
    if (!$StoragePaths) {
        # If StoragePaths is not specified, select all storages.
        $StoragePaths = @(Get-ChildItem $connectionPath -Recurse | Where-Object { $_.FullName -like "*.storage"} | Select-Object -ExpandProperty ObjectPath)
    }

    # Clean the input storage paths
    $StoragePaths = $StoragePaths -replace '[/\\]+', '\'

    # Build the storage path
    $fullStoragePath = $StoragePaths | ForEach-Object {
        if (!$_.StartsWith($connectionPath)) { "$connectionPath\$_" }
        else { $_ }
    }

    # Clean the storage path
    $fullStoragePath = $fullStoragePath -replace '[/\\]+', '\'

    # Configure other variables with default values.
    $storageType = "TemporaryStorage"

    # Configure the common parameters for New-HypStorage.
    $newHypStorageParameters = @{
        StoragePath = $fullStoragePath
        StorageType = $storageType
        JobGroup = $jobGroup
    }

    # If operating in an On-Prem environment, configure the AdminAddress.
    if ($AdminAddress) { $newHypStorageParameters['AdminAddress'] = $AdminAddress }

    # Create a broker hypervisor connection
    try { & New-HypStorage @newHypStorageParameters }
    catch {
        Write-Output $_
        exit
    }
}

######################################
# Step 2: Create a Network Resource. #
######################################
Write-Output "Step 2: Create a Network Resource."

# Configure the network path
if (!$NetworkPaths) {
    # If NetworkPaths is not specified, select all storages.
    $NetworkPaths = @(Get-ChildItem $connectionPath -Recurse | Where-Object { $_.FullName -like "*.network"} | Select-Object -ExpandProperty ObjectPath)
}

# Clean the input network paths
$NetworkPaths = $NetworkPaths -replace '[/\\]+', '\'

# Build the network path
$fullNetworkPath = $NetworkPaths | ForEach-Object {
    if (!$_.StartsWith($connectionPath)) { "$connectionPath\$_" }
    else { $_ }
}

# Clean the network paths
$fullNetworkPath = $fullNetworkPath -replace '[/\\]+', '\'

# Configure the hosting unit path.
$hostingUnitPath = @("XDHyp:\HostingUnits\$ResourceName")

# Clean the input root path
$RootPath = $RootPath -replace '[/\\]+', '\'

# Configure the root path
if (!$RootPath.StartsWith($connectionPath)) {
    $RootPath = "$connectionPath\$RootPath"
}
$fullRootPath = $RootPath -replace '[/\\]+', '\'

# Configure the common parameters for New-Item.
$newItemParameters = @{
    HypervisorConnectionName = $ConnectionName
    JobGroup = $jobGroup
    NetworkPath = $fullNetworkPath
    Path = $hostingUnitPath
    RootPath = $fullRootPath
    StoragePath = $fullStoragePath
}

# If operating in an On-Prem environment, configure the AdminAddress.
if ($AdminAddress) { $newItemParameters['AdminAddress'] = $AdminAddress }

# If PersonalvDiskStoragePath is specified, configure the PersonalvDiskStoragePath.
if ($PersonalvDiskStoragePath) { $newItemParameters['PersonalvDiskStoragePath'] = $PersonalvDiskStoragePath }

# If AvailabilityZonePath is specified, configure the AvailabilityZonePath.
if ($AvailabilityZonePath) {
    if (!$AvailabilityZonePath.StartsWith($connectionPath)) {
        $AvailabilityZonePath = "$connectionPath\$AvailabilityZonePath"
    }
    $fullAvailabilityZonePath = $AvailabilityZonePath -replace '[/\\]+', '\'
    $newItemParameters['AvailabilityZonePath'] = $fullAvailabilityZonePath
}

# Create a resource item.
try { & New-Item @newItemParameters }
catch {
    Write-Output $_
    exit
}
