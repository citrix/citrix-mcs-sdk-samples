<#
.SYNOPSIS
    Changes the vTPM provision policy for a specific provisioned virtual machine. Applicable for
    Citrix DaaS and on-prem.
.DESCRIPTION
    Set-ProvVM-VtpmProvisionPolicy.ps1 changes the vTPM provision policy on an individual VM in a
    VMware MCS catalog, overriding the catalog-level policy for that VM. The new policy is applied the
    next time the VM is (re)created from its configuration; it does not modify an already-provisioned
    vTPM device.

    Accepted values for -VtpmProvisionPolicy:
      - Clone : Clone the vTPM content from the source (machine profile).
      - Clean : Create a brand new (blank) vTPM device for the VM.
      - None  : The default. There is no need to pass it explicitly; omitting the parameter leaves the
                policy unchanged. Pass None only to reset the VM back to the default behavior.

    The vTPM provision policy only takes effect when the machine profile contains a vTPM.

    The original version of this script is compatible with Citrix Virtual Apps and Desktops 7 2511.
.INPUTS
    1. ProvisioningSchemeName: Name of the provisioning scheme the VM belongs to.
    2. VMName: Name of the provisioned virtual machine to update.
    3. VtpmProvisionPolicy: The new vTPM provision policy (Clone or Clean; or None to reset).
    4. MachineProfile (optional): Path to a machine profile template, if the VM configuration needs one.
.OUTPUTS
    N/A
.NOTES
    Version      : 1.0.0
    Author       : Citrix Systems, Inc.
.EXAMPLE
    .\Set-ProvVM-VtpmProvisionPolicy.ps1 `
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

    # Optional. Only needed when the VM configuration must also set a machine profile.
    [string] $MachineProfile
)

# Enable Citrix PowerShell Cmdlets
Add-PSSnapin citrix*

########################################################
# Step 1: Change the vTPM provision policy for the VM. #
########################################################

if ([string]::IsNullOrWhiteSpace($MachineProfile)) {
    Set-ProvVM -ProvisioningSchemeName $ProvisioningSchemeName -VMName $VMName -VtpmProvisionPolicy $VtpmProvisionPolicy
}
else {
    Set-ProvVM -ProvisioningSchemeName $ProvisioningSchemeName -VMName $VMName -VtpmProvisionPolicy $VtpmProvisionPolicy -MachineProfile $MachineProfile
}
