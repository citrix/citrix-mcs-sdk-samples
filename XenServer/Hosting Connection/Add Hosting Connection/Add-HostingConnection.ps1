<#
.SYNOPSIS
    Creation of a hosting connection and associated resources.
.DESCRIPTION
    Add-HostingConnection.ps1 creates a hosting connection and associated resources.
    The original version of this script is compatible with Citrix Virtual Apps and Desktops 7 2203 Long Term Service Release (LTSR).
.INPUTS
    1. ConnectionName: The name for the new hosting connection.
    2. ResourceName: The name for the network resource of the hosting connection.
    3. ConnectionType: The type of hosting connection (e.g., "VCenter").
    4. HypervisorAddress: The IP address of the hypervisor.
    5. ZoneUid: The UID that corresponds to the Zone in which the hosting connection is associated.
    6. AdminAddress: The primary DDC address.
    7. UserName: Username for hypervisor access.
    8. StoragePaths: Names of the storages available on the hypervisor.
    9. NetworkPaths: Names of the networks available on the hypervisor.
    10. RootPath: The Root Path of the networks available on the hypervisor.
    11. Metadata: The metadata of the hosting connection.
    12. CustomProperties: The CustomProperties of the hosting connection.
    13. Scope: Administration scopes for the hosting connection.
    14. SSLThumbprint: A unique identifier for the certificates of the hypervisor.
    15. PluginId: The Identification of the Plugin, such as "AzureRmFactory"
    16. PersonalvDiskStoragePath: The path of personal vDisk Storage.
    17. AvailabilityZonePath: The path of Availability Zone
    19. UseLocalStorageCaching: Flag to enable IntelliCache (local storage caching).
    20. GpuTypePath: The path of the vGPU available on the hypervisor.
.OUTPUTS
    A Hosting Connection and an associated Hosting Unit
.NOTES
    Version      : 1.0.0
    Author       : Citrix Systems, Inc.
.EXAMPLE
    # Create a hosting connection.
    .\Add-HostingConnection.ps1 `
        -ConnectionName "MyConnection" `
        -ResourceName "Myresource" `
        -ConnectionType "VCenter" `
        -HypervisorAddress "https://0.0.0.0" `
        -ZoneUid "00000000-0000-0000-0000-000000000000" `
        -AdminAddress "MyDDC.MyDomain.local" `
        -UserName "MyUserName" `
        -StoragePaths "MyStorage.storage", "MyStorage2.storage" `
        -NetworkPaths "MyNetwork.network" `
        -RootPath "/" `
        -Metadata @{"Citrix_Orchestration_Hypervisor_Secret_Allow_Edit"="false"}

    # Create a hosting connection with IntellieCache.
    .\Add-HostingConnection.ps1 `
        -ConnectionName "MyConnection" `
        -ResourceName "Myresource" `
        -ConnectionType "VCenter" `
        -HypervisorAddress "https://0.0.0.0" `
        -ZoneUid "00000000-0000-0000-0000-000000000000" `
        -AdminAddress "MyDDC.MyDomain.local" `
        -UserName "MyUserName" `
        -StoragePaths "MyStorage.storage", "MyStorage2.storage" `
        -NetworkPaths "MyNetwork.network" `
        -RootPath "/" `
        -Metadata @{"Citrix_Orchestration_Hypervisor_Secret_Allow_Edit"="false"} `
        -UseLocalStorageCaching

    # Create a hosting connection with vGPUs.
    .\Add-HostingConnection.ps1 `
        -ConnectionName "MyConnection" `
        -ResourceName "Myresource" `
        -ConnectionType "VCenter" `
        -HypervisorAddress "https://0.0.0.0" `
        -ZoneUid "00000000-0000-0000-0000-000000000000" `
        -AdminAddress "MyDDC.MyDomain.local" `
        -UserName "MyUserName" `
        -StoragePaths "MyStorage.storage", "MyStorage2.storage" `
        -NetworkPaths "MyNetwork.network" `
        -RootPath "/" `
        -Metadata @{"Citrix_Orchestration_Hypervisor_Secret_Allow_Edit"="false"} `
        -GpuTypePath "XDHyp:\Connections\MyConnection\MyGpuGroup.gpugroup\MyvGPU.vgputype"
#>

# /*************************************************************************
# * Copyright © 2024. Cloud Software Group, Inc. All Rights Reserved.
# * This file is subject to the license terms contained
# * in the license file that is distributed with this file.
# *************************************************************************/

param(
    [string] $ConnectionName,
    [string] $ResourceName,
    [string] $ConnectionType,
    [string[]] $HypervisorAddress = $null,
    [guid] $ZoneUid,
    [string] $AdminAddress = $null,
    [string] $UserName,
    [string[]] $StoragePaths = $null,
    [string[]] $NetworkPaths = $null,
    [string] $RootPath = $null,
    [string] $SSLThumbprint = "",
    [string] $CustomProperties = "",
    [hashtable] $Metadata = @{},
    [string[]] $Scope = @(),
    [string] $PluginId = "",
    [string] $PersonalvDiskStoragePath = $null,
    [string[]] $AvailabilityZonePath = @()
)

# Enable Citrix PowerShell Cmdlets
Add-PSSnapin citrix*

# Convert the inputs into array formats.
$HypervisorAddress = @($HypervisorAddress)
$StoragePaths = @($StoragePaths)
$NetworkPaths = @($NetworkPaths)
$AvailabilityZonePath = @($AvailabilityZonePath)

########################################
# Step 1: Create a Hosting Connection. #
########################################
Write-Output "Step 1: Create a Hosting Connection."

# Configure the parameters for a new broker hypervisor connection
$connectionPath = "XDHyp:\Connections\" + $ConnectionName

# Build the secure password
$SecurePasswordInput = Read-Host $"Please enter the password of $UserName to connect to the hypervisor" -AsSecureString
$EncryptedPasswordInput = $SecurePasswordInput | ConvertFrom-SecureString
$SecurePassword = ConvertTo-SecureString -String $EncryptedPasswordInput

# Configure the common parameters for New-Item.
$newItemParameters = @{
    ConnectionType = $ConnectionType
    CustomProperties = $CustomProperties
    HypervisorAddress = $HypervisorAddress
    Metadata = $metadata
    Path = $connectionPath
    Persist = $true
    Scope = $Scope
    UserName = $UserName
    SecurePassword = $SecurePassword
    ZoneUid = $ZoneUid
}

# If operating in an On-Prem environment, configure the AdminAddress.
if ($AdminAddress) { $newItemParameters['AdminAddress'] = $AdminAddress }

# If SSLThumbprint is specified, configure the SSLThumbprint.
if ($SSLThumbprint) { $newItemParameters['SSLThumbprint'] = $SSLThumbprint }

# If PluginId is specified, configure the PluginId.
if ($PluginId) { $newItemParameters['PluginId'] = $PluginId }

# Create an item for the new hosting connection
try { $connection = & New-Item @newItemParameters }
catch {
    Write-Output $_
    exit
}

# Configure the common parameters for New-BrokerHypervisorConnection.
$newBrokerHypervisorConnectionParameters = @{
    HypHypervisorConnectionUid = $connection.HypervisorConnectionUid
}

# If operating in an On-Prem environment, configure the AdminAddress.
if ($AdminAddress) { $newBrokerHypervisorConnectionParameters['AdminAddress'] = $AdminAddress }

# Create a broker hypervisor connection
try { & New-BrokerHypervisorConnection @newBrokerHypervisorConnectionParameters }
catch {
    Write-Output $_
    exit
}

######################################
# Step 2: Create a Storage Resource. #
######################################
Write-Output "Step 2: Create a Storage Resource."

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
# Step 3: Create a Network Resource. #
######################################
Write-Output "Step 3: Create a Network Resource."

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
