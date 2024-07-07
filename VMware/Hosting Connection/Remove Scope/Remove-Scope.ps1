<#
.SYNOPSIS
    Remove scopes from a existing hosting connection.
.DESCRIPTION
    The `Remove-Scope.ps1` script is designed to remove scopes from a existing hosting connection.
    The original version of this script is compatible with Citrix Virtual Apps and Desktops 7 2203 Long Term Service Release (LTSR).
.INPUTS
    1. ConnectionName: The name of the hosting connection to update.
    2. ScopeNames: The names of the scopes to be removed.
    3. AdminAddress: The primary DDC address.
.OUTPUTS
    N/A
.NOTES
    Version      : 1.0.0
    Author       : Citrix Systems, Inc.
.EXAMPLE
    .\Remove-Scope.ps1 `
        -ConnectionName "MyConnection" `
        -ScopeName "MyScope" `
        -AdminAddress "MyDDC.MyDomain.local"
#>

# /*************************************************************************
# * Copyright © 2024. Cloud Software Group, Inc. All Rights Reserved.
# * This file is subject to the license terms contained
# * in the license file that is distributed with this file.
# *************************************************************************/

param(
    [string] $ConnectionName,
    [string[]] $ScopeNames,
    [string] $AdminAddress = $null
)

# Enable Citrix PowerShell Cmdlets
Add-PSSnapin citrix*

# Convert the input to arrays
$ScopeNames = @($ScopeNames)

##########################################################
# Step 1: Remove the Scopes from the Hosting Connections #
##########################################################
Write-Output "Step 1: Remove the Scopes from the Hosting Connections."

# Configure the common parameters for Set-Item.
$removeHypHypervisorConnectionScopeParameters = @{
    HypervisorConnectionName = $ConnectionName
    Scope = $ScopeNames
}

# If operating in an On-Prem environment, configure the AdminAddress.
if ($AdminAddress) { $removeHypHypervisorConnectionScopeParameters['AdminAddress'] = $AdminAddress }

# Create an item for the new hosting connection
try { & Remove-HypHypervisorConnectionScope @removeHypHypervisorConnectionScopeParameters }
catch {
    Write-Output $_
    exit
}
