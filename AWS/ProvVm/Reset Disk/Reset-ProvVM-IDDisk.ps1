<#
.SYNOPSIS
    Resets the ID Disk of a Provisioned VM. Applicable for Citrix DaaS and on-prem.
.DESCRIPTION
    Reset-ProvVM-IDDisk helps reset the ID Disk of a Provisioned VM.
    This script is not compatible with Citrix Virtual Apps and Desktops 7 2402 Long Term Service Release (LTSR).
#>

# /*************************************************************************
# * Copyright © 2025. Cloud Software Group, Inc. All Rights Reserved.
# * This file is subject to the license terms contained
# * in the license file that is distributed with this file.
# *************************************************************************/

################################
# Step 0: Setup the parameters #
################################
# Add Citrix snap-ins
Add-PSSnapin -Name "Citrix.Host.Admin.V2","Citrix.MachineCreation.Admin.V2"

# [User Input Required] Set parameters for Reset-ProvVMDisk
$provisioningSchemeName = "demo-provScheme"
$VMName = "demo-provVM1"

# [User Input Required] Set parameters for Repair-AcctIdentity
$adUsername = "demo-username"
$secureUserInput = Read-Host 'Please enter your AD password' -AsSecureString
$encryptedInput = ConvertFrom-SecureString -SecureString $secureUserInput
$adPassword = ConvertTo-SecureString -String $encryptedInput

###################################
# Step 1: Reset the Identity disk #
###################################
# Get the ProvVM properties to get the ADAccountSid
$provVM = Get-ProvVM -VMName $VMName

Repair-AcctIdentity -IdentityAccountId $provVM.ADAccountSid -PrivilegedUserName $adUsername -PrivilegedUserPassword $adPassword -Target IdentityInfo
Reset-ProvVMDisk -ProvisioningSchemeName $provisioningSchemeName -VMName $VMName -Identity