<#
.SYNOPSIS
    Updates a ProvScheme.
.DESCRIPTION
    Update-ProvScheme.ps1 updates the RAM, CPUs, Cores per socket, Network Mapping, and Machine Profile values for a Provisioning Scheme.
    The original version of this script is compatible with  Citrix DaaS July 2025 Release.
.INPUTS
    1. ProvisioningSchemeName: Name of the new provisioning scheme
    2. MachineProfile:         OPTIONAL Path to Prism Central Template Version for hardware specification
    3. NetworkMapping:         OPTIONAL Specifies how the attached NICs are mapped to networks (required when using MachineProfile)
    4. CustomProperties:       OPTIONAL Used to provide Cluster, and CPUCores(Cores per CPU, overrides the setting in master image or machine profile Template Version) values
    5. VMCpuCount:             OPTIONAL Set the CPU setting (overrides the setting in master image or machine profile Template Version)
    6. VMMemoryMB:             OPTIONAL Set the Memory setting (overrides the setting in master image or machine profile Template Version)
.EXAMPLE
# Setting up customProperties as a variable for better readability
$customProperties = @"
    <CustomProperties xmlns="http://schemas.citrix.com/2014/xd/machinecreation">
        <StringProperty Name="ClusterId" Value="00001111-2222-3333-4444-555556666666"/>
        <StringProperty Name="CPUCores" Value="2"/>
    </CustomProperties>
"@
.\Update-ProvScheme.ps1 `
    -ProvisioningSchemeName "myProvScheme" `
    -CustomProperties $customProperties `
    -VMCpuCount 2 `
    -VMMemoryMB 4096

# Update a Provisioning Scheme using Machine Profile for hardware specification
.\Update-ProvScheme.ps1 `
    -ProvisioningSchemeName "myProvScheme" `
    -MachineProfile "XDHyp:\HostingUnits\myHostingUnit\Templates.folder\HardwareProfile.template\hardwarespec.templateversion" `
    -NetworkMapping @{"0"="XDHyp:\HostingUnits\myHostingUnit\Clusters.folder\cluster01.cluster\Network-A.network"}

# Update a Provisioning Scheme using Machine Profile with overridden hardware specification
.\Update-ProvScheme.ps1 `
    -ProvisioningSchemeName "myProvScheme" `
    -MachineProfile "XDHyp:\HostingUnits\myHostingUnit\Templates.folder\HardwareProfile.template\hardwarespec.templateversion" `
    -NetworkMapping @{"0"="XDHyp:\HostingUnits\myHostingUnit\Clusters.folder\cluster01.cluster\Network-A.network"} `
    -CustomProperties $customProperties `
    -VMCpuCount 4 `
    -VMMemoryMB 8192
#>
# /*************************************************************************
# * Copyright © 2025. Cloud Software Group, Inc.
# * This file is subject to the license terms contained
# * in the license file that is distributed with this file.
# *************************************************************************/

param(
    [Parameter(mandatory=$true)]  [string] $ProvisioningSchemeName,
    [Parameter(mandatory=$false)] [string] $MachineProfile,
    [Parameter(mandatory=$false)] [hashtable] $NetworkMapping,
    [Parameter(mandatory=$false)] [string] $CustomProperties,
    [Parameter(mandatory=$false)] [int] $VMCpuCount,
    [Parameter(mandatory=$false)] [int] $VMMemoryMB
)
# Enable Citrix PowerShell Cmdlets
Add-PSSnapin -Name "Citrix.Host.Admin.V2","Citrix.MachineCreation.Admin.V2"

Write-Verbose "Update the ProvScheme"

$updateProvSchemeParameters = @{}
if ($PSBoundParameters.ContainsKey("MachineProfile"))
{
    $updateProvSchemeParameters.Add("MachineProfile", $MachineProfile)
}
if ($PSBoundParameters.ContainsKey("NetworkMapping"))
{
    $updateProvSchemeParameters.Add("NetworkMapping", $NetworkMapping)
}
if ($PSBoundParameters.ContainsKey("CustomProperties"))
{
    $updateProvSchemeParameters.Add("CustomProperties", $CustomProperties)
}
if ($PSBoundParameters.ContainsKey("VMCpuCount"))
{
    $updateProvSchemeParameters.Add("VMCpuCount", $VMCpuCount)
}
if ($PSBoundParameters.ContainsKey("VMMemoryMB"))
{
    $updateProvSchemeParameters.Add("VMMemoryMB", $VMMemoryMB)
}

if ($updateProvSchemeParameters.Count -gt 0)
{
    try
    {
        & Set-ProvScheme -ProvisioningSchemeName $ProvisioningSchemeName @updateProvSchemeParameters
    }
    catch
    {
        Write-Error $_
        exit
    }
}
