<#
.SYNOPSIS
    Retrieves detailed information about provisioning VMs.
.DESCRIPTION
    The `Get-ProvVM-Detail.ps1` script retrieves detailed information about provisioning VMs.
    The original version of this script is compatible with Citrix Virtual Apps and Desktops 7 2203 Long Term Service Release (LTSR).
.INPUTS
    1. ProvisioningSchemeName: The name of the provisioning scheme.
.OUTPUTS
    Provisioning VM Objects.
.NOTES
    Version      : 1.0.0
    Author       : Citrix Systems, Inc.
.EXAMPLE
    .\Get-ProvVM-Detail.ps1 `
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

###################################################
# Step 1: Get the detail of the Provisioning VMs. #
###################################################
Get-ProvVM -ProvisioningSchemeName $ProvisioningSchemeName
