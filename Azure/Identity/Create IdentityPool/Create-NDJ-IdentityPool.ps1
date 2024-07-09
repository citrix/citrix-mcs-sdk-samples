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
$zoneName = "EmptyResourceLocation"
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
# Setup value to be None here to support no domain join case.
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
# Setup value to be Workgroup to support no domain join case.
$identityType = "Workgroup"
# Specifies the next number to be used when creating new AD accounts in the identity pool.
$startCount = 1

####################################
# Step 3: Create the Identity Pool #
####################################
New-AcctIdentityPool -DeviceManagementType $deviceManagementType `
    -IdentityPoolName $identityPoolName `
    -IdentityType  $identityType `
    -NamingScheme $namingScheme `
    -NamingSchemeType $namingSchemeType `
    -StartCount $startCount `
    -ZoneUid $zoneUid `
    -WorkgroupMachine # Indicates whether the accounts created should be part of a workgroup rather than a domain.
