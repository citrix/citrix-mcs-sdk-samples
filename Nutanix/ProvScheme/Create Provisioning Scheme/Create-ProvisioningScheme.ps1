<#
.SYNOPSIS
    Creates a ProvScheme.
.DESCRIPTION
    Create-ProvScheme.ps1 creates a new Provisioning Scheme.
    The original version of this script is compatible with Citrix Virtual Apps and Desktops 7 2402 Long Term Service Release (LTSR).
.INPUTS
    1. ProvisioningSchemeName: Name of the new provisioning scheme
    2. ProvisioningSchemeType: The Provisioning Scheme Type
    3. HostingUnitName: Name of the hosting unit used
    4. IdentityPoolName: Name of the Identity Pool used
    5. NetworkMapping: Specifies how the attached NICs are mapped to networks
    6. CustomProperties: Used to provide Container Path(as hypervisor path), vCPU count, RAM, and CPUCores(Cores per CPU) values
    7. MasterImageVM: Path to VM snapshot or template
    8. InitialBatchSizeHint: The number of VMs that will be intially added to the Provisioning Scheme
    9. CleanOnBoot: Reset VM's to their initial state on each power on
    10. Scope: Administration scopes for the identity pool
    11. RunAsynchronously: Run command asynchronously, returns ProvTask ID
.EXAMPLE
# Setting up customProperties as a variable for better readability
$customProperties = @"
    <CustomProperties xmlns="http://schemas.citrix.com/2014/xd/machinecreation">
        <StringProperty Name="ContainerPath" Value="/myContainer.storage"/>
        <StringProperty Name="vCPU" Value="3"/>
        <StringProperty Name="RAM" Value="6144"/>
        <StringProperty Name="CPUCores" Value="3"/>    
    </CustomProperties>
"@

# Create a non-persistent Provisioning Scheme 
.\Create-ProvisioningScheme.ps1 `
    -ProvisioningSchemeName "myProvScheme" `
    -ProvisioningSchemeType "MCS" `
    -HostingUnitName "myHostingUnit" `
    -IdentityPoolName "myIdp" `
    -NetworkMapping @{"0"="XDHyp:\HostingUnits\myHostingUnit\myNetwork.network"} `
    -CustomProperties $customProperties `
    -MasterImageVM "XDHyp:\HostingUnits\myHostingUnit\myMasterImage.template" `
    -InitialBatchSizeHint 1 `
    -CleanOnBoot `
    -Scope @() `
    -RunAsynchronously
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
    [string] $ProvisioningSchemeType,
    [Parameter(mandatory=$true)]
    [string] $HostingUnitName,
    [Parameter(mandatory=$true)]
    [string] $IdentityPoolName,
    [Parameter(mandatory=$true)]
    [hashtable] $NetworkMapping,
    [Parameter(mandatory=$true)]
    [string] $CustomProperties,
    [Parameter(mandatory=$true)]
    [string] $MasterImageVM,
    [string] $InitialBatchSizeHint,
    [switch] $CleanOnBoot = $false,
    [string[]] $Scope = @(),
    [switch] $RunAsynchronously = $false
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

# Create a Provisoning Scheme
try{
    & New-ProvScheme @newProvSchemeParameters
} catch {
    Write-Error $_
    exit
}
