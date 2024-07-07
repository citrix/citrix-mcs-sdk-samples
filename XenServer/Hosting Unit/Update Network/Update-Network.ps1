<#
.SYNOPSIS
    Update the networks of an existing hosting unit.
.DESCRIPTION
    The `Update-Network.ps1` script is designed to update the networks of an existing hosting unit.
    The original version of this script is compatible with Citrix Virtual Apps and Desktops 7 2203 Long Term Service Release (LTSR).
.INPUTS
    1. ConnectionName: The name of the hosting connection associated with the networks.
    2. HostingUnitName: The name of the hosting unit from which the networks will be updated.
    3. NetworkPaths: The paths of the networks of the hosting unit to be updated.
    4. AdminAddress: The primary DDC address.
.OUTPUTS
    N/A
.NOTES
    Version      : 1.0.0
    Author       : Citrix Systems, Inc.
.EXAMPLE
    .\Update-Network.ps1 `
        -ConnectionName "MyConnection" `
        -HostingUnitName "MyHostingUnit" `
        -NetworkPaths "MyNetwork1.network", "MyNetwork2.network"
        -AdminAddress "MyDDC.MyDomain.local"
#>

# /*************************************************************************
# * Copyright © 2024. Cloud Software Group, Inc. All Rights Reserved.
# * This file is subject to the license terms contained
# * in the license file that is distributed with this file.
# *************************************************************************/

param(
    [string] $ConnectionName,
    [string] $HostingUnitName,
    [string[]] $NetworkPaths = $null,
    [string] $AdminAddress = $null
)

# Enable Citrix PowerShell Cmdlets.
Add-PSSnapin citrix*

# Convert the inputs into array formats.
$NetworkPaths = @($NetworkPaths)

###################################################
# Step 1: Update the Networks of the Hosting Unit #
###################################################
Write-Output "Step 1: Update the Networks of the Hosting Unit."

# Build the connection path.
$connectionPath = "XDHyp:\Connections\" + $ConnectionName

# Clean the input network paths
$NetworkPaths = $NetworkPaths -replace '[/\\]+', '\'

# Build the network path
$fullNetworkPath = $NetworkPaths | ForEach-Object {
    if (!$_.StartsWith($connectionPath)) { "$connectionPath\$_" }
    else { $_ }
}

# Clean the network paths
$fullNetworkPath = $fullNetworkPath -replace '[/\\]+', '\'

# Configure the common parameters for Set-Item.
$setItemParameters = @{
    Path = "XDHyp:\HostingUnits\" + $HostingUnitName
    NetworkPath = $fullNetworkPath
}

# If operating in an On-Prem environment, configure the AdminAddress.
if ($AdminAddress) { $setItemParameters['AdminAddress'] = $AdminAddress }

# Update the networks of the hosting unit
try { & Set-Item @setItemParameters }
catch {
    Write-Output $_
    exit
}