<#
.SYNOPSIS
    Creates a new Identity Pool.
.DESCRIPTION
    The `Create-IdentityPool.ps1` script facilitates the creation of a new Identity Pool.
    The original version of this script is compatible with Citrix Virtual Apps and Desktops 7 2402 Long Term Service Release (LTSR).
.INPUTS
    1. IdentityPoolName: The name of the identity pool.
    2. ZoneUid: The UID that corresponds to the Zone in which these AD accounts will be created.
    3. AdminAddress: The primary DDC address.
    4. NamingScheme: Defines the template name for AD accounts created in the identity pool.
    5. NamingSchemeType: The type of naming scheme. This can be Numeric or Alphabetic.
    6. Scope: The administration scopes to be applied to the new identity pool.
    7. WorkGroupMachine: Indicates whether the accounts created should be part of a workgroup rather than a domain.
    8. Domain: The AD domain name for the pool. Specify this in FQDN format; for example, MyDomain.local.
.OUTPUTS
    An Identity Pool Object.
.EXAMPLE
    # Create a Domain-Joined IdentityPool
    .\Create-IdentityPool.ps1 `
        -IdentityPoolName "MyIdentityPool" `
        -ZoneUid "00000000-0000-0000-0000-000000000000" `
        -AdminAddress "MyDDC.MyDomain.local" `
        -Domain "MyDomain.local" `
        -NamingScheme "MyVM###" `
        -NamingSchemeType "Numeric" `
        -Scope @()

    # Create a Non-Domain-Joined IdentityPool
    .\Create-IdentityPool.ps1 `
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
    [Parameter(mandatory=$true)]
    [string] $IdentityPoolName,
    [Parameter(mandatory=$true)]
    [guid] $ZoneUid,
    [Parameter(mandatory=$true)]
    [string] $NamingScheme,
    [Parameter(mandatory=$true)]
    [string] $NamingSchemeType,
    [string] $AdminAddress = $null,
    [switch] $WorkGroupMachine = $false,
    [string] $Domain,
    [string[]] $Scope = @()
)
# Enable Citrix PowerShell Cmdlets
Add-PSSnapin -Name "Citrix.Host.Admin.V2","Citrix.MachineCreation.Admin.V2" 

Write-Verbose "Create an Identity Pool."

# Configure the common parameters for New-AcctIdentityPool.
$params = @{
    IdentityPoolName    = $IdentityPoolName
    ZoneUid             = $ZoneUid
    NamingScheme        = $NamingScheme
    NamingSchemeType    = $NamingSchemeType
    Scope               = $Scope
    AllowUnicode        = $true
}

# Add conditional parameters
if ($WorkGroupMachine) {
    $params['WorkGroupMachine'] = $WorkGroupMachine
}else {
    if(!$PSBoundParameters.ContainsKey("Domain")){
        Write-Error "Either provide a Domain, or use the WorkGroupMachine flag"
        exit
    }
    $params['Domain'] = $Domain
}
if ($AdminAddress) { $params['AdminAddress'] = $AdminAddress }

& New-AcctIdentityPool @params
