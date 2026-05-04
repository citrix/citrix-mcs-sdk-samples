# /*************************************************************************
# * Copyright © Citrix Systems, Inc. All Rights Reserved.
# * This file is subject to the license terms contained
# * in the license file that is distributed with this file.
# *************************************************************************/

<#
.SYNOPSIS
    Creates a Hybrid Entra joined joined PVS catalog using MCS.

.DESCRIPTION
    Create-PvsProvScheme-HybridEntraJoined.ps1 creates a PVS Provisioning Scheme (PVS provisioning using MCS)
    and a PVS‑backed Machine Catalog configured for Hybrid Entra joined joined machines.

    The original version of this script is compatible with
    Citrix Virtual Apps and Desktops 7 2402 Long Term Service Release (LTSR) or later.

    IMPORTANT:
    - Review and update ALL "Replaceable parameters" before running.
    - Run from a Delivery Controller (DDC) with Citrix PowerShell SDK installed.
#>

# ==============================
# Replaceable parameters
# ==============================

# Identity / domain (Hybrid Entra joined)

# Hybrid Entra joined identity pool name
# Example: "CTX-HybridAAD-MultiSession-EastUS"
$identityPoolName        = "HybridAADJoinedCatalog"

# AD DNS prefix (NetBIOS-style, left part of FQDN)
# Example: "corp", "emea", "prod"
$domainPrefix            = "corp"

# AD DNS suffix (right part of FQDN)
# Example: "local", "contoso.com", "company.com"
$domainExtension         = "local"

# Fully qualified domain name built from prefix + suffix
# Example result: "corp.local"
$domainFqdn              = "$domainPrefix.$domainExtension"

# OU where computer accounts are created (must be in the Hybrid AAD-sync OU)
# Example: "OU=HybridAADComputers,OU=Citrix,DC=corp,DC=local"
$ouDn                    = "CN=AADComputers,DC=$domainPrefix,DC=$domainExtension"

# AD account with permissions to create computer accounts and set userCertificate
# Example: "corp\citrixsvc-join" (dedicated service account)
$adAdminUser             = "corp\admin1"               # Domain\user (matches CVAD doc pattern)

# NOTE:
# - The password is NOT stored in the script.
# - User is prompted at runtime and the password is kept as a SecureString.
# - The extra ConvertFrom/ConvertTo roundtrip matches the requested pattern.
$SecureUserInput = Read-Host 'Enter password for AD admin account' -AsSecureString
$EncryptedInput  = ConvertFrom-SecureString -String $SecureUserInput
$securePassword  = ConvertTo-SecureString -String $EncryptedInput

# Number of AD accounts / VMs to create initially
# Example: 10, 25, 50 depending on initial deployment size
$accountCount            = 10

# PVS / hosting / Azure (PVS provisioning using MCS)

# CleanOnBoot:
#   $true  = non-persistent (recommended for pooled workloads)
#   $false = persistent (changes retained; use with care)
# Example: $true for Hybrid AAD pooled session hosts
$isCleanOnBoot           = $true

# Name of provisioning scheme & broker catalog
# Example: "CTX-HybridAAD-PVS-MCS-EastUS"
$provisioningSchemeName  = "demo-provScheme-hybridAAD"

# Hosting unit name as defined in Studio / Web Studio
# Example: "Azure-EastUS-Prod-Connection"
$hostingUnitName         = "demo-hostingUnit"

# Azure resource group that contains the vNet/subnet
# Example: "rg-xd-networking-eastus"
$networkMappingRgName    = "demo-networkMappingResourceGroup"

# Azure region (must match your hosting unit)
# Example: "East US", "West Europe", "Central US"
$region                  = "East US"

# Azure vNet name
# Example: "vnet-xd-hybridaad-eastus"
$vNet                    = "MyVnet"

# Azure subnet name for session hosts
# Example: "subnet-session-hosts"
$subnet                  = "subnet1"

# Initial batch size hint for VM creation
# Example: 10, 20, 50
$numberOfVms             = 10                          # Initial batch size hint

# Machine profile resource group (template VM)
# Example: "rg-xd-machineprofiles-eastus"
$machineProfileRgName    = "demo-machineProfileResourceGroup"

# Machine profile VM name
# Example: "mp-windows-2022-multisession"
$machineProfileName      = "mymachineprofile"

# Write-back cache disk size (in GB)
# Example: 20, 40, 80 depending on workload and vDisk size
$writeBackCacheDiskSizeGB = 40                         # Adjust as needed, e.g. 20, 40, 80

# PVS site / vDisk (GUIDs or IDs from Get-HypPvsSite / Get-HypPvsDiskInfo)
# Example PVS Site GUID: "f3bb97d1-1f2a-4f38-8e7a-3e2a0b4a1234"
$pvsSite                 = "samplePvsSiteGuid"

# Example PVS vDisk GUID: "a1b2c3d4-5678-90ab-cdef-1234567890ab"
$pvsVDisk                = "samplePvsVDiskGuid"

# Naming scheme for computer accounts (Hybrid AAD guidance)
# Example: "HYBAAD-SH-" -> HYBAAD-SH-01, HYBAAD-SH-02, ...
$sampleNamingScheme      = "HybridAAD-VM-"

# Custom properties for Azure PVS ProvScheme (adjust as needed; avoid disallowed props for PVS-on-Azure)
# Example configuration:
# - Managed disks
# - Windows OS
# - Standard SSD for OS
$sampleCustomProperties  = "<CustomProperties xmlns=`"http://schemas.citrix.com/2014/xd/machinecreation`" xmlns:xsi=`"http://www.w3.org/2001/XMLSchema-instance`"><Property xsi:type=`"StringProperty`" Name=`"UseManagedDisks`" Value=`"true`" /><Property xsi:type=`"StringProperty`" Name=`"OsType`" Value=`"Windows`" /><Property xsi:type=`"StringProperty`" Name=`"StorageType`" Value=`"StandardSSD_LRS`" /><Property xsi:type=`"StringProperty`" Name=`"PersistWBC`" Value=`"true`" /><Property xsi:type=`"StringProperty`" Name=`"PersistOsDisk`" Value=`"false`" /><Property xsi:type=`"StringProperty`" Name=`"PersistVm`" Value=`"false`" /><Property xsi:type=`"StringProperty`" Name=`"WBCDiskStorageType`" Value=`"Premium_LRS`" /><Property xsi:type=`"StringProperty`" Name=`"UseTempDiskForWBC`" Value=`"false`" /><Property xsi:type=`"StringProperty`" Name=`"LicenseType`" Value=`"Windows_Server`" /><Property xsi-type=`"StringProperty`" Name=`"Zones`" Value=`"`" /></CustomProperties>"

# Broker catalog settings

# AllocationType:
#   "Random" = pooled; users get any available VM
#   "Static" = dedicated; users always get the same VM
# Example: "Random" for pooled Hybrid AAD session hosts
$allocationType          = "Random"

# Description shown in Studio / Web Studio
# Example: "Hybrid AAD joined multi-session catalog using PVS with MCS"
$description             = "PVS provisioning using MCS – Hybrid Entra joined joined catalog"

# PersistUserChanges:
#   "Discard" = non-persistent
$persistUserChanges      = "Discard"

# SessionSupport:
#   "MultiSession"  = server OS / multi-session (e.g. Windows Server, Windows 10/11 multi-session)
#   "SingleSession" = single-session VDI
# Example: "MultiSession" for host pools with multiple users per VM
$sessionSupport          = "MultiSession"

# ==============================
# Derived paths (XDHyp:\)
# ==============================

# Network mapping for Azure vNet/subnet (index "0" usually first NIC)
# Example resulting path:
#   XDHyp:\HostingUnits\Azure-EastUS-Prod-Connection\East US.region\virtualprivatecloud.folder\rg-xd-networking-eastus.resourcegroup\vnet-xd-hybridaad-eastus.virtualprivatecloud\subnet-session-hosts.network
$networkMapping = @{
    "0" = "XDHyp:\HostingUnits\$hostingUnitName\$region.region\virtualprivatecloud.folder\$networkMappingRgName.resourcegroup\$vNet.virtualprivatecloud\$subnet.network"
}

# Service offering (VM size) – adjust to Azure SKU you use
# Example SKU: Standard_D4s_v5, Standard_D8s_v5, etc.
$serviceOffering = "XDHyp:\HostingUnits\$hostingUnitName\serviceoffering.folder\Standard_D2s_v3.serviceoffering"

# Machine profile path – template VM for hardware configuration
# Example:
#   XDHyp:\HostingUnits\Azure-EastUS-Prod-Connection\machineprofile.folder\rg-xd-machineprofiles-eastus.resourcegroup\mp-windows-2022-multisession.vm
$machineProfilePath = "XDHyp:\HostingUnits\$hostingUnitName\machineprofile.folder\$machineProfileRgName.resourcegroup\$machineProfileName.vm"

# ==============================
# End of replaceable parameters
# ==============================

# Add Citrix snap-ins
Add-PSSnapin -Name "Citrix.Host.Admin.V2","Citrix.MachineCreation.Admin.V2","Citrix.Broker.Admin.V2" -ErrorAction SilentlyContinue

#------------------------------------------------- Create Hybrid Entra joined Identity Pool ------------------------------------------#

New-AcctIdentityPool `
    -AllowUnicode `
    -IdentityType "HybridAzureAD" `
    -Domain $domainFqdn `
    -IdentityPoolName $identityPoolName `
    -NamingScheme "$($sampleNamingScheme)##" `
    -NamingSchemeType "Numeric" `
    -OU $ouDn `
    -Scope @()

#------------------------------------------------- Create AD Accounts for Hybrid Entra joined ----------------------------------------#

New-AcctADAccount `
    -IdentityPoolName $identityPoolName `
    -Count $accountCount `
    -ADUserName $adAdminUser `
    -ADPassword $securePassword `
    -OutVariable acctResult

$acctResult.SuccessfulAccounts | Select-Object ADAccountName

#------------------------------------------------- Set userCertificate for AD Accounts -------------------------------------------#

Set-AcctAdAccountUserCert `
    -IdentityPoolName $identityPoolName `
    -ADUserName $adAdminUser `
    -ADPassword $securePassword `
    -All

#------------------------------------------------- Create the PVS ProvisioningScheme (PVS provisioning using MCS) ----------------#

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
    -MachineProfile $machineProfilePath `
    -UseWriteBackCache -WriteBackCacheDiskSize $writeBackCacheDiskSizeGB

#------------------------------------------------- Create the Broker Catalog (Hybrid Entra joined) -----------------------------------#

New-BrokerCatalog -Name $provisioningSchemeName `
    -ProvisioningSchemeId $createdProvScheme.ProvisioningSchemeUid `
    -AllocationType $allocationType  `
    -Description $description `
    -IsRemotePC $False `
    -PersistUserChanges $persistUserChanges `
    -ProvisioningType "MCS" `
    -Scope @() `
    -SessionSupport $sessionSupport
