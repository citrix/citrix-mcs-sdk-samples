<#
.SYNOPSIS
    Deletion of a hosting connection and associated resources.
.DESCRIPTION
    Remove-HostingConnection.ps1 deletes a hosting connection and associated resources.
    The original version of this script is compatible with Citrix Virtual Apps and Desktops 7 2203 Long Term Service Release (LTSR).
.INPUTS
    1. ConnectionName: The name of the hosting connection to be deleted.
    2. AdminAddress: The primary DDC address.
.OUTPUTS
    N/A
.NOTES
    Version      : 1.0.0
    Author       : Citrix Systems, Inc.
.EXAMPLE
    .\Remove-HostingConnection.ps1 `
        -ConnectionName "MyConnection" `
        -AdminAddress "MyDDC.MyDomain.local"
#>

# /*************************************************************************
# * Copyright © 2024. Cloud Software Group, Inc. All Rights Reserved.
# * This file is subject to the license terms contained
# * in the license file that is distributed with this file.
# *************************************************************************/

param(
    [string] $ConnectionName,
    [string] $AdminAddress = $null
)

Add-PSSnapin citrix*

##########################################################
# Step 1: Remove the Resources of the Hosting Connection #
##########################################################
Write-Output "Step 1: Remove the Resources of the Hosting Connection."

# Get the Resources of the Hosting Connection
$resources = Get-ChildItem "XDHyp:\HostingUnits\" | Where-Object { $_.HypervisorConnection.HypervisorConnectionName -eq $ConnectionName }

# Remove the Resources of the Hosting Connection
$resources.HostingUnitName | ForEach-Object {
    # Configure the common parameters for Remove-Item.
    $removeItemParameters = @{
        LiteralPath = "XDHyp:\HostingUnits\$_"
        Force = $true
    }
    # If operating in an On-Prem environment, configure the AdminAddress.
    if ($AdminAddress) { $removeItemParameters['AdminAddress'] = $AdminAddress }

    # Create an item for the new hosting connection
    try { & Remove-Item @removeItemParameters }
    catch {
        Write-Output $_
        exit
    }
}

#########################################
# Step 2: Remove the Hosting Connection #
#########################################
Write-Output "Step 2: Remove the Hosting Connection."

# Configure the common parameters for Remove-BrokerHypervisorConnection.
$removeBrokerHypervisorConnectionParameters = @{
    Name = $ConnectionName
}

# If operating in an On-Prem environment, configure the AdminAddress.
if ($AdminAddress) { $removeBrokerHypervisorConnectionParameters['AdminAddress'] = $AdminAddress }

# Remove the Broker Hypervisor Connection.
try { & Remove-BrokerHypervisorConnection @removeBrokerHypervisorConnectionParameters }
catch {
    Write-Output $_
    exit
}

# Configure the common parameters for Remove-Item.
$removeItemParameters = @{
    LiteralPath = @("XDHyp:\Connections\" + $ConnectionName)
}

# If operating in an On-Prem environment, configure the AdminAddress.
if ($AdminAddress) { $removeItemParameters['AdminAddress'] = $AdminAddress }

# Remove the Broker Hypervisor Connection.
try { & Remove-Item @removeItemParameters }
catch {
    Write-Output $_
    exit
}
