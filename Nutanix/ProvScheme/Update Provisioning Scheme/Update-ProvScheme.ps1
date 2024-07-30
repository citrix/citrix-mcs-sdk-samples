<#
.SYNOPSIS
    Update the RAM, CPUs and Cores per socket for a ProvScheme.
.DESCRIPTION
    Update-ProvScheme.ps1 updates the RAM, CPUs and Cores per socket values for a Provisioning Scheme.
    The original version of this script is compatible with Citrix Virtual Apps and Desktops 7 2402 Long Term Service Release (LTSR).
.INPUTS
    1. ProvisioningSchemeName: Name of the new provisioning scheme
    2. CustomProperties: Used to provide Container Path(as hypervisor path), vCPU count, RAM, and CPUCores(Cores per CPU) values
    3. 
.EXAMPLE
# Setting up customProperties as a variable for better readability
$customProperties = @"
    <CustomProperties xmlns="http://schemas.citrix.com/2014/xd/machinecreation">
        <StringProperty Name="ContainerPath" Value="/myContainer.storage"/>
        <StringProperty Name="vCPU" Value="2"/>
        <StringProperty Name="RAM" Value="4096"/>
        <StringProperty Name="CPUCores" Value="1"/>    
    </CustomProperties>
"@
.\Update-ProvScheme.ps1 `
    -ProvisioningSchemeName "myProvScheme" `
    -CustomProperties $customProperties `
    -VMCpuCount 2 `
    -VMMemoryMB 4096
#>

# /*************************************************************************
# * Copyright © 2024. Cloud Software Group, Inc.
# * This file is subject to the license terms contained
# * in the license file that is distributed with this file.
# *************************************************************************/

param(
    [Parameter(mandatory=$true)]
    [string] $ProvisioningSchemeName,
    [Parameter(mandatory=$true)]
    [string] $CustomProperties,
    [int] $VMCpuCount,
    [int] $VMMemoryMB
)
# Enable Citrix PowerShell Cmdlets
Add-PSSnapin -Name "Citrix.Host.Admin.V2","Citrix.MachineCreation.Admin.V2" 

Write-Verbose "Update the ProvScheme"

# Configure the common parameters for Set-ProvScheme.
$updateProvSchemeParameters = @{
    ProvisioningSchemeName  = $ProvisioningSchemeName
    CustomProperties        = $CustomProperties
    VMCpuCount              = $VMCpuCount
    VMMemoryMB              = $VMMemoryMB
}

# Create a Provisoning Scheme
try{
    & Set-ProvScheme @updateProvSchemeParameters -ErrorAction Stop
} catch {
    Write-Error $_
    exit
}
