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
     6. CustomProperties:       Used to provide Cluster and CPUCores(Cores per CPU) values
     7. MasterImageVM:          Path to Prism Central Template Version
     8. VMCpuCount:             OPTIONAL: Number of vCPUs, overrides settings in Template Version
     9. VMMemoryMB:             OPTIONAL: VM memory in MB, overrides settings in Template Version
    10. InitialBatchSizeHint:   The number of VMs that will be intially added to the Provisioning Scheme
    11. CleanOnBoot:            Reset VM's to their initial state on each power on
    12. Scope:                  Administration scopes for the identity pool
    13. RunAsynchronously:      Run command asynchronously, returns ProvTask ID
    14. PersistUserChanges:     User data persistence method
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
    -RunAsynchronously `
    -PersistUserChanges OnLocal
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
    [Parameter(mandatory=$false)] [int]       $VMCpuCount,
    [Parameter(mandatory=$false)] [int]       $VMMemoryMB,
    [Parameter(mandatory=$false)] [string]    $InitialBatchSizeHint="1",
    [Parameter(mandatory=$false)] [switch]    $CleanOnBoot = $false,
    [Parameter(mandatory=$false)] [string[]]  $Scope = @(),
    [Parameter(mandatory=$false)] [switch]    $RunAsynchronously = $false,
    [Parameter(mandatory=$false)] [string]    $PersistUserChanges
)

# Enable Citrix PowerShell Cmdlets
Add-PSSnapin -Name "Citrix.Host.Admin.V2","Citrix.MachineCreation.Admin.V2"

Write-Verbose "Create a ProvScheme"

# Configure the common parameters for New-ProvScheme.
$newProvSchemeParameters = @{
    ProvisioningSchemeName  = $ProvisioningSchemeName
    ProvisioningSchemeType  = $ProvisioningSchemeType
    HostingUnitName         = $HostingUnitName
    IdentityPoolName        = $identityPoolName
    NetworkMapping          = $NetworkMapping
    CustomProperties        = $CustomProperties
    MasterImageVM           = $MasterImageVM
    InitialBatchSizeHint    = $InitialBatchSizeHint
    CleanOnBoot             = $CleanOnBoot
    Scope                   = $Scope
    RunAsynchronously       = $RunAsynchronously
}


if ($PSBoundParameters.ContainsKey("VMCpuCount"))
{
    $newProvSchemeParameters.Add("VMCpuCount", $VMCpuCount)
}

if ($PSBoundParameters.ContainsKey("VMMemoryMB"))
{
    $newProvSchemeParameters.Add("VMMemoryMB", $VMMemoryMB)
}


# Create a Provisoning Scheme
try
{
    & New-ProvScheme @newProvSchemeParameters
}
catch
{
    Write-Error $_
    exit
}
