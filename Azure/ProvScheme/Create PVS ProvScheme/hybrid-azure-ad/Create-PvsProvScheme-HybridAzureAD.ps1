# /*************************************************************************
# * Copyright © Citrix Systems, Inc. All Rights Reserved.
# * This file is subject to the license terms contained
# * in the license file that is distributed with this file.
# *************************************************************************/

<#
.SYNOPSIS
    Creates a Hybrid Azure AD joined PVS catalog using MCS.

.DESCRIPTION
    Create-PvsProvScheme-HybridAzureAD.ps1 creates a PVS Provisioning Scheme (PVS provisioning using MCS)
    and a PVS‑backed Machine Catalog configured for Hybrid Azure AD joined machines.

    IMPORTANT:
    - Review and update ALL "Replaceable parameters" before running.
    - Run from a Delivery Controller (DDC) with Citrix PowerShell SDK installed.
#>

# ==============================
# Replaceable parameters
# ==============================

# Identity / domain (Hybrid Azure AD)
$identityPoolName        = "HybridAADJoinedCatalog"     # Hybrid Azure AD identity pool name

$domainPrefix            = "corp"                      # AD DNS prefix (e.g. corp)
$domainExtension         = "local"                     # AD DNS suffix (e.g. local)
$domainFqdn              = "$domainPrefix.$domainExtension"

# OU where computer accounts are created (must be in the Hybrid AAD-sync OU)
$ouDn                    = "CN=AADComputers,DC=$domainPrefix,DC=$domainExtension"

# AD account with permissions to create computer accounts and set userCertificate
$adAdminUser             = "corp\admin1"               # Domain\user (matches CVAD doc pattern)

# NOTE:
# - The password is NOT stored in the script.
# - User is prompted at runtime and the password is kept as a SecureString.
# - The extra ConvertFrom/ConvertTo roundtrip matches the requested pattern.
$SecureUserInput = Read-Host 'Enter password for AD admin account' -AsSecureString
$EncryptedInput  = ConvertFrom-SecureString -String $SecureUserInput
$securePassword  = ConvertTo-SecureString -String $EncryptedInput

# Number of AD accounts / VMs to create initially
$accountCount            = 10

# PVS / hosting / Azure (PVS provisioning using MCS)
$isCleanOnBoot           = $true
$provisioningSchemeName  = "demo-provScheme-hybridAAD"
$hostingUnitName         = "demo-hostingUnit"
$networkMappingRgName    = "demo-networkMappingResourceGroup"
$region                  = "East US"
$vNet                    = "MyVnet"
$subnet                  = "subnet1"
$numberOfVms             = 10                          # Initial batch size hint

$machineProfileRgName    = "demo-machineProfileResourceGroup"
$machineProfileName      = "mymachineprofile"

# Write-back cache disk size (in GB)
$writeBackCacheDiskSizeGB = 40                         # Adjust as needed, e.g. 20, 40, 80

# PVS site / vDisk (GUIDs or IDs from Get-HypPvsSite / Get-HypPvsDiskInfo)
$pvsSite                 = "samplePvsSiteGuid"
$pvsVDisk                = "samplePvsVDiskGuid"

# Naming scheme for computer accounts (Hybrid AAD guidance)
$sampleNamingScheme      = "HybridAAD-VM-"

# Custom properties for Azure PVS ProvScheme (adjust as needed; avoid disallowed props for PVS-on-Azure)
$sampleCustomProperties  = "<CustomProperties xmlns=`"http://schemas.citrix.com/2014/xd/machinecreation`" xmlns:xsi=`"http://www.w3.org/2001/XMLSchema-instance`"><Property xsi:type=`"StringProperty`" Name=`"UseManagedDisks`" Value=`"true`" /><Property xsi:type=`"StringProperty`" Name=`"OsType`" Value=`"Windows`" /><Property xsi:type=`"StringProperty`" Name=`"StorageType`" Value=`"StandardSSD_LRS`" /><Property xsi:type=`"StringProperty`" Name=`"PersistWBC`" Value=`"true`" /><Property xsi:type=`"StringProperty`" Name=`"PersistOsDisk`" Value=`"false`" /><Property xsi:type=`"StringProperty`" Name=`"PersistVm`" Value=`"false`" /><Property xsi:type=`"StringProperty`" Name=`"WBCDiskStorageType`" Value=`"Premium_LRS`" /><Property xsi:type=`"StringProperty`" Name=`"UseTempDiskForWBC`" Value=`"false`" /><Property xsi:type=`"StringProperty`" Name=`"LicenseType`" Value=`"Windows_Server`" /><Property xsi:type=`"StringProperty`" Name=`"Zones`" Value=`"`" /></CustomProperties>"

# Broker catalog settings
$allocationType          = "Random"
$description             = "PVS provisioning using MCS – Hybrid Azure AD joined catalog"
$persistUserChanges      = "Discard"
$sessionSupport          = "MultiSession"

# ==============================
# Derived paths (XDHyp:\)
# ==============================

$networkMapping = @{
    "0" = "XDHyp:\HostingUnits\$hostingUnitName\$region.region\virtualprivatecloud.folder\$networkMappingRgName.resourcegroup\$vNet.virtualprivatecloud\$subnet.network"
}

$serviceOffering = "XDHyp:\HostingUnits\$hostingUnitName\serviceoffering.folder\Standard_D2s_v3.serviceoffering"

$machineProfilePath = "XDHyp:\HostingUnits\$hostingUnitName\machineprofile.folder\$machineProfileRgName.resourcegroup\$machineProfileName.vm"

# ==============================
# End of replaceable parameters
# ==============================

# Add Citrix snap-ins
Add-PSSnapin -Name "Citrix.Host.Admin.V2","Citrix.MachineCreation.Admin.V2","Citrix.Broker.Admin.V2" -ErrorAction SilentlyContinue

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
    -NetworkMapping $networkMapping `
    -ServiceOffering $serviceOffering `
    -CustomProperties $sampleCustomProperties `
    -MachineProfile $machineProfilePath `
    -UseWriteBackCache -WriteBackCacheDiskSize $writeBackCacheDiskSizeGB

#------------------------------------------------- Create the Broker Catalog (Hybrid Azure AD) -----------------------------------#

New-BrokerCatalog -Name $provisioningSchemeName `
    -ProvisioningSchemeId $createdProvScheme.ProvisioningSchemeUid `
    -AllocationType $allocationType  `
    -Description $description `
    -IsRemotePC $False `
    -PersistUserChanges $persistUserChanges `
    -ProvisioningType "MCS" `
    -Scope @() `
    -SessionSupport $sessionSupport