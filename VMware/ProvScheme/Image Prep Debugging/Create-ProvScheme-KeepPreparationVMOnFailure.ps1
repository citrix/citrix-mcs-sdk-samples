<#
.SYNOPSIS
    Creates a ProvScheme that keeps the image preparation VM on the hypervisor when image preparation fails.
.DESCRIPTION
    Create-ProvScheme-KeepPreparationVMOnFailure.ps1 creates a ProvScheme using the
    -KeepPreparationVMOnFailure switch of New-ProvScheme.

    By default MCS removes the temporary image preparation VM whether image preparation succeeds or
    fails. When -KeepPreparationVMOnFailure is supplied and image preparation fails, the image
    preparation VM and its resources are left on the hypervisor so the failure can be investigated.
    If image preparation succeeds, the VM is removed automatically and the switch has no effect.

    On a failed run the provisioning scheme is still created, but it is not operational.

    The original version of this script is compatible with CVAD Cloud 123 (and the equivalent CVAD
    on-prem release) and later.
.INPUTS
    1. ProvisioningSchemeName: Name of the new provisioning scheme.
    2. IdentityPoolName: Name of the Identity Pool used.
    3. HostingUnitName: Name of the hosting unit used.
    4. ProvisioningSchemeType: The Provisioning Scheme Type.
    5. MasterImageVM: Path to VM snapshot or template.
    6. NetworkMapping: Specifies how the attached NICs are mapped to networks.
    7. VMCpuCount: The number of processors that will be used to create VMs from the provisioning scheme.
    8. VMMemoryMB: The maximum amount of memory that will be used to create VMs from the provisioning scheme in MB.
    9. InitialBatchSizeHint: The number of initial VMs that will be added to the MCS catalog.
    10. Scope: Administration scopes for the identity pool.
    11. CustomProperties: Specific properties for the hosting infrastructure.
    12. AdminAddress: The primary DDC address.
.OUTPUTS
    A New Provisioning Scheme Object
.NOTES
    Version      : 1.0.0
    Author       : Citrix Systems, Inc.
.EXAMPLE
    .\Create-ProvScheme-KeepPreparationVMOnFailure.ps1 `
        -ProvisioningSchemeName "MyMachineCatalog" `
        -IdentityPoolName "MyMachineCatalog" `
        -HostingUnitName "MyHostingUnit" `
        -ProvisioningSchemeType "MCS" `
        -MasterImageVM "XDHyp:\HostingUnits\MyHostingUnit\MyVM.vm\MySnapshot.snapshot" `
        -NetworkMapping @{"0"="XDHyp:\HostingUnits\MyHostingUnit\MyNetwork.network"} `
        -VMCpuCount 1 `
        -VMMemoryMB 1024 `
        -InitialBatchSizeHint 1 `
        -Scope @() `
        -CustomProperties "" `
        -AdminAddress "MyDDC.MyDomain.local"
#>

# /*************************************************************************
# * Copyright © 2026. Cloud Software Group, Inc. All Rights Reserved.
# * This file is subject to the license terms contained
# * in the license file that is distributed with this file.
# *************************************************************************/

param(
    [string] $ProvisioningSchemeName,
    [string] $IdentityPoolName,
    [string] $HostingUnitName,
    [string] $ProvisioningSchemeType,
    [string] $MasterImageVM,
    [hashtable] $NetworkMapping,
    [string] $VMCpuCount,
    [string] $VMMemoryMB,
    [string] $InitialBatchSizeHint,
    [string[]] $Scope,
    [string] $CustomProperties,
    [string] $AdminAddress = $null
)

# Enable Citrix PowerShell Cmdlets
Add-PSSnapin citrix*

# Convert the inputs into array formats.
$Scope = @($Scope)

# Configure the parameters for New-ProvScheme. CleanOnBoot and KeepPreparationVMOnFailure are always
# set so that a failed image preparation leaves the preparation VM on the hypervisor for investigation.
$newProvSchemeParameters = @{
    ProvisioningSchemeName     = $ProvisioningSchemeName
    IdentityPoolName           = $IdentityPoolName
    HostingUnitName            = $HostingUnitName
    ProvisioningSchemeType     = $ProvisioningSchemeType
    MasterImageVM              = $MasterImageVM
    NetworkMapping             = $NetworkMapping
    VMCpuCount                 = $VMCpuCount
    VMMemoryMB                 = $VMMemoryMB
    InitialBatchSizeHint       = $InitialBatchSizeHint
    Scope                      = $Scope
    CustomProperties           = $CustomProperties
    CleanOnBoot                = $true
    KeepPreparationVMOnFailure = $true
}

# If operating in an On-Prem environment, configure the AdminAddress.
if ($AdminAddress) { $newProvSchemeParameters['AdminAddress'] = $AdminAddress }

# Create a Provisioning Scheme, keeping the image preparation VM on the hypervisor if image preparation fails.
& New-ProvScheme @newProvSchemeParameters
