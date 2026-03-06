# /*************************************************************************
# * Copyright © Citrix Systems, Inc. All Rights Reserved.
# * This file is subject to the license terms contained
# * in the license file that is distributed with this file.
# *************************************************************************/

<#
.SYNOPSIS
    Creates a PVS provisioning scheme and a broker catalog using MCS provisioning.

.DESCRIPTION
    Create-PvsProvScheme.ps1 creates a PVS Provisioning Scheme and an associated
    Machine Catalog that uses MCS provisioning with PVS-backed machines.

    The original version of this script is compatible with
    Citrix Virtual Apps and Desktops 7 2402 Long Term Service Release (LTSR) or later.

    IMPORTANT:
    - Review and update ALL user input parameters in the "User Input Required" sections.
    - Run from a Delivery Controller (DDC) with the Citrix PowerShell SDK installed.
#>

# Add Citrix snap-ins (idempotent: ignore errors if already loaded)
Add-PSSnapin -Name "Citrix.Host.Admin.V2","Citrix.MachineCreation.Admin.V2","Citrix.Broker.Admin.V2" -ErrorAction SilentlyContinue

#------------------------------------------------- User Input: Provisioning Scheme ------------------------------------------------#
# CleanOnBoot:
#   $true  = non-persistent VMs (disk reset on reboot; typical for pooled, non-persistent workloads)
#   $false = persistent VMs (changes kept; use with care for PVS)
# Example: $true for pooled non-persistent workloads; $false for special persistent workloads
$isCleanOnBoot = $true

# Name of the provisioning scheme and identity pool (can be different if desired)
# Example: "CTX-PVS-MCS-Prod-Scheme"
$provisioningSchemeName = "demo-provScheme"

# Identity pool name (typically same as provisioning scheme)
# Example: "CTX-PVS-MCS-Prod-IdentityPool"
$identityPoolName       = $provisioningSchemeName

# Hosting unit name as configured in Studio / Web Studio (Azure hosting connection)
# Example: "Azure-Prod-EastUS-Connection"
$hostingUnitName = "demo-hostingUnit"

# Azure resource group that contains the vNet/subnet used by the VMs
# Example: "rg-xd-networking-eastus"
$networkMappingResourceGroupName = "demo-networkMappingResourceGroup"

# Azure region and network configuration
# Example region: "East US", "West Europe", "Central US"
$region = "East US"

# Example vNet name: "vnet-xd-prod-eastus"
$vNet   = "MyVnet"

# Example subnet name: "subnet-session-hosts"
$subnet = "subnet1"

# Initial number of VMs to create when provisioning (hint; can be increased later)
# Example: 5, 10, 50 depending on your initial deployment size
$numberOfVms = 1

# Machine profile resource group and name (template VM defining size, disks, etc.)
# Example RG: "rg-xd-machineprofiles-eastus"
$machineProfileResourceGroupName = "demo-machineProfileResourceGroup"

# Example profile VM name: "mp-windows-2022-multi"
$machineProfile                  = "mymachineprofile"

# Naming scheme and domain for machine accounts
# Example naming scheme: "CTX-PVS-MCS-VDI-" => machines become CTX-PVS-MCS-VDI-01, CTX-PVS-MCS-VDI-02, ...
$sampleNamingScheme = "sampleNaming"   # Example: "CTX-PVS-MCS-VDI-"

# Example domain: "corp.local" or "corp.company.com"
$domain             = "sampleDomain"   # Example: "corp.local"

# PVS site and vDisk identifiers (from Get-HypPvsSite / Get-HypPvsDiskInfo)
# Example PVS site GUID: "f3bb97d1-1f2a-4f38-8e7a-3e2a0b4a1234"
$pvsSite  = "samplePvsSiteGuid"

# Example PVS vDisk GUID: "a1b2c3d4-5678-90ab-cdef-1234567890ab"
$pvsVDisk = "samplePvsVDiskGuid"

# Write-back cache disk size (in GB) – parameterized
# Example: 20, 40, 80 depending on I/O profile and image size
$writeBackCacheDiskSizeGB = 40        # Adjust as needed, e.g. 20, 40, 80

# Custom properties for Azure PVS ProvScheme (adjust to your environment; avoid disallowed props)
# Example: Use managed disks, Windows OS, Standard SSD for OS
# IMPORTANT: Ensure this matches your hosting and licensing requirements.
$sampleCustomProperties = "<CustomProperties xmlns=`"http://schemas.citrix.com/2014/xd/machinecreation`" xmlns:xsi=`"http://www.w3.org/2001/XMLSchema-instance`"><Property xsi:type=`"StringProperty`" Name=`"UseManagedDisks`" Value=`"true`" /><Property xsi:type=`"StringProperty`" Name=`"OsType`" Value=`"Windows`" /><Property xsi:type=`"StringProperty`" Name=`"StorageType`" Value=`"StandardSSD_LRS`" /><Property xsi:type=`"StringProperty`" Name=`"PersistWBC`" Value=`"true`" /><Property xsi:type=`"StringProperty`" Name=`"PersistOsDisk`" Value=`"false`" /><Property xsi:type=`"StringProperty`" Name=`"PersistVm`" Value=`"false`" /><Property xsi:type=`"StringProperty`" Name=`"WBCDiskStorageType`" Value=`"Premium_LRS`" /><Property xsi:type=`"StringProperty`" Name=`"UseTempDiskForWBC`" Value=`"false`" /><Property xsi:type=`"StringProperty`" Name=`"LicenseType`" Value=`"Windows_Server`" /><Property xsi-type=`"StringProperty`" Name=`"Zones`" Value=`"`" /></CustomProperties>"

#------------------------------------------------- User Input: Broker Catalog -----------------------------------------------------#
# AllocationType:
#   "Random"  = pooled desktops; users get any available VM
#   "Static"  = dedicated desktops; users are permanently assigned a VM
# Example: "Random" for pooled session hosts; "Static" for dedicated VDI
$allocationType = "Random"

# Description shown in Studio / Web Studio
# Example: "Prod multi-session catalog using PVS with MCS provisioning"
$description = "PVS provisioning using MCS – sample catalog (update for production use)."

# PersistUserChanges:
#   "Discard" = changes are discarded (pooled/non-persistent)
$persistUserChanges = "Discard"

# SessionSupport:
#   "MultiSession" = server OS / multi-session workloads
#   "SingleSession" = single-session (VDI) workloads
# Example: "MultiSession" for Windows Server / multi-session; "SingleSession" for Windows 10/11 VDI
$sessionSupport = "MultiSession"

#------------------------------------------------- Derived paths (XDHyp:\) --------------------------------------------------------#
# Network mapping for Azure vNet/subnet (index "0" is typically the first NIC)
# Example resulting path:
#   XDHyp:\HostingUnits\Azure-Prod-EastUS-Connection\East US.region\virtualprivatecloud.folder\rg-xd-networking-eastus.resourcegroup\vnet-xd-prod-eastus.virtualprivatecloud\subnet-session-hosts.network
$networkMapping = @{
    "0" = "XDHyp:\HostingUnits\$hostingUnitName\$region.region\virtualprivatecloud.folder\$networkMappingResourceGroupName.resourcegroup\$vNet.virtualprivatecloud\$subnet.network"
}

# Service offering (VM size) – adjust to your chosen Azure VM SKU
# Example: Standard_D4s_v5, Standard_D8s_v5, etc.
$serviceOffering = "XDHyp:\HostingUnits\$hostingUnitName\serviceoffering.folder\Standard_D2s_v3.serviceoffering"

# Machine profile path – template VM used for hardware configuration
# Example:
#   XDHyp:\HostingUnits\Azure-Prod-EastUS-Connection\machineprofile.folder\rg-xd-machineprofiles-eastus.resourcegroup\mp-windows-2022-multi.vm
$sampleMachineProfilePath = "XDHyp:\HostingUnits\$hostingUnitName\machineprofile.folder\$machineProfileResourceGroupName.resourcegroup\$machineProfile.vm"

#------------------------------------------------- Create Identity Pool -----------------------------------------------------------#
# Identity pool defines how machine accounts are named and in which domain they are created.
New-AcctIdentityPool `
    -IdentityPoolName $provisioningSchemeName `
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
    -InitialBatchSizeHint $numberOfVms `
    -NetworkMapping $networkMapping `
    -ServiceOffering $serviceOffering `
    -CustomProperties $sampleCustomProperties `
    -MachineProfile $sampleMachineProfilePath `
    -UseWriteBackCache -WriteBackCacheDiskSize $writeBackCacheDiskSizeGB

#------------------------------------------------- Create the Broker Catalog ------------------------------------------------------#
# The broker catalog makes the provisioning scheme visible and usable in Studio / Web Studio.
New-BrokerCatalog -Name $provisioningSchemeName `
    -ProvisioningSchemeId $createdProvScheme.ProvisioningSchemeUid `
    -AllocationType $allocationType  `
    -Description $description `
    -IsRemotePC $False `
    -PersistUserChanges $persistUserChanges `
    -ProvisioningType "MCS" `
    -Scope @() `
    -SessionSupport $sessionSupport