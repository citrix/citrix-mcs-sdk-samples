<#
.SYNOPSIS
    Deletion of a hosting unit and associated resources.
.DESCRIPTION
    The `Remove-HostingUnit.ps1` script facilitates the deletion of a hosting unit and associated resources.
    The original version of this script is compatible with Citrix Virtual Apps and Desktops 7 2203 Long Term Service Release (LTSR).
.INPUTS
    1. HostingUnitNames: The names of the hosting unit to be deleted.
    2. AdminAddress: The primary DDC address.
.OUTPUTS
    N/A
.NOTES
    Version      : 1.0.0
    Author       : Citrix Systems, Inc.
.EXAMPLE
    .\Remove-HostingUnit.ps1 `
        -HostingUnitNames "MyHostingUnit1", "MyHostingUnit2" `
        -AdminAddress "MyDDC.MyDomain.local"
#>

# /*************************************************************************
# * Copyright © 2024. Cloud Software Group, Inc. All Rights Reserved.
# * This file is subject to the license terms contained
# * in the license file that is distributed with this file.
# *************************************************************************/

param(
    [string[]] $HostingUnitNames,
    [string] $AdminAddress = $null
)

# Enable Citrix PowerShell Cmdlets
Add-PSSnapin citrix*

# Convert the inputs into array formats.
$HostingUnitNames = @($HostingUnitNames)

####################################################
# Step 1: Remove the Resources of the Hosting Unit #
####################################################
Write-Output "Step 1: Remove the Resources of the Hosting Unit."

$HostingUnitNames | ForEach-Object {
    # Configure the common parameters for Remove-Item.
    $removeItemParameters = @{
        LiteralPath = "XDHyp:\HostingUnits\$_"
        Force = $true
    }

    # If operating in an On-Prem environment, configure the AdminAddress.
    if ($AdminAddress) { $removeItemParameters['AdminAddress'] = $AdminAddress }

    # Remove the hosting unit.
    try { & Remove-Item @removeItemParameters }
    catch {
        Write-Output $_
        exit
    }
}
