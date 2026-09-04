<#
.SYNOPSIS
    Updates the master image of a ProvScheme, keeping the image preparation VM on failure.
.DESCRIPTION
    Update-MasterImage-KeepPreparationVMOnFailure.ps1 updates the master image of an existing
    provisioning scheme using Publish-ProvMasterVMImage with the -KeepPreparationVMOnFailure switch.

    When image preparation fails, the image preparation VM and its resources are left on the
    hypervisor so the failure can be investigated. If image preparation succeeds, the VM is removed
    automatically and the switch has no effect. On a failed run the provisioning scheme keeps running
    on the previous master image.

    Re-running Publish-ProvMasterVMImage for the same scheme automatically removes any image
    preparation VM left by the previous failed attempt.

    The original version of this script is compatible with CVAD Cloud 123 (and the equivalent CVAD
    on-prem release) and later.
.INPUTS
    1. ProvisioningSchemeName: Name of the provisioning scheme whose master image will be updated.
    2. MasterImageVM: Path to the new VM snapshot or template.
    3. AdminAddress: The primary DDC address.
.OUTPUTS
    N/A
.NOTES
    Version      : 1.0.0
    Author       : Citrix Systems, Inc.
.EXAMPLE
    .\Update-MasterImage-KeepPreparationVMOnFailure.ps1 `
        -ProvisioningSchemeName "MyMachineCatalog" `
        -MasterImageVM "XDHyp:\HostingUnits\MyHostingUnit\MyVM.vm\MyNewSnapshot.snapshot" `
        -AdminAddress "MyDDC.MyDomain.local"
#>

# /*************************************************************************
# * Copyright © 2026. Cloud Software Group, Inc. All Rights Reserved.
# * This file is subject to the license terms contained
# * in the license file that is distributed with this file.
# *************************************************************************/

param(
    [string] $ProvisioningSchemeName,
    [string] $MasterImageVM,
    [string] $AdminAddress = $null
)

# Enable Citrix PowerShell Cmdlets
Add-PSSnapin citrix*

# Configure the parameters for Publish-ProvMasterVMImage. KeepPreparationVMOnFailure is always set so
# that a failed image preparation leaves the preparation VM on the hypervisor for investigation.
$publishParameters = @{
    ProvisioningSchemeName     = $ProvisioningSchemeName
    MasterImageVM              = $MasterImageVM
    KeepPreparationVMOnFailure = $true
}

# If operating in an On-Prem environment, configure the AdminAddress.
if ($AdminAddress) { $publishParameters['AdminAddress'] = $AdminAddress }

# Update the master image, keeping the image preparation VM on the hypervisor if image preparation fails.
& Publish-ProvMasterVMImage @publishParameters
