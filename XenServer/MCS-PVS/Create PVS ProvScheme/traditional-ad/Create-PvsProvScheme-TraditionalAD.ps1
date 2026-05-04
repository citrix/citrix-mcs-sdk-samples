# /*************************************************************************
# * Copyright © Citrix Systems, Inc. All Rights Reserved.
# * This file is subject to the license terms contained
# * in the license file that is distributed with this file.
# *************************************************************************/

<#
.SYNOPSIS
    Creates a PVS provisioning scheme and a broker catalog using MCS provisioning on XenServer.

.DESCRIPTION
    Create-PvsProvScheme-TraditionalAD.ps1 creates a PVS Provisioning Scheme and an associated
    Machine Catalog that uses MCS provisioning with PVS-backed machines hosted on XenServer.

    The original version of this script is compatible with
    Citrix Virtual Apps and Desktops 7 2402 Long Term Service Release (LTSR) or later.

    IMPORTANT:
    - Review and update ALL user input parameters in the "User Input Required" sections.
    - Run from a Delivery Controller (DDC) with the Citrix PowerShell SDK installed.
#>

# Add Citrix snap-ins (idempotent: ignore errors if already loaded)
Add-PSSnapin -Name "Citrix.ADIdentity.Admin.V2","Citrix.Host.Admin.V2","Citrix.MachineCreation.Admin.V2","Citrix.Broker.Admin.V2" -ErrorAction SilentlyContinue

#------------------------------------------------- User Input: Provisioning Scheme ------------------------------------------------#
# CleanOnBoot:
#   $true  = non-persistent VMs (disk reset on reboot; typical for pooled workloads)
#   $false = persistent VMs (changes kept; use with care for PVS)
$isCleanOnBoot = $true

# Name of the provisioning scheme and identity pool (can be different if desired)
# Example: "CTX-PVS-XenServer-Prod-Scheme"
$provisioningSchemeName = "demo-provScheme"

# Identity pool name (typically same as provisioning scheme)
$identityPoolName       = $provisioningSchemeName

# Hosting unit name as configured in Studio / Web Studio (XenServer hosting unit)
# Example: "XenServer-Prod-HostingUnit"
$hostingUnitName = "demo-hostingUnit"

# Hosting unit network name for the first NIC
# Example: "Pool Network 0"
$networkName = "Pool Network 0"

# Machine profile used to define the hardware configuration (CPU, memory, NIC, etc.) for the catalog.
# The machine profile must be a VM snapshot that exists in the same hosting unit.
# The path format is: XDHyp:\HostingUnits\<HostingUnitName>\<VmName>.vm\<SnapshotName>.snapshot
# Example VM name: "MyVmName"
$machineProfileVmName = "MyVmName"

# Example snapshot name: "MySnapshotName"
$machineProfileSnapshotName = "MySnapshotName"

# Initial batch size hint for MCS workflow planning.
# This value is passed to -InitialBatchSizeHint and does NOT create VMs by itself.
$initialBatchSizeHint = 1

# CPU and memory settings to apply to provisioned VMs
# Example CPU count: 2, 4, 8
$vmCpuCount  = 2

# Example memory in MB: 4096, 8192, 16384
$vmMemoryMB  = 8192

# Naming scheme and domain for machine accounts
# Example naming scheme: "CTX-PVS-XEN-VDI-" => machines become CTX-PVS-XEN-VDI-01, CTX-PVS-XEN-VDI-02, ...
$sampleNamingScheme = "sampleNaming"

# Example domain: "corp.local" or "corp.company.com"
$domain             = "sampleDomain"

# PVS site and vDisk identifiers (from Get-HypPvsSite / Get-HypPvsDiskInfo)
# Example PVS site GUID: "f3bb97d1-1f2a-4f38-8e7a-3e2a0b4a1234"
$pvsSite  = "samplePvsSiteGuid"

# Example PVS vDisk GUID: "a1b2c3d4-5678-90ab-cdef-1234567890ab"
$pvsVDisk = "samplePvsVDiskGuid"

# XenServer-specific custom properties, if required for your environment.
# Leave empty unless you need hosting-platform-specific settings.
$sampleCustomProperties = ""

# Write-back cache disk size (in GB)
# Example: 20, 40, 80 depending on I/O profile and image size
$writeBackCacheDiskSizeGB = 40        # Adjust as needed, e.g. 20, 40, 80

#------------------------------------------------- User Input: Broker Catalog -----------------------------------------------------#
# AllocationType:
#   "Random"  = pooled desktops; users get any available VM
#   "Static"  = dedicated desktops; users are permanently assigned a VM
$allocationType = "Random"

# Description shown in Studio / Web Studio
$description = "PVS provisioning using MCS on XenServer - sample catalog (update for production use)."

# PersistUserChanges:
#   "Discard" = changes are discarded (pooled/non-persistent)
$persistUserChanges = "Discard"

# SessionSupport:
#   "MultiSession" = server OS / multi-session workloads
#   "SingleSession" = single-session (VDI) workloads
$sessionSupport = "MultiSession"

#------------------------------------------------- Derived paths (XDHyp:\) --------------------------------------------------------#
# Network mapping for the first NIC on XenServer.
$networkMapping = @{
    "0" = "XDHyp:\HostingUnits\$hostingUnitName\$networkName.network"
}

# Machine profile path used to define VM hardware characteristics.
$machineProfilePath = "XDHyp:\HostingUnits\$hostingUnitName\$machineProfileVmName.vm\$machineProfileSnapshotName.snapshot"

#------------------------------------------------- Create Identity Pool -----------------------------------------------------------#
# Identity pool defines how machine accounts are named and in which domain they are created.
New-AcctIdentityPool `
    -IdentityPoolName $identityPoolName `
    -NamingScheme "$($sampleNamingScheme)##" `
    -NamingSchemeType Numeric `
    -Domain $domain

#------------------------------------------------- Create the Provisioning Scheme -------------------------------------------------#
# The provisioning scheme ties PVS, hosting, and identity together to define how VMs are created.
$createdProvScheme = New-ProvScheme -CleanOnBoot:$isCleanOnBoot `
    -ProvisioningSchemeName $provisioningSchemeName `
    -ProvisioningSchemeType PVS `
    -PVSSite $pvsSite `
    -PVSvDisk $pvsVDisk `
    -HostingUnitName $hostingUnitName `
    -IdentityPoolName $identityPoolName `
    -InitialBatchSizeHint $initialBatchSizeHint `
    -MachineProfile $machineProfilePath `
    -NetworkMapping $networkMapping `
    -CustomProperties $sampleCustomProperties `
    -VMCpuCount $vmCpuCount `
    -VMMemoryMB $vmMemoryMB `
    -UseWriteBackCache -WriteBackCacheDiskSize $writeBackCacheDiskSizeGB

#------------------------------------------------- Create the Broker Catalog ------------------------------------------------------#
# The broker catalog makes the provisioning scheme visible and usable in Studio / Web Studio.
New-BrokerCatalog -Name $provisioningSchemeName `
    -ProvisioningSchemeId $createdProvScheme.ProvisioningSchemeUid `
    -AllocationType $allocationType `
    -Description $description `
    -IsRemotePC $False `
    -PersistUserChanges $persistUserChanges `
    -ProvisioningType "MCS" `
    -Scope @() `
    -SessionSupport $sessionSupport