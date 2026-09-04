<#
.SYNOPSIS
    Finds the image preparation VM that was kept on the hypervisor after an image preparation failure.
.DESCRIPTION
    Get-ProvImagePrepVM.ps1 shows how to locate an image preparation VM that was retained on the
    hypervisor by the -KeepPreparationVMOnFailure switch. Pass -ProvisioningSchemeName (or
    -ProvisioningSchemeUid) to target a single scheme, or omit both to list the image preparation
    VMs for all provisioning schemes that currently have one.

    Use the returned details to find the VM on the hypervisor so its logs can be inspected. On
    VMware, match the VM using the PreparationImageName field (in the form
    "Preparation - <CatalogName>").

    Get-ProvImagePrepVM requires CVAD Cloud 129 / CVAD 2611 CR or later.
.INPUTS
    1. ProvisioningSchemeName: Name of the provisioning scheme to query. Omit to list the image
       preparation VMs for all provisioning schemes that currently have one.
    2. AdminAddress: The primary DDC address.
.OUTPUTS
    Image preparation VM details for the matching provisioning scheme(s).
.NOTES
    Version      : 1.0.0
    Author       : Citrix Systems, Inc.
.EXAMPLE
    # Retrieve the image preparation VM for a specific provisioning scheme.
    .\Get-ProvImagePrepVM.ps1 `
        -ProvisioningSchemeName "MyMachineCatalog" `
        -AdminAddress "MyDDC.MyDomain.local"

    # Omit -ProvisioningSchemeName to list the image preparation VMs for all provisioning schemes.
    .\Get-ProvImagePrepVM.ps1
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

# Configure the parameters for Get-ProvImagePrepVM. Omit -ProvisioningSchemeName to list the image
# preparation VMs for all provisioning schemes that currently have one.
$getParameters = @{}
if ($ProvisioningSchemeName) { $getParameters['ProvisioningSchemeName'] = $ProvisioningSchemeName }

# If operating in an On-Prem environment, configure the AdminAddress.
if ($AdminAddress) { $getParameters['AdminAddress'] = $AdminAddress }

# Retrieve image preparation VM details.
& Get-ProvImagePrepVM @getParameters
