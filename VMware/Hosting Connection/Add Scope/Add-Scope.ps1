<#
.SYNOPSIS
    Add scopes to existing hosting connections
.DESCRIPTION
    Add-Scope.ps1 adds scopes to existing hosting connections.
    The original version of this script is compatible with Citrix Virtual Apps and Desktops 7 2203 Long Term Service Release (LTSR).
.INPUTS
    1. ConnectionName: The name of the hosting connection to update.
    2. ScopeNames: The names of the scopes to be added.
    3. AdminAddress: The primary DDC address.
.OUTPUTS
    An Citrix.Host.Sdk.Hypervisorconnection object containing the new definition of the hypervisor connection
.NOTES
    Version      : 1.0.0
    Author       : Citrix Systems, Inc.
.EXAMPLE
    .\Add-Scope.ps1 `
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
    [string] $AdminAddress
)

# Enable Citrix PowerShell Cmdlets
Add-PSSnapin citrix*

# Convert the input to arrays
$ScopeNames = @($ScopeNames)

######################################################
# Step 1: Add the scope to the Hypervisor Connection #
######################################################
Write-Output "Step 1: Add the scope to the Hypervisor Connection."

# Configure the common parameters for Set-Item.
$addHypHypervisorConnectionScopeParameters = @{
    HypervisorConnectionName = $ConnectionName
    Scope = $ScopeNames
}

# If operating in an On-Prem environment, configure the AdminAddress.
if ($AdminAddress) { $addHypHypervisorConnectionScopeParameters['AdminAddress'] = $AdminAddress }

# Create an item for the new hosting connection
try { & Add-HypHypervisorConnectionScope @addHypHypervisorConnectionScopeParameters }
catch {
    Write-Output $_
    exit
}
