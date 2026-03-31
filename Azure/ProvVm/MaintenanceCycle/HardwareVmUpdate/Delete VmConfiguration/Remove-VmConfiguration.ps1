<#
.SYNOPSIS
    Removes an inactive ProvVMConfiguration. Applicable for Citrix DaaS and on-prem.
.DESCRIPTION
    Remove-VmConfiguration removes an inactive ProvVMConfiguration
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
$ConfigurationVersion = 4

####################################################
# Removes a ProvVMConfiguration
####################################################
Remove-ProvVMConfiguration -ADAccountSid $ADAccountSid -ConfigurationVersion $ConfigurationVersion