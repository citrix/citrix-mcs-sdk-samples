<#
.SYNOPSIS
    Removes a machine catalog.
.DESCRIPTION
    The `Remove-MachineCatalog.ps1` script returns the detail of an identity pool.
    The original version of this script is compatible with Citrix Virtual Apps and Desktops 7 2203 Long Term Service Release (LTSR).
.INPUTS
    1. ProvisioningSchemeName: Name of the Machine Catalog to be removed.
    2. AdminAddress: The primary DDC address.

    Additionally, the script supports these optional parameters:

    3. PurgeDBOnly: A flag to remove VM records from the Machine Creation Services database without deleting the actual VMs and hard disk copies from the hypervisor.
    4. ForgetVM: A flag to disassociate VMs from Citrix management, removing Citrix-specific tags/identifiers, while retaining the VMs and hard disk copies in the hypervisor.

.OUTPUTS
    N/A
.NOTES
    Version      : 1.0.0
    Author       : Citrix Systems, Inc.
.EXAMPLE
    # Remove a ProvScheme
    .\Remove-ProvScheme.ps1 `
        -ProvisioningSchemeName "MyProvScheme" `
        -AdminAddress "MyDDC.MyDomain.local"

    # Remove a ProvScheme with PurgeDBOnly
    .\Remove-ProvScheme.ps1 `
        -ProvisioningSchemeName "MyProvScheme" `
        -AdminAddress "MyDDC.MyDomain.local" `
        -PurgeDBOnly $True

    # Remove a ProvScheme with ForgetVM
    .\Remove-ProvScheme.ps1 `
        -ProvisioningSchemeName "MyProvScheme" `
        -AdminAddress "MyDDC.MyDomain.local" `
        -ForgetVM $True
#>

# /*************************************************************************
# * Copyright © 2024. Cloud Software Group, Inc. All Rights Reserved.
# * This file is subject to the license terms contained
# * in the license file that is distributed with this file.
# *************************************************************************/

param(
    [string] $ProvisioningSchemeName,
    [switch] $PurgeDBOnly = $false,
    [switch] $ForgetVM = $false,
    [string] $AdminAddress = $null
)

# Enable Citrix PowerShell Cmdlets
Add-PSSnapin citrix*

################################
# Step 1: Remove a ProvScheme. #
################################
Write-Output "Step 1: Remove a ProvScheme."

# Configure the common parameters for Remove-ProvScheme.
$removeProvSchemeParameters = @{
    ProvisioningSchemeName  = $ProvisioningSchemeName
}

# Configure additional parameters for Remove-ProvScheme, e.g., PurgeDBOnly or ForgetVM.
if ($PurgeDBOnly) {
    $removeProvSchemeParameters['PurgeDBOnly'] = $true
} elseif ($ForgetVM) {
    $removeProvSchemeParameters['ForgetVM'] = $true
}

# If operating in an On-Prem environment, configure the AdminAddress.
if ($AdminAddress) { $removeProvSchemeParameters['AdminAddress'] = $AdminAddress }

# Remove ProvScheme.
& Remove-ProvScheme @removeProvSchemeParameters
