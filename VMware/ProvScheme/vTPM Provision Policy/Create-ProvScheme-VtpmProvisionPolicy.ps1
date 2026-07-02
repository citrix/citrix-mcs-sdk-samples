<#
.SYNOPSIS
    Creates a ProvScheme that sets the vTPM provision policy.
.DESCRIPTION
    Create-ProvScheme-VtpmProvisionPolicy.ps1 creates a VMware ProvScheme and uses the
    VtpmProvisionPolicy parameter to control how the vTPM device of each provisioned VM is created.

    The vTPM provision policy only takes effect when the machine profile contains a vTPM, so this
    example provisions from a machine profile template (-MachineProfile).

    Accepted values for -VtpmProvisionPolicy:
      - None  : The default, used when the parameter is omitted. No explicit policy; the legacy
                behavior is used. There is no need to pass None explicitly.
      - Clone : Clone the vTPM content from the source (machine profile). All provisioned VMs share
                the same vTPM content (for example, to carry over TPM-protected keys such as BitLocker).
      - Clean : Create a brand new (blank) vTPM device for each provisioned VM, so every machine gets
                a unique vTPM.

    The original version of this script is compatible with Citrix Virtual Apps and Desktops 7 2511.
.INPUTS
    N/A
.OUTPUTS
    A New Provisioning Scheme Object
.NOTES
    Version      : 1.0.0
    Author       : Citrix Systems, Inc.
.EXAMPLE
    .\Create-ProvScheme-VtpmProvisionPolicy.ps1
#>

# /*************************************************************************
# * Copyright © 2026. Cloud Software Group, Inc. All Rights Reserved.
# * This file is subject to the license terms contained
# * in the license file that is distributed with this file.
# *************************************************************************/

# Enable Citrix PowerShell Cmdlets
Add-PSSnapin citrix*

# Example Configuration for New-ProvScheme.
$ProvisioningSchemeName  = "MyMachineCatalog"
$IdentityPoolName        = "MyMachineCatalog"
$HostingUnitName         = "MyHostingUnit"
$MasterImageVM           = "XDHyp:\HostingUnits\MyHostingUnit\MyVM.vm\MySnapshot.snapshot"
$MachineProfile          = "XDHyp:\HostingUnits\MyHostingUnit\MyVM-Template.template"
$NetworkMapping          = @{"0"="XDHyp:\HostingUnits\MyHostingUnit\MyNetwork.network"}

# The vTPM provision policy. Allowed values: Clone or Clean.
# Omit -VtpmProvisionPolicy entirely to use the default (None).
$VtpmProvisionPolicy     = "Clone"

# Create a Provisioning Scheme.
# -MachineProfile is required because the vTPM provision policy only applies when the
#  machine profile contains a vTPM. Hardware properties such as CPU count and memory are
#  captured from the machine profile, so they are not specified explicitly here.
New-ProvScheme `
    -ProvisioningSchemeName $ProvisioningSchemeName `
    -IdentityPoolName $IdentityPoolName `
    -HostingUnitName $HostingUnitName `
    -MasterImageVM $MasterImageVM `
    -MachineProfile $MachineProfile `
    -NetworkMapping $NetworkMapping `
    -CleanOnBoot:$false `
    -VtpmProvisionPolicy $VtpmProvisionPolicy
