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
    5. ImageDefinitionName: Name of the image definition.
    6. ImageVersionNumber: The version number of the image.
    7. CustomProperties: Specific properties for the hosting infrastructure.
    8. NetworkMapping: Specifies how the attached NICs are mapped to networks.
    9. MachineProfile: Specifies the machine profile
    10. InitialBatchSizeHint: The number of initial VMs that will be added to the MCS catalog.
    11. Scope: Administration scopes for the identity pool.
    12. CleanOnBoot: Reset VMs to initial state on start.
    13. AdminAddress: The primary DDC address.
#>

# /*************************************************************************
# * Copyright © 2026. Cloud Software Group, Inc. All Rights Reserved.
# * This file is subject to the license terms contained
# * in the license file that is distributed with this file.
# *************************************************************************/

param(
    [string] $ProvisioningSchemeName,
    [string] $HostingUnitName,
    [string] $IdentityPoolName,
    [string] $ProvisioningSchemeType,
    [string] $ImageDefinitionName,
    [int] $ImageVersionNumber,
    [string] $CustomProperties,
    [hashtable] $NetworkMapping,
    [string] $MachineProfile,
    [string] $InitialBatchSizeHint,
    [string[]] $Scope,
    [switch] $CleanOnBoot = $false,
    [string] $AdminAddress = $null    
)

# Enable Citrix PowerShell Cmdlets
Add-PSSnapin -Name "Citrix.Host.Admin.V2", "Citrix.MachineCreation.Admin.V2"

# Convert the inputs into array formats.
$Scope = @($Scope)

$Image = Get-ProvImageVersionSpec -ImageVersionNumber $ImageVersionNumber -ImageDefinitionName $ImageDefinitionName | Where-Object IsPrepared -eq $True 
if (-not $Image) { throw "No prepared image version spec found for image definition '$ImageDefinitionName' and version $ImageVersionNumber." }

# Configure the common parameters for New-ProvScheme.
$newProvSchemeParameters = @{
    ProvisioningSchemeName = $ProvisioningSchemeName
    HostingUnitName        = $HostingUnitName
    IdentityPoolName       = $identityPoolName
    ProvisioningSchemeType = $ProvisioningSchemeType
    ImageVersionSpecUid    = $Image.ImageVersionSpecUid
    CustomProperties       = $CustomProperties
    NetworkMapping         = $NetworkMapping
    MachineProfile         = $MachineProfile
    InitialBatchSizeHint   = $InitialBatchSizeHint
    Scope                  = $Scope
    CleanOnBoot            = $CleanOnBoot
}

# If operating in an On-Prem environment, configure the AdminAddress.
if ($AdminAddress) { $newProvSchemeParameters['AdminAddress'] = $AdminAddress }

# Create a Provisioning Scheme
& New-ProvScheme @newProvSchemeParameters
