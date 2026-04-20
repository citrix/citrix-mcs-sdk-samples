<#
.SYNOPSIS
    Creates a ProvScheme.
.DESCRIPTION
    Create-ProvScheme.ps1 creates a new Provisioning Scheme.
    The original version of this script is compatible with  Citrix DaaS July 2025 Release.
.INPUTS
     1. ProvisioningSchemeName: Name of the new provisioning scheme
     2. ProvisioningSchemeType: The Provisioning Scheme Type (one of: MCS)
     3. HostingUnitName:        Name of the hosting unit used
     4. IdentityPoolName:       Name of the Identity Pool used
     5. NetworkMapping:         Specifies how the attached NICs are mapped to networks
     6. CustomProperties:       Used to provide Cluster and CPUCores (Cores per CPU, overrides the setting in master image or machine profile Template Version) values
     7. MasterImageVM:          Path to Prism Central Template Version
     8. MachineProfile:         OPTIONAL: Path to Prism Central Template Version for hardware specification
     9. VMCpuCount:             OPTIONAL: Number of vCPUs, overrides the setting in master image or machine profile Template Version
    10. VMMemoryMB:             OPTIONAL: VM memory in MB, overrides the setting in master image or machine profile Template Version
    11. InitialBatchSizeHint:   The number of VMs that will be intially added to the Provisioning Scheme
    12. CleanOnBoot:            Reset VM's to their initial state on each power on
    13. Scope:                  Administration scopes for the identity pool
    14. RunAsynchronously:      Run command asynchronously, returns ProvTask ID
.EXAMPLE
# Setting up customProperties as a variable for better readability
$customProperties = @"
    <CustomProperties xmlns="http://schemas.citrix.com/2014/xd/machinecreation">
        <StringProperty Name="ClusterId" Value="00001111-2222-3333-4444-555556666666"/>
        <StringProperty Name="CPUCores" Value="1"/>
    </CustomProperties>
"@

# Create a non-persistent Provisioning Scheme
.\Create-ProvScheme.ps1 `
    -ProvisioningSchemeName "myProvScheme" `
    -ProvisioningSchemeType "MCS" `
    -HostingUnitName "myHostingUnit" `
    -IdentityPoolName "myIdp" `
    -NetworkMapping @{"0"="XDHyp:\HostingUnits\myHostingUnit\Clusters.folder\cluster01.cluster\Network-A.network"} `
    -CustomProperties $customProperties `
    -MasterImageVM "XDHyp:\HostingUnits\myHostingUnit\Templates.folder\CitrixVda.template\win2022-vda-2411.templateversion" `
    -VMCpuCount 2 `
    -VMMemoryMB 6144 `
    -InitialBatchSizeHint 1 `
    -CleanOnBoot `
    -Scope @() `
    -RunAsynchronously

# Create a persistent Provisioning Scheme with changes saved locally on the device
.\Create-ProvScheme.ps1 `
    -ProvisioningSchemeName "myProvScheme" `
    -ProvisioningSchemeType "MCS" `
    -HostingUnitName "myHostingUnit" `
    -IdentityPoolName "myIdp" `
    -NetworkMapping @{"0"="XDHyp:\HostingUnits\myHostingUnit\Clusters.folder\cluster01.cluster\Network-A.network"} `
    -CustomProperties $customProperties `
    -MasterImageVM "XDHyp:\HostingUnits\myHostingUnit\Templates.folder\CitrixVda.template\win2022-vda-2411.templateversion" `
    -VMCpuCount 3 `
    -VMMemoryMB 6144 `
    -InitialBatchSizeHint 1 `
    -Scope @() `
    -RunAsynchronously

# Create a Provisioning Scheme using Machine Profile for hardware specification
.\Create-ProvScheme.ps1 `
    -ProvisioningSchemeName "myProvScheme" `
    -ProvisioningSchemeType "MCS" `
    -HostingUnitName "myHostingUnit" `
    -IdentityPoolName "myIdp" `
    -NetworkMapping @{"0"="XDHyp:\HostingUnits\myHostingUnit\Clusters.folder\cluster01.cluster\Network-A.network"} `
    -CustomProperties $customProperties `
    -MasterImageVM "XDHyp:\HostingUnits\myHostingUnit\Templates.folder\CitrixVda.template\win2022-vda-2411.templateversion" `
    -MachineProfile "XDHyp:\HostingUnits\myHostingUnit\Templates.folder\HardwareProfile.template\hardwarespec.templateversion" `
    -InitialBatchSizeHint 1 `
    -CleanOnBoot `
    -Scope @() `
    -RunAsynchronously

# Create a Provisioning Scheme using Machine Profile with overridden hardware specification
.\Create-ProvScheme.ps1 `
    -ProvisioningSchemeName "myProvScheme" `
    -ProvisioningSchemeType "MCS" `
    -HostingUnitName "myHostingUnit" `
    -IdentityPoolName "myIdp" `
    -NetworkMapping @{"0"="XDHyp:\HostingUnits\myHostingUnit\Clusters.folder\cluster01.cluster\Network-A.network"} `
    -CustomProperties $customProperties `
    -MasterImageVM "XDHyp:\HostingUnits\myHostingUnit\Templates.folder\CitrixVda.template\win2022-vda-2411.templateversion" `
    -MachineProfile "XDHyp:\HostingUnits\myHostingUnit\Templates.folder\HardwareProfile.template\hardwarespec.templateversion" `
    -VMCpuCount 4 `
    -VMMemoryMB 8192 `
    -InitialBatchSizeHint 1 `
    -CleanOnBoot `
    -Scope @() `
    -RunAsynchronously
#>

# /*************************************************************************
# * Copyright © 2025. Cloud Software Group, Inc.
# * This file is subject to the license terms contained
# * in the license file that is distributed with this file.
# *************************************************************************/

param(
    [Parameter(mandatory=$true)]  [string]    $ProvisioningSchemeName,
    [Parameter(mandatory=$true)]  [string]    $ProvisioningSchemeType,
    [Parameter(mandatory=$true)]  [string]    $HostingUnitName,
    [Parameter(mandatory=$true)]  [string]    $IdentityPoolName,
    [Parameter(mandatory=$true)]  [hashtable] $NetworkMapping,
    [Parameter(mandatory=$true)]  [string]    $CustomProperties,
    [Parameter(mandatory=$true)]  [string]    $MasterImageVM,
    [Parameter(mandatory=$false)] [string]    $MachineProfile,
    [Parameter(mandatory=$false)] [int]       $VMCpuCount,
    [Parameter(mandatory=$false)] [int]       $VMMemoryMB,
    [Parameter(mandatory=$false)] [string]    $InitialBatchSizeHint="1",
    [Parameter(mandatory=$false)] [switch]    $CleanOnBoot = $false,
    [Parameter(mandatory=$false)] [string[]]  $Scope = @(),
    [Parameter(mandatory=$false)] [switch]    $RunAsynchronously = $false
)

# Enable Citrix PowerShell Cmdlets
Add-PSSnapin -Name "Citrix.Host.Admin.V2","Citrix.MachineCreation.Admin.V2"

Write-Verbose "Create a ProvScheme"

# Configure the common parameters for New-ProvScheme.
$newProvSchemeParameters = @{
    ProvisioningSchemeName  = $ProvisioningSchemeName
    ProvisioningSchemeType  = $ProvisioningSchemeType
    HostingUnitName         = $HostingUnitName
    IdentityPoolName        = $IdentityPoolName
    NetworkMapping          = $NetworkMapping
    CustomProperties        = $CustomProperties
    MasterImageVM           = $MasterImageVM
    InitialBatchSizeHint    = $InitialBatchSizeHint
    CleanOnBoot             = $CleanOnBoot
    Scope                   = $Scope
    RunAsynchronously       = $RunAsynchronously
}

if ($PSBoundParameters.ContainsKey("MachineProfile"))
{
    $newProvSchemeParameters.Add("MachineProfile", $MachineProfile)
}

if ($PSBoundParameters.ContainsKey("VMCpuCount"))
{
    $newProvSchemeParameters.Add("VMCpuCount", $VMCpuCount)
}

if ($PSBoundParameters.ContainsKey("VMMemoryMB"))
{
    $newProvSchemeParameters.Add("VMMemoryMB", $VMMemoryMB)
}


# Create a Provisioning Scheme
try
{
    & New-ProvScheme @newProvSchemeParameters
}
catch
{
    Write-Error $_
    exit
}
