<#
.SYNOPSIS
    Creates an Identity Pool. Applicable for Citrix DaaS and on-prem.
.DESCRIPTION
    Create-IdentityPool.ps1 emulates the behavior of the New-AcctIdentityPool command.
    The original version of this script is compatible with Citrix Virtual Apps and Desktops 7 2203 Long Term Service Release (LTSR).
#>

# /*************************************************************************
# * Copyright © 2024. Cloud Software Group, Inc. All Rights Reserved.
# * This file is subject to the license terms contained
# * in the license file that is distributed with this file.
# *************************************************************************/

##########################
# Step 1: Find Zone Uid. #
##########################
# [User Input Required] Set parameters for New-AcctIdentityPool
# Gets zones with the specified name.
$zoneName = "AzureResourceLocation"

# The UID that corresponds to the Zone in which these AD accounts will be created.
# This is only intended to be used for Citrix Cloud Delivery Controllers.
$zoneUid = $null
$zone = Get-ConfigZone -Name $zoneName -ErrorAction 'SilentlyContinue'
$zoneUid = $zone.Uid
if($null -eq $zoneUid)
{
    throw "Could not find the zone (zoneName): $($zoneName). Verify the zoneName exists or try the default 'Primary.'"
}


################################
# Step 2: Setup the parameters #
################################
# Add Citrix snap-ins
Add-PSSnapin -Name "Citrix.Host.Admin.V2","Citrix.MachineCreation.Admin.V2"

# [User Input Required] Set parameters for New-AcctIdentityPool

# The type of device management type.
# This can be Intune, IntuneWithCitrixTags, or None.
# Setup value to be None here to support Active Directory case.
$deviceManagementType = "None"
# The name of the identity pool. This must not contain any of the following characters \/;:#.*?=<>|[]()””’
$identityPoolName = "demo-identitypool01"
# Defines the template name for AD accounts created in the identity pool.
# The scheme can consist of fixed characters and a variable part defined by ‘#’ characters.
# There can be only one variable region defined.
# The number of ‘#’ characters defines the minimum length of the variable region.
# For example, a naming scheme of H#### could create accounts called H0001,
# H0002 (for a numeric scheme type) or HAAAA, HAAAB (for an alphabetic type).
$namingScheme = "demo-###"
# The type of naming scheme. This can be Numeric or Alphabetic.
# This defines the format of the variable part of the AD account names that will be created.
# Setup value to be Numeric as a demo.
$namingSchemeType = "Numeric"
# The type of identity type. This can be ActiveDirectory, AzureAD, HybridAzureAD, or Workgroup.
# Setup value to be ActiveDirectory to support no domain join case.
$identityType = "ActiveDirectory"
# The OU that computer accounts will be created in. If this is not specified,
# accounts are created into the default account container specified by AD.
# This is the ‘Computers’ container for out-of-the-box installations of AD.
# The OU must be a valid AD container of the domain specified for the pool.
$OU = "CN=Computers,DC=cvad,DC=local"
# Specifies the next number to be used when creating new AD accounts in the identity pool.
$startCount = 1
# The AD domain name for the pool. Specify this in FQDN format; for example, MyDomain.com.
$domain = "cvad.local"

####################################
# Step 3: Create the Identity Pool #
####################################
New-AcctIdentityPool -DeviceManagementType $deviceManagementType `
    -Domain $domain `
    -IdentityPoolName $identityPoolName `
    -IdentityType  $identityType `
    -NamingScheme $namingScheme `
    -NamingSchemeType $namingSchemeType `
    -OU $OU `
    -StartCount $startCount `
    -ZoneUid $zoneUid