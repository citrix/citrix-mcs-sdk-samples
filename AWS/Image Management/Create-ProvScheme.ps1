<#
.SYNOPSIS
    Creates a provisioning scheme by a prepared image.
.DESCRIPTION
    Create-ProvScheme.ps1 creates a provisioning scheme by a prepared image.
    The original version of this script is compatible with Citrix Virtual Apps and Desktops 7 2411.
.INPUTS
    1. ProvisioningSchemeName: Name of the new provisioning scheme.
    2. HostingUnitName: Name of the hosting unit used.
    3. IdentityPoolName: Name of the Identity Pool used.
    4. ProvisioningSchemeType: The Provisioning Scheme Type.
    5. ImageDefinitionName: Path to VM snapshot or template.
    6. ImageVersionNumber: The version number of the image.
    7. CustomProperties: Specific properties for the hosting infrastructure.
    8. NetworkMapping: Specifies how the attached NICs are mapped to networks.
    9. ServiceOffering: The service offering used.
    10. InitialBatchSizeHint: The number of initial VMs that will be added to the MCS catalog.
    11. Scope: Administration scopes for the identity pool.
    12. CleanOnBoot: Reset VMs to initial state on start.
    13. AdminAddress: The primary DDC address.
    14. UseFullDiskCloneProvisioning: This flag enables the use of Full Clone provisioning.
    15. UseWriteBackCache: A flag to enable the Write-Back Cache feature. This should be set to True to enable the Write-Back Cache.
    16. WriteBackCacheDiskSize: Specifies the disk size of the Write-Back Cache.
    17. WriteBackCacheMemorySize: Defines the memory size of the Write-Back Cache.
    18. WriteBackCacheDriveLetter: Assigns the drive letter for the Write-Back Cache disk.
#>

# /*************************************************************************
# * Copyright © 2025. Cloud Software Group, Inc. All Rights Reserved.
# * This file is subject to the license terms contained
# * in the license file that is distributed with this file.
# *************************************************************************/

param(
    [string] $ProvisioningSchemeName,
    [string] $HostingUnitName,
    [string] $IdentityPoolName,
    [string] $ImageDefinitionName,
    [int] $ImageVersionNumber,
    [string] $MachineProfile,
    [Parameter(Mandatory = $false)][string] $CustomProperties = "",
    [Parameter(Mandatory = $false)][switch] $CleanOnBoot,
    [Parameter(Mandatory = $false)][string] $AdminAddress = $null,
    [Parameter(Mandatory = $false)][switch] $UseFullDiskCloneProvisioning = $false,
    [Parameter(Mandatory = $false)][int] $InitialBatchSizeHint = 0,
    [Parameter(Mandatory = $false)][string] $ProvisioningSchemeType = "MCS",
    [Parameter(Mandatory = $false)][switch] $UseWriteBackCache = $false,
    [Parameter(Mandatory = $false)][int] $WriteBackCacheDiskSize = 0,
    [Parameter(Mandatory = $false)][int] $WriteBackCacheMemorySize = 0,
    [Parameter(Mandatory = $false)][string] $WriteBackCacheDriveLetter = ""
)

# Enable Citrix PowerShell Cmdlets
Add-PSSnapin -Name "Citrix.Host.Admin.V2", "Citrix.MachineCreation.Admin.V2"

# Convert the inputs into array formats.
$Scope = @($Scope)

$Image = Get-ProvImageVersionSpec -ImageVersionNumber $ImageVersionNumber -ImageDefinitionName $ImageDefinitionName | Where-Object IsPrepared -eq $True

# Configure the common parameters for New-ProvScheme.
$newProvSchemeParameters = @{
    ProvisioningSchemeName = $ProvisioningSchemeName
    HostingUnitName        = $HostingUnitName
    IdentityPoolName       = $IdentityPoolName
    MachineProfile         = $MachineProfile
    ProvisioningSchemeType = $ProvisioningSchemeType
    ImageVersionSpecUid    = $Image.ImageVersionSpecUid
    CustomProperties       = $CustomProperties
    InitialBatchSizeHint   = $InitialBatchSizeHint
    CleanOnBoot            = $CleanOnBoot
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
