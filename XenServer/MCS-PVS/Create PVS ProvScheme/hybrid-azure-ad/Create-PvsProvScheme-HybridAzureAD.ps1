# /*************************************************************************
# * Copyright © Citrix Systems, Inc. All Rights Reserved.
# * This file is subject to the license terms contained
# * in the license file that is distributed with this file.
# *************************************************************************/

<#
.SYNOPSIS
    Creates a Hybrid Azure AD joined PVS catalog using MCS on XenServer.

.DESCRIPTION
    Create-PvsProvScheme-HybridAzureAD.ps1 creates a PVS Provisioning Scheme (PVS provisioning using MCS)
    and a PVS-backed Machine Catalog configured for Hybrid Azure AD joined machines hosted on XenServer.

    The original version of this script is compatible with
    Citrix Virtual Apps and Desktops 7 2402 Long Term Service Release (LTSR) or later.

    IMPORTANT:
    - Review and update ALL "Replaceable parameters" before running.
    - Run from a Delivery Controller (DDC) with Citrix PowerShell SDK installed.
#>

# ==============================
# Replaceable parameters
# ==============================

# Identity / domain (Hybrid Azure AD)

# Hybrid Azure AD identity pool name
# Example: "CTX-HybridAAD-MultiSession-XenServer"
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
$EncryptedInput  = ConvertFrom-SecureString -SecureString $SecureUserInput
$securePassword  = ConvertTo-SecureString -String $EncryptedInput

# Number of AD accounts / VMs to create initially
# Example: 10, 25, 50 depending on initial deployment size
$accountCount            = 10

# PVS / hosting / XenServer (PVS provisioning using MCS)

# CleanOnBoot:
#   $true  = non-persistent (recommended for pooled workloads)
#   $false = persistent (changes retained; use with care)
# Example: $true for Hybrid AAD pooled session hosts
$isCleanOnBoot           = $true

# Name of provisioning scheme & broker catalog
# Example: "CTX-HybridAAD-PVS-MCS-XenServer"
$provisioningSchemeName  = "demo-provScheme-hybridAAD"

# Hosting unit name as defined in Studio / Web Studio
# Example: "XenServer-Prod-HostingUnit"
$hostingUnitName         = "demo-hostingUnit"

# Hosting unit network name for the first NIC
# Example: "Pool Network 0"
$networkName             = "Pool Network 0"

# Machine profile used to define the hardware configuration (CPU, memory, NIC, etc.) for the catalog.
# The machine profile must be a VM snapshot that exists in the same hosting unit.
# The path format is: XDHyp:\HostingUnits\<HostingUnitName>\<VmName>.vm\<SnapshotName>.snapshot
# Example VM name: "MyVmName"
$machineProfileVmName       = "MyVmName"

# Example snapshot name: "MySnapshotName"
$machineProfileSnapshotName = "MySnapshotName"

# Initial batch size hint for MCS workflow planning.
# This value is passed to -InitialBatchSizeHint and does NOT create VMs by itself.
$numberOfVms             = 10

# CPU and memory settings to apply to provisioned VMs
# Example CPU count: 2, 4, 8
$vmCpuCount              = 2

# Example memory in MB: 4096, 8192, 16384
$vmMemoryMB              = 8192

# Write-back cache disk size (in GB)
# Example: 20, 40, 80 depending on workload and vDisk size
$writeBackCacheDiskSizeGB = 40                         # Adjust as needed, e.g. 20, 40, 80

# PVS site / vDisk (GUIDs or IDs from Get-HypPvsSite / Get-HypPvsDiskInfo)
# Example PVS Site GUID: "f3bb97d1-1f2a-4f38-8e7a-3e2a0b4a1234"
$pvsSite                 = "samplePvsSiteGuid"

# Example PVS vDisk GUID: "a1b2c3d4-5678-90ab-cdef-1234567890ab"
$pvsVDisk                = "samplePvsVDiskGuid"

# Naming scheme for computer accounts (Hybrid AAD guidance)
# Example: "HYBAAD-XEN-" -> HYBAAD-XEN-01, HYBAAD-XEN-02, ...
$sampleNamingScheme      = "HybridAAD-VM-"

# XenServer-specific custom properties, if required for your environment.
# Leave empty unless you need hosting-platform-specific settings.
$sampleCustomProperties  = ""

# Broker catalog settings

# AllocationType:
#   "Random" = pooled; users get any available VM
#   "Static" = dedicated; users always get the same VM
# Example: "Random" for pooled Hybrid AAD session hosts
$allocationType          = "Random"

# Description shown in Studio / Web Studio
$description             = "PVS provisioning using MCS on XenServer - Hybrid Azure AD joined catalog"

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

# Network mapping for the first NIC on XenServer.
$networkMapping = @{
    "0" = "XDHyp:\HostingUnits\$hostingUnitName\$networkName.network"
}

# Machine profile path used to define VM hardware characteristics.
# Format: XDHyp:\HostingUnits\<HostingUnitName>\<VmName>.vm\<SnapshotName>.snapshot
$machineProfilePath = "XDHyp:\HostingUnits\$hostingUnitName\$machineProfileVmName.vm\$machineProfileSnapshotName.snapshot"

# ==============================
# End of replaceable parameters
# ==============================

# Add Citrix snap-ins
Add-PSSnapin -Name "Citrix.ADIdentity.Admin.V2","Citrix.Host.Admin.V2","Citrix.MachineCreation.Admin.V2","Citrix.Broker.Admin.V2" -ErrorAction SilentlyContinue

#------------------------------------------------- Create Hybrid Azure AD Identity Pool ------------------------------------------#

New-AcctIdentityPool `
    -AllowUnicode `
    -IdentityType "HybridAzureAD" `
    -Domain $domainFqdn `
    -IdentityPoolName $identityPoolName `
    -NamingScheme "$($sampleNamingScheme)##" `
    -NamingSchemeType "Numeric" `
    -OU $ouDn `
    -Scope @()

#------------------------------------------------- Create AD Accounts for Hybrid Azure AD ----------------------------------------#

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
    -MachineProfile $machineProfilePath `
    -NetworkMapping $networkMapping `
    -CustomProperties $sampleCustomProperties `
    -VMCpuCount $vmCpuCount `
    -VMMemoryMB $vmMemoryMB `
    -UseWriteBackCache -WriteBackCacheDiskSize $writeBackCacheDiskSizeGB

#------------------------------------------------- Create the Broker Catalog (Hybrid Azure AD) -----------------------------------#

New-BrokerCatalog -Name $provisioningSchemeName `
    -ProvisioningSchemeId $createdProvScheme.ProvisioningSchemeUid `
    -AllocationType $allocationType `
    -Description $description `
    -IsRemotePC $False `
    -PersistUserChanges $persistUserChanges `
    -ProvisioningType "MCS" `
    -Scope @() `
    -SessionSupport $sessionSupport
