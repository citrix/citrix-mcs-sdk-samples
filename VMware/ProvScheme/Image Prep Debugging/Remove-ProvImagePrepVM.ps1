<#
.SYNOPSIS
    Removes an image preparation VM that was kept on the hypervisor after an image preparation failure.
.DESCRIPTION
    Remove-ProvImagePrepVM.ps1 removes the image preparation VM and its associated resources for a
    provisioning scheme once troubleshooting is complete. Target the scheme with
    -ProvisioningSchemeName or -ProvisioningSchemeUid, or pipe a provisioning scheme into the cmdlet.

    The image preparation VM is also removed automatically when the machine catalog is deleted, or
    when Publish-ProvMasterVMImage is run again for the same scheme.

    Remove-ProvImagePrepVM requires CVAD Cloud 129 / CVAD 2611 CR or later.
.INPUTS
    1. ProvisioningSchemeName: Name of the provisioning scheme whose image preparation VM will be removed.
    2. AdminAddress: The primary DDC address.

    A provisioning scheme object can also be piped in (ProvisioningSchemeName / ProvisioningSchemeUid).
.OUTPUTS
    N/A
.NOTES
    Version      : 1.0.0
    Author       : Citrix Systems, Inc.
.EXAMPLE
    .\Remove-ProvImagePrepVM.ps1 `
        -ProvisioningSchemeName "MyMachineCatalog" `
        -AdminAddress "MyDDC.MyDomain.local"
#>

# /*************************************************************************
# * Copyright © 2026. Cloud Software Group, Inc. All Rights Reserved.
# * This file is subject to the license terms contained
# * in the license file that is distributed with this file.
# *************************************************************************/

param(
    [string] $ProvisioningSchemeName,
    [string] $AdminAddress = $null
)

# Enable Citrix PowerShell Cmdlets
Add-PSSnapin citrix*

# Configure the parameters for Remove-ProvImagePrepVM.
$removeParameters = @{
    ProvisioningSchemeName = $ProvisioningSchemeName
}

# If operating in an On-Prem environment, configure the AdminAddress.
if ($AdminAddress) { $removeParameters['AdminAddress'] = $AdminAddress }

# Remove the image preparation VM (and its resources) for the provisioning scheme.
& Remove-ProvImagePrepVM @removeParameters

# Alternatively, pipe a provisioning scheme into Remove-ProvImagePrepVM:
# Get-ProvScheme -ProvisioningSchemeName $ProvisioningSchemeName | Remove-ProvImagePrepVM
