<#
.SYNOPSIS
    Creates a ProvScheme. 
.DESCRIPTION
    Add-ProvScheme.ps1 creates a ProvScheme.
    The original version of this script is compatible with Citrix Virtual Apps and Desktops 7 2203 Long Term Service Release (LTSR).
.INPUTS
    1. ProvisioningSchemeName: Name of the new provisioning scheme.
    2. HostingUnitName: Name of the hosting unit used.
    3. IdentityPoolName: Name of the Identity Pool used.
    4. ProvisioningSchemeType: The Provisioning Scheme Type.
    5. MasterImageVM: Path to VM snapshot or template.
    6. CustomProperties: Specific properties for the hosting infrastructure.
    7. NetworkMapping: Specifies how the attached NICs are mapped to networks.
    8. VMCpuCount: The number of processors that will be used to create VMs from the provisioning scheme.
    9. VMMemoryMB: The maximum amount of memory that will be used to created VMs from the provisioning scheme in MB.
    10. InitialBatchSizeHint: The number of initial VMs that will be added to the MCS catalog.
    11. Scope: Administration scopes for the identity pool.
    12. CleanOnBoot: Reset VMs to initial state on start.
    13. ZoneUid: The UID that corresponds to the Zone in which the hosting connection is associated.
    14. UseFullDiskCloneProvisioning: This flag enables the use of Full Clone provisioning.
.OUTPUTS
    A New Provisioning Scheme Object
.NOTES
    Version      : 1.0.0
    Author       : Citrix Systems, Inc.
.EXAMPLE
    .\Add-ProvScheme.ps1 `
        -ProvisioningSchemeName "MyMachineCatalog" `
        -HostingUnitName "MyHostingUnit" `
        -IdentityPoolName "MyMachineCatalog" `
        -ProvisioningSchemeType "MCS" `
        -MasterImageVM "XDHyp:\HostingUnits\MyHostingUnit\MyVM.vm\MySnapshot.snapshot" `
        -CustomProperties "" `
        -NetworkMapping @{"0"="XDHyp:\HostingUnits\MyHostingUnit\MyNetwork.network"} `
        -VMCpuCount 1 `
        -VMMemoryMB 1024 `
        -InitialBatchSizeHint 1 `
        -Scope @()  `
        -CleanOnBoot $true `
        -ZoneUid "00000000-0000-0000-0000-000000000000" `
        -UseFullDiskCloneProvisioning $true 
#>

# /*************************************************************************
# * Copyright © 2024. Cloud Software Group, Inc. All Rights Reserved.
# * This file is subject to the license terms contained
# * in the license file that is distributed with this file.
# *************************************************************************/

param(
    [string] $ProvisioningSchemeName,
    [string] $HostingUnitName,
    [string] $IdentityPoolName,
    [string] $ProvisioningSchemeType, 
    [string] $MasterImageVM,
    [string] $CustomProperties = "",
    [string] $NetworkMapping,
    [string] $VMCpuCount,
    [string] $VMMemoryMB,
    [string] $InitialBatchSizeHint, 
    [string[]] $Scope = @(),
    [switch] $CleanOnBoot = $false,
    [guid] $ZoneUid,
    [switch] $UseFullDiskCloneProvisioning = $false
)

# Enable Citrix PowerShell Cmdlets
Add-PSSnapin citrix*

# Convert the inputs into array formats.
$Scope = @($Scope)

# Determine if the script operates in a Cloud or On-Prem environment.
# It's considered On-Prem if no connector addresses are found.
$connectorAddresses = Get-ConfigEdgeServer -ZoneUid $ZoneUid | ForEach-Object { $_.MachineAddress }
$isOnPrem = -not $connectorAddresses

# Retrieve Delivery Controller addresses and set the AdminAddress for an On-Prem environment.
If ($isOnPrem) {
    $ddcAddresses = (Get-ConfigZone -Name "Primary").ControllerNames | ForEach-Object { "$_.$Domain" }
    $adminAddress = $ddcAddresses[0]
}

################################
# Step 1: Create a ProvScheme. #
################################
Write-Output "Step 1: Create a ProvScheme."

# Configure the common parameters for New-ProvScheme.
$newProvSchemeParameters = @{
    ProvisioningSchemeName  = $ProvisioningSchemeName
    HostingUnitName         = $HostingUnitName
    IdentityPoolName        = $identityPoolName
    ProvisioningSchemeType  = $ProvisioningSchemeType
    MasterImageVM           = $MasterImageVM
    CustomProperties        = $CustomProperties
    NetworkMapping          = $NetworkMapping
    VMCpuCount              = $VMCpuCount
    VMMemoryMB              = $VMMemoryMB
    InitialBatchSizeHint    = $InitialBatchSizeHint
    Scope                   = $Scope
    CleanOnBoot             = $CleanOnBoot
    UseFullDiskCloneProvisioning = $UseFullDiskCloneProvisioning
}

# If operating in an On-Prem environment, configure the AdminAddress.
if ($isOnPrem) { $newItemParameters['AdminAddress'] = $adminAddress }

# Create a Provisoning Scheme
& New-ProvScheme @newProvSchemeParameters
