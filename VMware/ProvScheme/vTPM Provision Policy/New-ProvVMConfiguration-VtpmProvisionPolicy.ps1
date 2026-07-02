<#
.SYNOPSIS
    Creates a new configuration for a provisioned virtual machine that sets the vTPM provision policy.
    Applicable for Citrix DaaS and on-prem.
.DESCRIPTION
    New-ProvVMConfiguration-VtpmProvisionPolicy.ps1 creates a new configuration for a specific
    provisioned VM in a VMware MCS catalog and sets the vTPM provision policy on that configuration.

    Note: New-ProvVMConfiguration is an experimental command and part of the image-decouple workflow.

    Accepted values for -VtpmProvisionPolicy:
      - Clone : Clone the vTPM content from the source (machine profile).
      - Clean : Create a brand new (blank) vTPM device for the VM.
      - None  : The default. There is no need to pass it explicitly.

    The vTPM provision policy only takes effect when the machine profile contains a vTPM.

    The original version of this script is compatible with Citrix Virtual Apps and Desktops 7 2511.
.INPUTS
    1. ProvisioningSchemeName: Name of the provisioning scheme the VM belongs to.
    2. VMName: Name of the provisioned virtual machine.
    3. VtpmProvisionPolicy: The vTPM provision policy (Clone or Clean).
    4. MachineProfile (optional): Path to a machine profile template, if the configuration needs one.
.OUTPUTS
    A New Provisioned VM Configuration Object
.NOTES
    Version      : 1.0.0
    Author       : Citrix Systems, Inc.
.EXAMPLE
    .\New-ProvVMConfiguration-VtpmProvisionPolicy.ps1 `
        -ProvisioningSchemeName "MyCatalog" `
        -VMName "MyCatalog-VM-01" `
        -VtpmProvisionPolicy "Clean"
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
    [string] $VMName,

    [Parameter(Mandatory = $true)]
    [ValidateSet("None", "Clone", "Clean")]
    [string] $VtpmProvisionPolicy,

    # Optional. Provide a machine profile if the configuration should set or change it.
    [string] $MachineProfile
)

# Enable Citrix PowerShell Cmdlets
Add-PSSnapin citrix*

##################################################################
# Step 1: Create a new VM configuration with the vTPM policy.    #
##################################################################

if ([string]::IsNullOrWhiteSpace($MachineProfile)) {
    New-ProvVMConfiguration -ProvisioningSchemeName $ProvisioningSchemeName -VMName $VMName -VtpmProvisionPolicy $VtpmProvisionPolicy
}
else {
    New-ProvVMConfiguration -ProvisioningSchemeName $ProvisioningSchemeName -VMName $VMName -VtpmProvisionPolicy $VtpmProvisionPolicy -MachineProfile $MachineProfile
}
