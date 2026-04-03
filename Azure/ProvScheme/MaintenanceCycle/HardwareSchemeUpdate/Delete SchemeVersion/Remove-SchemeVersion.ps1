<#
.SYNOPSIS
    Removes an inactive Provisioning Scheme Version. Applicable for Citrix DaaS and on-prem.
.DESCRIPTION
    Remove-SchemeVersion removes an inactive Provisioning Scheme Version
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
$provisioningSchemeName = "ScaleTest"

####################################################
# Removes a Provisioning Scheme Version
####################################################
Remove-ProvSchemeVersion -ProvisioningSchemeName $provisioningSchemeName -Version $Version