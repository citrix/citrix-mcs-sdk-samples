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
$isCleanOnBoot = $true

# Name of the provisioning scheme and identity pool (can be different if desired)
$provisioningSchemeName = "demo-provScheme"
$identityPoolName       = $provisioningSchemeName

# Hosting unit name as configured in Studio / Web Studio (Azure hosting connection)
$hostingUnitName = "demo-hostingUnit"

# Azure resource group that contains the vNet/subnet used by the VMs
$networkMappingResourceGroupName = "demo-networkMappingResourceGroup"

# Azure region and network configuration
$region = "East US"
$vNet   = "MyVnet"
$subnet = "subnet1"

# Initial number of VMs to create when provisioning (hint; can be increased later)
$numberOfVms = 1

# Machine profile resource group and name (template VM defining size, disks, etc.)
$machineProfileResourceGroupName = "demo-machineProfileResourceGroup"
$machineProfile                  = "mymachineprofile"

# Naming scheme and domain for machine accounts
$sampleNamingScheme = "sampleNaming"   # Example: "CTX-VDI-"
$domain             = "sampleDomain"   # Example: "corp.local"

# PVS site and vDisk identifiers (from Get-HypPvsSite / Get-HypPvsDiskInfo)
$pvsSite  = "samplePvsSiteGuid"
$pvsVDisk = "samplePvsVDiskGuid"

# Write-back cache disk size (in GB) – parameterized
$writeBackCacheDiskSizeGB = 40        # Adjust as needed, e.g. 20, 40, 80

# Custom properties for Azure PVS ProvScheme (adjust to your environment; avoid disallowed props)
$sampleCustomProperties = "<CustomProperties xmlns=`"http://schemas.citrix.com/2014/xd/machinecreation`" xmlns:xsi=`"http://www.w3.org/2001/XMLSchema-instance`"><Property xsi:type=`"StringProperty`" Name=`"UseManagedDisks`" Value=`"true`" /><Property xsi:type=`"StringProperty`" Name=`"OsType`" Value=`"Windows`" /><Property xsi:type=`"StringProperty`" Name=`"StorageType`" Value=`"StandardSSD_LRS`" /><Property xsi:type=`"StringProperty`" Name=`"PersistWBC`" Value=`"true`" /><Property xsi:type=`"StringProperty`" Name=`"PersistOsDisk`" Value=`"false`" /><Property xsi:type=`"StringProperty`" Name=`"PersistVm`" Value=`"false`" /><Property xsi:type=`"StringProperty`" Name=`"WBCDiskStorageType`" Value=`"Premium_LRS`" /><Property xsi:type=`"StringProperty`" Name=`"UseTempDiskForWBC`" Value=`"false`" /><Property xsi:type=`"StringProperty`" Name=`"LicenseType`" Value=`"Windows_Server`" /><Property xsi-type=`"StringProperty`" Name=`"Zones`" Value=`"`" /></CustomProperties>"

#------------------------------------------------- User Input: Broker Catalog -----------------------------------------------------#
# AllocationType:
#   "Random"  = pooled desktops; users get any available VM
#   "Static"  = dedicated desktops; users are permanently assigned a VM
$allocationType = "Random"

# Description shown in Studio / Web Studio
$description = "PVS provisioning using MCS – sample catalog (update for production use)."

# PersistUserChanges:
#   "Discard" = changes are discarded (pooled/non-persistent)
#   "OnLocal" or "OnPvD" depending on your configuration (if using persistence)
$persistUserChanges = "Discard"

# SessionSupport:
#   "MultiSession" = server OS / multi-session workloads
#   "SingleSession" = single-session (VDI) workloads
$sessionSupport = "MultiSession"

#------------------------------------------------- Derived paths (XDHyp:\) --------------------------------------------------------#
# Network mapping for Azure vNet/subnet (index "0" is typically the first NIC)
$networkMapping = @{
    "0" = "XDHyp:\HostingUnits\$hostingUnitName\$region.region\virtualprivatecloud.folder\$networkMappingResourceGroupName.resourcegroup\$vNet.virtualprivatecloud\$subnet.network"
}

# Service offering (VM size) – adjust to your chosen Azure VM SKU
$serviceOffering = "XDHyp:\HostingUnits\$hostingUnitName\serviceoffering.folder\Standard_D2s_v3.serviceoffering"

# Machine profile path – template VM used for hardware configuration
$sampleMachineProfilePath = "XDHyp:\HostingUnits\$hostingUnitName\machineprofile.folder\$machineProfileResourceGroupName.resourcegroup\$machineProfile.vm"

# NOTE:
# If you intend to use a master image VM instead of a machine profile, set:
#   $masterImagePath = "XDHyp:\HostingUnits\...\<your-master-image>.vm"
# and update the New-ProvScheme call accordingly.

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