<#
.SYNOPSIS
    Retrieves detailed information about a machine catalog.
.DESCRIPTION
    The `Get-ProvScheme-Details.ps1` script retrieves detailed information about a machine catalog.
    The original version of this script is compatible with Citrix Virtual Apps and Desktops 7 2203 Long Term Service Release (LTSR).
.INPUTS
    1. ProvisioningSchemeName: The name of the provisioning scheme.
.OUTPUTS
    A Provioning Scheme
.NOTES
    Version      : 1.0.0
    Author       : Citrix Systems, Inc.
.EXAMPLE
    .\Get-ProvScheme-Details.ps1 `
        -ProvisioningSchemeName "MyCatalog"
#>

# /*************************************************************************
# * Copyright © 2024. Cloud Software Group, Inc. All Rights Reserved.
# * This file is subject to the license terms contained
# * in the license file that is distributed with this file.
# *************************************************************************/

param(
    [string] $ProvisioningSchemeName
)

# Enable Citrix PowerShell Cmdlets
Add-PSSnapin citrix*

######################################################
# Step 1: Get the detail of the Provisioning Scheme. #
######################################################
Get-ProvScheme -ProvisioningSchemeName $ProvisioningSchemeName
