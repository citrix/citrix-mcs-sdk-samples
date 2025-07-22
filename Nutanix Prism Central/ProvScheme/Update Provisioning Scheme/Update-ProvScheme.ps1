<#
.SYNOPSIS
    Update the RAM, CPUs and Cores per socket for a ProvScheme.
.DESCRIPTION
    Update-ProvScheme.ps1 updates the RAM, CPUs and Cores per socket values for a Provisioning Scheme.
    The original version of this script is compatible with  Citrix DaaS July 2025 Release.
.INPUTS
    1. ProvisioningSchemeName: Name of the new provisioning scheme
    2. CustomProperties:       OPTIONAL Used to provide Cluster, and CPUCores(Cores per CPU) values
    3. VMCpuCount:             OPTIONAL Set the CPU setting
    4. VMMemoryMB:             OPTIONAL Set the Memory setting
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
#>
# /*************************************************************************
# * Copyright © 2025. Cloud Software Group, Inc.
# * This file is subject to the license terms contained
# * in the license file that is distributed with this file.
# *************************************************************************/

param(
    [Parameter(mandatory=$true)]  [string] $ProvisioningSchemeName,
    [Parameter(mandatory=$false)] [string] $CustomProperties,
    [Parameter(mandatory=$false)] [int] $VMCpuCount,
    [Parameter(mandatory=$false)] [int] $VMMemoryMB
)
# Enable Citrix PowerShell Cmdlets
Add-PSSnapin -Name "Citrix.Host.Admin.V2","Citrix.MachineCreation.Admin.V2"

Write-Verbose "Update the ProvScheme"

$updateProvSchemeParameters = @{}
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
