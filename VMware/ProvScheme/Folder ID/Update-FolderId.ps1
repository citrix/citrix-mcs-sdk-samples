<#
.SYNOPSIS
    Update the Folder Id of a provisioning scheme.
.DESCRIPTION
    `Update-MasterImage.ps1` is designed to update the Folder Id of a provisioning scheme.
    The original version of this script is compatible with Citrix Virtual Apps and Desktops 7 2203 Long Term Service Release (LTSR).
.INPUTS
    1. ProvisioningSchemeName: Name of the provisioning scheme to be updated.
    2. CustomProperties: The custom properties that include the VMware Folder Id.
    3. AdminAddress: The primary DDC address.
.OUTPUTS
    N/A
.NOTES
    Version      : 1.0.0
    Author       : Citrix Systems, Inc.
.EXAMPLE
    .\Update-FoldeId.ps1 `
        -ProvisioningSchemeName "MyCatalog" `
        -CustomProperties "<CustomProperties xmlns=""http://schemas.citrix.com/2014/xd/machinecreation"" xmlns:xsi=""http://www.w3.org/2001/XMLSchema-instance""><Property xsi:type=""StringProperty"" Name=""FolderId"" Value=""group-v000"" /></CustomProperties>" `
        -AdminAddress "MyDDC.MyDomain.local"
#>

# /*************************************************************************
# * Copyright © 2024. Cloud Software Group, Inc. All Rights Reserved.
# * This file is subject to the license terms contained
# * in the license file that is distributed with this file.
# *************************************************************************/

param(
    [string] $ProvisioningSchemeName,
    [string] $CustomProperties = $null,
    [string] $AdminAddress = $null
)

# Enable Citrix PowerShell Cmdlets
Add-PSSnapin citrix*

##################################################################
# Step 1: Update the CustomProperties of the Provisioning Scheme #
##################################################################
Write-Output "Step 1: Update the CustomProperties of the Provisioning Scheme."

# Configure the common parameters for New-ProvScheme.
$setProvSchemeParameters = @{
    ProvisioningSchemeName  = $ProvisioningSchemeName
    CustomProperties         = $CustomProperties
}

# If operating in an On-Prem environment, configure the AdminAddress.
if ($AdminAddress) { $setProvSchemeParameters['AdminAddress'] = $AdminAddress }

# Modify the Provisioning Scheme
& Set-ProvScheme @setProvSchemeParameters
