<#
.SYNOPSIS
    Creates a ProvScheme.
.DESCRIPTION
    Add-ProvScheme.ps1 creates a ProvScheme.
    The original version of this script is compatible with Citrix Virtual Apps and Desktops 7 2203 Long Term Service Release (LTSR).
.INPUTS
    1. ProvisioningSchemeName: Name of the new provisioning scheme.
    2. HostingUnitName: Name of the hosting unit used.
    3. IdentityPoolName: Name of the Identity Pool used.
    4. ProvisioningSchemeType: The Provisioning Scheme Type.
    5. MasterImageVM: Path to VM snapshot or template.
    6. CustomProperties: Specific properties for the hosting infrastructure.
    7. NetworkMapping: Specifies how the attached NICs are mapped to networks.
    8. VMCpuCount: The number of processors that will be used to create VMs from the provisioning scheme.
    9. VMMemoryMB: The maximum amount of memory that will be used to created VMs from the provisioning scheme in MB.
    10. InitialBatchSizeHint: The number of initial VMs that will be added to the MCS catalog.
    11. Scope: Administration scopes for the identity pool.
    12. CleanOnBoot: Reset VMs to initial state on start.
    13. AdminAddress: The primary DDC address.
    14. UseFullDiskCloneProvisioning: This flag enables the use of Full Clone provisioning.
    15. UseWriteBackCache: A flag to enable the Write-Back Cache feature. This should be set to True to enable the Write-Back Cache.
    16. WriteBackCacheDiskSize: Specifies the disk size of the Write-Back Cache.
    17. WriteBackCacheMemorySize: Defines the memory size of the Write-Back Cache.
    18. WriteBackCacheDriveLetter: Assigns the drive letter for the Write-Back Cache disk.
.OUTPUTS
    A New Provisioning Scheme Object
.NOTES
    Version      : 1.0.0
    Author       : Citrix Systems, Inc.
.EXAMPLE
    # Create a ProvScheme
    .\Add-ProvScheme.ps1 `
        -ProvisioningSchemeName "MyMachineCatalog" `
        -HostingUnitName "MyHostingUnit" `
        -IdentityPoolName "MyMachineCatalog" `
        -ProvisioningSchemeType "MCS" `
        -MasterImageVM "XDHyp:\HostingUnits\MyHostingUnit\MyVM.vm\MySnapshot.snapshot" `
        -CustomProperties "" `
        -NetworkMapping @{"0"="XDHyp:\HostingUnits\MyHostingUnit\MyNetwork.network"} `
        -VMCpuCount 1 `
        -VMMemoryMB 1024 `
        -Scope @() `
        -InitialBatchSizeHint 1 `
        -CleanOnBoot $true `
        -AdminAddress "MyDDC.MyDomain.local"

    # Create a ProvScheme with Full Clone
    .\Add-ProvScheme.ps1 `
        -ProvisioningSchemeName "MyMachineCatalog" `
        -HostingUnitName "MyHostingUnit" `
        -IdentityPoolName "MyMachineCatalog" `
        -ProvisioningSchemeType "MCS" `
        -MasterImageVM "XDHyp:\HostingUnits\MyHostingUnit\MyVM.vm\MySnapshot.snapshot" `
        -CustomProperties "" `
        -NetworkMapping @{"0"="XDHyp:\HostingUnits\MyHostingUnit\MyNetwork.network"} `
        -VMCpuCount 1 `
        -VMMemoryMB 1024 `
        -Scope @() `
        -InitialBatchSizeHint 1 `
        -CleanOnBoot $true `
        -AdminAddress "MyDDC.MyDomain.local" `
        -UseFullDiskCloneProvisioning $true

    # Create a ProvScheme with Write-Back Cache
    .\Add-ProvScheme.ps1 `
        -ProvisioningSchemeName "MyMachineCatalog" `
        -HostingUnitName "MyHostingUnit" `
        -IdentityPoolName "MyMachineCatalog" `
        -ProvisioningSchemeType "MCS" `
        -MasterImageVM "XDHyp:\HostingUnits\MyHostingUnit\MyVM.vm\MySnapshot.snapshot" `
        -CustomProperties "" `
        -NetworkMapping @{"0"="XDHyp:\HostingUnits\MyHostingUnit\MyNetwork.network"} `
        -VMCpuCount 1 `
        -VMMemoryMB 1024 `
        -Scope @() `
        -InitialBatchSizeHint 1 `
        -CleanOnBoot $true `
        -AdminAddress "MyDDC.MyDomain.local" `
        -UseWriteBackCache $True `
        -WriteBackCacheDiskSize 128 `
        -WriteBackCacheMemorySize 256 `
        -WriteBackCacheDriveLetter "W"
#>

# /*************************************************************************
# * Copyright © 2024. Cloud Software Group, Inc. All Rights Reserved.
# * This file is subject to the license terms contained
# * in the license file that is distributed with this file.
# *************************************************************************/

param(
    [string] $ProvisioningSchemeName,
    [string] $HostingUnitName,
    [string] $IdentityPoolName,
    [string] $ProvisioningSchemeType,
    [string] $MasterImageVM,
    [string] $CustomProperties,
    [hashtable] $NetworkMapping,
    [string] $VMCpuCount,
    [string] $VMMemoryMB,
    [string] $InitialBatchSizeHint,
    [string[]] $Scope,
    [switch] $CleanOnBoot = $false,
    [string] $AdminAddress = $null,
    [switch] $UseFullDiskCloneProvisioning = $false,
    [switch] $UseWriteBackCache = $false,
    [int] $WriteBackCacheDiskSize,
    [int] $WriteBackCacheMemorySize,
    [string] $WriteBackCacheDriveLetter
)

# Enable Citrix PowerShell Cmdlets
Add-PSSnapin citrix*

# Convert the inputs into array formats.
$Scope = @($Scope)

################################
# Step 1: Create a ProvScheme. #
################################
Write-Output "Step 1: Create a ProvScheme."

# Configure the common parameters for New-ProvScheme.
$newProvSchemeParameters = @{
    ProvisioningSchemeName  = $ProvisioningSchemeName
    HostingUnitName         = $HostingUnitName
    IdentityPoolName        = $identityPoolName
    ProvisioningSchemeType  = $ProvisioningSchemeType
    MasterImageVM           = $MasterImageVM
    CustomProperties        = $CustomProperties
    NetworkMapping          = $NetworkMapping
    VMCpuCount              = $VMCpuCount
    VMMemoryMB              = $VMMemoryMB
    InitialBatchSizeHint    = $InitialBatchSizeHint
    Scope                   = $Scope
    CleanOnBoot             = $CleanOnBoot
}

# If operating in an On-Prem environment, configure the AdminAddress.
if ($AdminAddress) { $newItemParameters['AdminAddress'] = $AdminAddress }

# If UseFullDiskCloneProvisioning is specified, configure the UseFullDiskCloneProvisioning.
if ($UseFullDiskCloneProvisioning) { $newItemParameters['UseFullDiskCloneProvisioning'] = $UseFullDiskCloneProvisioning }

# If UseWriteBackCache is specified, configure the Write-Back Cache.
if ($UseWriteBackCache) {
    $newItemParameters['UseWriteBackCache'] = $UseWriteBackCache
    $newItemParameters['WriteBackCacheDiskSize'] = $WriteBackCacheDiskSize
    $newItemParameters['WriteBackCacheMemorySize'] = $WriteBackCacheMemorySize
    $newItemParameters['WriteBackCacheDriveLetter'] = $WriteBackCacheDriveLetter
}

# Create a Provisoning Scheme
& New-ProvScheme @newProvSchemeParameters
