<#
.SYNOPSIS
    Creates a new configuration version of a provisioning scheme that sets the vTPM provision policy.
    Applicable for Citrix DaaS and on-prem.
.DESCRIPTION
    New-ProvSchemeVersion-VtpmProvisionPolicy.ps1 creates a new configuration version for an existing
    VMware MCS provisioning scheme and sets the vTPM provision policy on that version. New machines
    created from this version use the specified policy.

    Note: New-ProvSchemeVersion is an experimental command and part of the image-decouple workflow.

    Accepted values for -VtpmProvisionPolicy:
      - Clone : Clone the vTPM content from the source (machine profile).
      - Clean : Create a brand new (blank) vTPM device for each provisioned VM.
      - None  : The default. There is no need to pass it explicitly.

    The vTPM provision policy only takes effect when the machine profile contains a vTPM.

    The original version of this script is compatible with Citrix Virtual Apps and Desktops 7 2511.
.INPUTS
    1. ProvisioningSchemeName: Name of the provisioning scheme to create a new version for.
    2. VtpmProvisionPolicy: The vTPM provision policy (Clone or Clean).
    3. MachineProfile (optional): Path to a machine profile template, if the new version should set one.
.OUTPUTS
    A New Provisioning Scheme Version Object
.NOTES
    Version      : 1.0.0
    Author       : Citrix Systems, Inc.
.EXAMPLE
    .\New-ProvSchemeVersion-VtpmProvisionPolicy.ps1 `
        -ProvisioningSchemeName "MyCatalog" `
        -VtpmProvisionPolicy "Clone"
#>

# /*************************************************************************
# * Copyright © 2026. Cloud Software Group, Inc. All Rights Reserved.
# * This file is subject to the license terms contained
# * in the license file that is distributed with this file.
# *************************************************************************/

##########################
# Step 0: Set parameters #
##########################
param(
    [Parameter(Mandatory = $true)]
    [string] $ProvisioningSchemeName,

    [Parameter(Mandatory = $true)]
    [ValidateSet("None", "Clone", "Clean")]
    [string] $VtpmProvisionPolicy,

    # Optional. Provide a machine profile if the new version should set or change it.
    [string] $MachineProfile
)

# Enable Citrix PowerShell Cmdlets
Add-PSSnapin citrix*

###############################################################
# Step 1: Create a new scheme version with the vTPM policy.   #
###############################################################

if ([string]::IsNullOrWhiteSpace($MachineProfile)) {
    New-ProvSchemeVersion -ProvisioningSchemeName $ProvisioningSchemeName -VtpmProvisionPolicy $VtpmProvisionPolicy
}
else {
    New-ProvSchemeVersion -ProvisioningSchemeName $ProvisioningSchemeName -VtpmProvisionPolicy $VtpmProvisionPolicy -MachineProfile $MachineProfile
}
