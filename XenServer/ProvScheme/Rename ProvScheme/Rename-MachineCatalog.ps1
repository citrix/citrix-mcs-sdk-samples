<#
.SYNOPSIS
    Rename tests on a specified machine catalog.
.DESCRIPTION
    The `Rename-MachineCatalog.ps1` script is designed to rename tests on a specified machine catalog.
    The original version of this script is compatible with Citrix Virtual Apps and Desktops 7 2203 Long Term Service Release (LTSR).
.INPUTS
    1. CatalogName: The name of the catalog.
    2. NewCatalogName The new name of the catalog.
    3. AdminAddress: The primary DDC address.
.OUTPUTS
    N/A
.NOTES
    Version      : 1.0.0
    Author       : Citrix Systems, Inc.
.EXAMPLE
    .\Rename-MachineCatalog.ps1 `
        -CatalogName "MyCatalog" `
        -NewCatalogName "MyRenamedCatalog" `
        -AdminAddress "MyDDC.MyDomain.local"
#>

# /*************************************************************************
# * Copyright © 2024. Cloud Software Group, Inc. All Rights Reserved.
# * This file is subject to the license terms contained
# * in the license file that is distributed with this file.
# *************************************************************************/

param(
    [string] $CatalogName,
    [string] $NewCatalogName,
    [string] $AdminAddress = $null
)

# Enable Citrix PowerShell Cmdlets.
Add-PSSnapin citrix*

####################################################
# Step 1: Check if the Proposed New Name is Unused #
####################################################
Write-Output "Step 1: Check if the Proposed New Name is Unused."

# Configure the common parameters for Test-ProvSchemeNameAvailable.
$testProvSchemeNameAvailableParameters = @{
    ProvisioningSchemeName  = $NewCatalogName
}

# If operating in an On-Prem environment, configure the AdminAddress.
if ($AdminAddress) { $testProvSchemeNameAvailableParameters['AdminAddress'] = $AdminAddress }

# Check whether the Proposed New Name is already in use by another ProvScheme
$isAvailableProvSchemeName = & Test-ProvSchemeNameAvailable @testProvSchemeNameAvailableParameters

if ($isAvailableProvSchemeName.Available -ne "True") {
    Write-Output "Unavailable: The Proposed New Name is already in use by another ProvScheme."
    exit
}

# Configure the common parameters for Test-AcctIdentityPoolNameAvailable.
$testAcctIdentityPoolNameAvailableParameters = @{
    IdentityPoolName  = $NewCatalogName
}

# If operating in an On-Prem environment, configure the AdminAddress.
if ($AdminAddress) { $testAcctIdentityPoolNameAvailableParameters['AdminAddress'] = $AdminAddress }

# Check whether the Proposed New Name is already in use by another ProvScheme
$isAvailableIdentityPoolName = & Test-AcctIdentityPoolNameAvailable @testAcctIdentityPoolNameAvailableParameters

if ($isAvailableIdentityPoolName.Available -ne "True") {
    Write-Output "Unavailable: The Proposed New Name is already in use by another IdentityPool."
    exit
}

#####################################
# Step 2: Rename the Broker Catalog #
#####################################
Write-Output "Step 2: Rename the Broker Catalog."

# Configure the common parameters for Rename-BrokerCatalog.
$renameBrokerCatalogParameters = @{
    Name  = $CatalogName
    NewName = $NewCatalogName
}

# If operating in an On-Prem environment, configure the AdminAddress.
if ($AdminAddress) { $renameBrokerCatalogParameters['AdminAddress'] = $AdminAddress }

# Rename the Broker Catalog.
& Rename-BrokerCatalog @renameBrokerCatalogParameters

##########################################
# Step 3: Rename the Provisioning Scheme #
##########################################
Write-Output "Step 3: Rename the Provisioning Scheme."

# Configure the common parameters for Rename-ProvScheme.
$renameProvSchemeParameters = @{
    ProvisioningSchemeName  = $CatalogName
    NewProvisioningSchemeName = $NewCatalogName
}

# If operating in an On-Prem environment, configure the AdminAddress.
if ($AdminAddress) { $renameProvSchemeParameters['AdminAddress'] = $AdminAddress }

# Rename the Broker Catalog.
& Rename-ProvScheme @renameProvSchemeParameters

###################################
# Step 4: Rename the IdentityPool #
###################################
Write-Output "Step 4: Rename the IdentityPool."

# Configure the common parameters for Rename-AcctIdentityPool.
$renameProvSchemeParameters = @{
    IdentityPoolName  = $CatalogName
    NewIdentityPoolName = $NewCatalogName
}

# If operating in an On-Prem environment, configure the AdminAddress.
if ($AdminAddress) { $renameProvSchemeParameters['AdminAddress'] = $AdminAddress }

# Rename the Identity Pool.
& Rename-AcctIdentityPool @renameProvSchemeParameters
