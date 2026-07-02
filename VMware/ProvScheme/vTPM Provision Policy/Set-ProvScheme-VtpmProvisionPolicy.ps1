<#
.SYNOPSIS
    Sets or changes the VtpmProvisionPolicy parameter on an existing MCS catalog. The updated policy
    is applied to new machines added after the operation, not to existing machines. Applicable for
    Citrix DaaS and on-prem.
.DESCRIPTION
    Set-ProvScheme-VtpmProvisionPolicy.ps1 changes the vTPM provision policy on an existing VMware
    MCS catalog.

    Accepted values for -VtpmProvisionPolicy:
      - Clone : Clone the vTPM content from the source (machine profile). All provisioned VMs share
                the same vTPM content (for example, to carry over TPM-protected keys such as BitLocker).
      - Clean : Create a brand new (blank) vTPM device for each provisioned VM, so every machine gets
                a unique vTPM.
      - None  : The default. There is no need to pass it explicitly; omitting the parameter leaves the
                policy unchanged. Pass None only if you want to reset an existing catalog back to the
                default behavior.

    Requirements for setting a non-None policy on an existing catalog:
      1. The hypervisor must support the vTPM provision policy (VMware).
      2. The catalog must have a machine profile. If the existing catalog has no machine profile,
         supply one in the same call with -MachineProfile (this script does that when -MachineProfile
         is provided). The policy only takes effect when that machine profile contains a vTPM.
      3. The updated policy applies to NEW machines added after this operation, not to existing machines.

    The vTPM provision policy only takes effect when the machine profile contains a vTPM.

    The original version of this script is compatible with Citrix Virtual Apps and Desktops 7 2511.
.INPUTS
    1. ProvisioningSchemeName: Name of the provisioning scheme to be updated.
    2. VtpmProvisionPolicy: The new vTPM provision policy (Clone or Clean; or None to reset).
    3. MachineProfile (optional): Path to a machine profile template. Required only if the existing
       catalog does not already have a machine profile.
.OUTPUTS
    N/A
.NOTES
    Version      : 1.0.0
    Author       : Citrix Systems, Inc.
.EXAMPLE
    # Existing catalog that already uses a machine profile
    .\Set-ProvScheme-VtpmProvisionPolicy.ps1 `
        -ProvisioningSchemeName "MyCatalog" `
        -VtpmProvisionPolicy "Clean"
.EXAMPLE
    # Existing catalog that has no machine profile yet
    .\Set-ProvScheme-VtpmProvisionPolicy.ps1 `
        -ProvisioningSchemeName "MyCatalog" `
        -VtpmProvisionPolicy "Clone" `
        -MachineProfile "XDHyp:\HostingUnits\MyHostingUnit\MyVM-Template.template"
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

    # Optional. Only needed when the existing catalog does not already have a machine profile.
    [string] $MachineProfile
)

# Enable Citrix PowerShell Cmdlets
Add-PSSnapin citrix*

############################################################
# Step 1: Change the Provisioning Scheme VtpmProvisionPolicy #
############################################################

# The updated policy applies to new machines post operation, not to existing machines.
if ([string]::IsNullOrWhiteSpace($MachineProfile)) {
    Set-ProvScheme -ProvisioningSchemeName $ProvisioningSchemeName -VtpmProvisionPolicy $VtpmProvisionPolicy
}
else {
    # Provide a machine profile in the same call when the catalog has none yet.
    Set-ProvScheme -ProvisioningSchemeName $ProvisioningSchemeName -VtpmProvisionPolicy $VtpmProvisionPolicy -MachineProfile $MachineProfile
}
