<#
.SYNOPSIS
    Gets a ProvVMConfiguration. Applicable for Citrix DaaS and on-prem.
.DESCRIPTION
    Get-VmConfiguration gets a ProvVMConfiguration
#>

# /*************************************************************************
# * Copyright © 2025. Cloud Software Group, Inc. All Rights Reserved.
# * This file is subject to the license terms contained
# * in the license file that is distributed with this file.
# *************************************************************************/

Add-PSSnapin -Name "Citrix.Host.Admin.V2","Citrix.MachineCreation.Admin.V2"

#####################
# Prepare Parameters
#####################
$ADAccountSid = "00000000-0000-0000-0000-000000000000"
$Version = 4
$provisioningSchemeName = "ScaleTest"

###############################################################
# Gets ProvVMConfiguration
###############################################################
Get-ProvVMConfiguration -ADAccountSid $ADAccountSid -Version $Version -ProvisioningSchemeName $provisioningSchemeName 