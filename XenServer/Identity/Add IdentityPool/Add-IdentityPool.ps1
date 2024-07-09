<#
.SYNOPSIS
    Creation of a Domain-Joined Identity Pool.
.DESCRIPTION
    The `Add-IdentityPool.ps1` script facilitates the creation of a Domain-Joined Identity Pool.
    The original version of this script is compatible with Citrix Virtual Apps and Desktops 7 2203 Long Term Service Release (LTSR).
.INPUTS
    1. IdentityPoolName: The name of the identity pool.
    2. ZoneUid: The UID that corresponds to the Zone in which these AD accounts will be created.
    3. NamingScheme: Defines the template name for AD accounts created in the identity pool.
    4. NamingSchemeType: The type of naming scheme. This can be Numeric or Alphabetic.
    5. Scope: The administration scopes to be applied to the new identity pool.
    6. WorkGroupMachine: Indicates whether the accounts created should be part of a workgroup rather than a domain.
    7. Domain: The AD domain name for the pool. Specify this in FQDN format; for example, MyDomain.local.
.OUTPUTS
    An Identity Pool Object.
.NOTES
    Version      : 1.0.0
    Author       : Citrix Systems, Inc.
.EXAMPLE
    # Create a Domain-Joined IdentityPool
    .\Add-IdentityPool.ps1 `
        -IdentityPoolName "MyIdentityPool" `
        -ZoneUid "00000000-0000-0000-0000-000000000000" `
        -AdminAddress "MyDDC.MyDomain.local" `
        -Domain "MyDomain.local" `
        -NamingScheme "MyVM###" `
        -NamingSchemeType "Numeric" `
        -Scope @()

    # Create a Non-Domain-Joined IdentityPool
    .\Add-IdentityPool.ps1 `
        -IdentityPoolName "MyIdentityPool" `
        -ZoneUid "00000000-0000-0000-0000-000000000000" `
        -AdminAddress "MyDDC.MyDomain.local" `
        -WorkGroupMachine `
        -NamingScheme "MyVM###" `
        -NamingSchemeType "Numeric" `
        -Scope @()
#>

# /*************************************************************************
# * Copyright © 2024. Cloud Software Group, Inc. All Rights Reserved.
# * This file is subject to the license terms contained
# * in the license file that is distributed with this file.
# *************************************************************************/

param(
    [string] $IdentityPoolName,
    [guid] $ZoneUid,
    [string] $AdminAddress = $null,
    [switch] $WorkGroupMachine = $false,
    [string] $Domain,
    [string] $NamingScheme,
    [string] $NamingSchemeType,
    [string[]] $Scope = @()
)
# Enable Citrix PowerShell Cmdlets
Add-PSSnapin citrix*

# Convert the inputs into array formats.
$Scope = @($Scope)

######################################
# Step 1: Create a New Identity Pool #
######################################
Write-Output "Step 1: Create an Identity Pool."

# Configure the common parameters for New-AcctIdentityPool.
$newAcctIdentityPoolParameters = @{
    IdentityPoolName    = $IdentityPoolName
    ZoneUid             = $ZoneUid
    NamingScheme        = $NamingScheme
    NamingSchemeType    = $NamingSchemeType
    Scope               = $Scope
    AllowUnicode        = $true
}

# Update the configuration for (Non-)Domain-Joined IdentityPool
if ($WorkGroupMachine) {
    # If $WorkGroupMachine is specified, update the configuration for a Non-Domained-Joined IdentityPool
    $newAcctIdentityPoolParameters['WorkGroupMachine'] = $WorkGroupMachine
}else {
    # Else, update the configuration for a Domained-Joined IdentityPool
    $newAcctIdentityPoolParameters['Domain'] = $Domain
}

# If operating in an On-Prem environment, configure the AdminAddress.
if ($AdminAddress) { $newAcctIdentityPoolParameters['AdminAddress'] = $AdminAddress }

# Create a Provisoning Scheme
& New-AcctIdentityPool @newAcctIdentityPoolParameters
