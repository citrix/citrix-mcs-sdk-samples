<#
.SYNOPSIS
    Gets a Provisioning Scheme History. Applicable for Citrix DaaS and on-prem.
.DESCRIPTION
    Get-SchemeHistory gets a Provisioning Scheme History
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
$ProvisioningSchemeHistoryVersion = 1

###############################################################
# Gets Provisioning Scheme History
###############################################################
Get-ProvSchemeHistory -ProvisioningSchemeName $provisioningSchemeName -ProvisioningSchemeHistoryVersion $ProvisioningSchemeHistoryVersion