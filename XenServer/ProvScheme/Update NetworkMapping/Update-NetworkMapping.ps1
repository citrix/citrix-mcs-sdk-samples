<#
.SYNOPSIS
    Update the network mappigof a provisioning scheme.
.DESCRIPTION
    `Update-MasterImage.ps1` is designed to update the network mappigof a provisioning scheme.
    The original version of this script is compatible with Citrix Virtual Apps and Desktops 7 2203 Long Term Service Release (LTSR).
.INPUTS
    1. ProvisioningSchemeName: Name of the provisioning scheme to be updated.
    2. NetworkMapping: Specifies how the attached NICs are mapped to networks, represented as @{"DeviceID" = "NetworkPath"}
    3. AdminAddress: The primary DDC address.
.OUTPUTS
    N/A
.NOTES
    Version      : 1.0.0
    Author       : Citrix Systems, Inc.
.EXAMPLE
    .\Update-NetworkMapping.ps1 `
        -ProvisioningSchemeName "MyCatalog" `
        -NetworkMapping @{"0" = "XDHyp:\HostingUnits\MyHostingUnit\My Network.network"} `
        -AdminAddress "MyDDC.MyDomain.local"
#>

# /*************************************************************************
# * Copyright © 2024. Cloud Software Group, Inc. All Rights Reserved.
# * This file is subject to the license terms contained
# * in the license file that is distributed with this file.
# *************************************************************************/

param(
    [string] $ProvisioningSchemeName,
    [hashtable] $NetworkMapping = @{},
    [string] $AdminAddress = $null
)

# Enable Citrix PowerShell Cmdlets
Add-PSSnapin citrix*

################################################################
# Step 1: Update the NetworkMapping of the Provisioning Scheme #
################################################################
Write-Output "Step 1: Update the NetworkMapping of the Provisioning Scheme."

# Configure the common parameters for Set-ProvScheme.
$setProvSchemeParameters = @{
    ProvisioningSchemeName  = $ProvisioningSchemeName
    NetworkMapping         = $NetworkMapping
}

# If operating in an On-Prem environment, configure the AdminAddress.
if ($AdminAddress) { $setProvSchemeParameters['AdminAddress'] = $AdminAddress }

# Modify the Provisioning Scheme
& Set-ProvScheme @setProvSchemeParameters
