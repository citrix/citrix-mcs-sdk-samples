<#
.SYNOPSIS
    Creating a Machine Catalog.
.DESCRIPTION
    `Add-MachineCatalog.ps1` is tailored for creating a Machine Catalog.
    The original version of this script is compatible with Citrix Virtual Apps and Desktops 7 2203 Long Term Service Release (LTSR).
.INPUTS
    1. ProvisioningSchemeName: Name of the new provisioning scheme.
    2. HostingUnitName: Name of the hosting unit used.
    3. Domain: Active Directory domain name.
    4. UserName: The username for an AD user account with Write Permissions.
    5. ZoneUid: The UID that corresponds to the Zone in which these AD accounts will be created.
    6. AdminAddress: The primary DDC address.
    7. NamingScheme: Template for AD account names.
    8. NamingSchemeType: Naming scheme type for the catalog.
    9. ProvisioningType: Type of provisioning used.
    10. SessionSupport: Single or multi-session capability.
    11. AllocationType: User assignment method for machines.
    12. PersistUserChanges: User data persistence method.
    13. CleanOnBoot: Reset VMs to initial state on start.
    14. MasterImage: Path to VM snapshot or template.
    15. CustomProperties: Specific properties for the hosting infrastructure.
    16. Scope: Administration scopes for the identity pool.
    17. Count: Number of accounts to be created.
.OUTPUTS
    1. A New Identity Pool.
    4. New ADAccount(s).
    3. A Provisioning Scheme.
    5. New ProvVM(s).
    2. A New Broker Catalog.
    6. New Broker Machine(s).
.NOTES
    Version      : 1.0.0
    Author       : Citrix Systems, Inc.
.EXAMPLE
    .\Add-MachineCatalog.ps1 `
        -ProvisioningSchemeName "MyCatalog" `
        -HostingUnitName "Myresource" `
        -Domain "MyDomain.local" `
        -UserName "MyUserName" `
        -Password "MyPassword" `
        -ZoneUid "aaaaaaaa-bbbb-cccc-dddd-eeeeeeeeeeee" `
        -AdminAddress "MyDDC.MyDomain.local" `
        -NamingScheme "MyVM###" `
        -NamingSchemeType "Numeric" `
        -ProvisioningType "MCS" `
        -SessionSupport "Single"  `
        -AllocationType "Random"  `
        -PersistUserChanges "Discard" `
        -CleanOnBoot $True `
        -MasterImage "XDHyp:\HostingUnits\Myresource\MyVM.vm\MySnapshot.snapshot"  `
        -CustomProperties "" `
        -Scope @() `
        -Count 2
#>

# /*************************************************************************
# * Copyright © 2024. Cloud Software Group, Inc. All Rights Reserved.
# * This file is subject to the license terms contained
# * in the license file that is distributed with this file.
# *************************************************************************/

param(
    [string] $ProvisioningSchemeName,
    [string] $HostingUnitName,
    [string] $Domain,
    [switch] $WorkGroupMachine = $false,
    [string] $UserName,
    [guid] $ZoneUid,
    [string] $AdminAddress = $null,
    [string] $NamingScheme,
    [string] $NamingSchemeType,
    [string] $ProvisioningType,
    [string] $SessionSupport,
    [string] $AllocationType,
    [string] $PersistUserChanges,
    [switch] $CleanOnBoot = $false,
    [string] $MasterImage,
    [string] $CustomProperties = "",
    [string[]] $Scope = @(),
    [int] $Count,
    [switch] $UseFullDiskCloneProvisioning = $false,
    [switch] $UseWriteBackCache = $false,
    [int] $WriteBackCacheDiskSize,
    [int] $WriteBackCacheMemorySize,
    [string] $WriteBackCacheDriveLetter
)

# Enable Citrix PowerShell Cmdlets
Add-PSSnapin citrix*

# Convert the inputs into array formats.
$Scope = @($Scope)

# Basic Validation for the input
if (($CleanOnBoot -eq $True) -and ($PersistUserChanges -eq "OnLocal")) {
    Write-Output "Invalid Input. PersistUserChanges cannot be OnLocal when CleanOnBoot is set."
}

######################################
# Step 1: Create a New Identity Pool #
######################################
Write-Output "Step 1: Create a New Identity Pool."

# Configure the common parameters for New-AcctIdentityPool.
$newAcctIdentityPoolParameters = @{
    IdentityPoolName    = $ProvisioningSchemeName
    ZoneUid             = $ZoneUid
    NamingScheme        = $NamingScheme
    NamingSchemeType    = $NamingSchemeType
    Scope               = $Scope
    AllowUnicode        = $true
}

# Update the configuration for (Non-)Domain-Joined IdentityPool
if ($WorkGroupMachine) {
    # If $WorkGroupMachine is specified, update the configuration for a Non-Domained-Joined IdentityPool
    $newAcctIdentityPoolParameters['WorkGroupMachine'] = $WorkGroupMachine
}
else {
    # Else, update the configuration for a Domained-Joined IdentityPool
    $newAcctIdentityPoolParameters['Domain'] = $Domain
}

# If operating in an On-Prem environment, configure the AdminAddress.
if ($AdminAddress) { $newAcctIdentityPoolParameters['AdminAddress'] = $AdminAddress }

# Create a Provisoning Scheme
$newAcctIdentityPoolResult = & New-AcctIdentityPool @newAcctIdentityPoolParameters
$newAcctIdentityPoolResult

###################################
# Step 2: Create New ADAccount(s) #
###################################
Write-Output "Step 2: Create New ADAccount(s)."

# Build the AD User Name
$adUserName = "$Domain\$UserName"

# Build the secure password
$SecurePasswordInput = Read-Host $"Please enter the Active Directory password for the user $UserName" -AsSecureString
$EncryptedPasswordInput = $SecurePasswordInput | ConvertFrom-SecureString
$securedPassword = ConvertTo-SecureString -String $EncryptedPasswordInput

# Configure the common parameters for New-AcctIdentityPool.
$newAcctADAccountParameters = @{
    IdentityPoolUid = $newAcctIdentityPoolResult.IdentityPoolUid
    ADUserName      = $adUserName
    ADPassword      = $securedPassword
    Count           = $Count
}

# If operating in an On-Prem environment, configure the AdminAddress.
if ($AdminAddress) { $newAcctADAccountParameters['AdminAddress'] = $AdminAddress }

# Create a Provisoning Scheme
$newAcctADAccountResult = & New-AcctADAccount @newAcctADAccountParameters
$newAcctADAccountResult

########################################
# Step 3: Create a Provisioning Scheme #
########################################
Write-Output "Step 3: Create a Provisioning Scheme."

# Create a Snapshot if a VM is selected as Master Image
if ($MasterImage -like "*.vm") {
    $MasterImage = New-HypVMSnapshot -LiteralPath $MasterImage -SnapshotName "Citrix_XD_$ProvisioningSchemeName"
}

# Configure a predictive hint for the number of initial VMs that will be added to the MCS catalog when the scheme is successfully created
$initialBatchSizeHint = 1

# Read the Network Mappings of the Master Image
$networkObject = (Get-HypConfigurationObjectForItem -LiteralPath $MasterImage).NetworkMappings

# Build the NetworkMapping for New-ProvScheme
$networkMapping = @{}
foreach ($network in $networkObject) {
    $networkMapping[$($network.DeviceId)] = $($network.Network.NetworkPath)
}

# Configure CPU Count and Memory of the VMs
$vmCpuCount = (Get-HypConfigurationObjectForItem -LiteralPath $MasterImage).CpuCount
$vmMemoryMB = (Get-HypConfigurationObjectForItem -LiteralPath $MasterImage).MemoryMB

# Configure the common parameters for New-ProvScheme.
$newProvSchemeParameters = @{
    ProvisioningSchemeName  = $ProvisioningSchemeName
    HostingUnitName         = $HostingUnitName
    IdentityPoolName        = $identityPoolName
    ProvisioningSchemeType  = $ProvisioningType
    MasterImageVM           = $MasterImage
    CustomProperties        = $CustomProperties
    NetworkMapping          = $networkMapping
    VMCpuCount              = $vmCpuCount
    VMMemoryMB              = $vmMemoryMB
    InitialBatchSizeHint    = $initialBatchSizeHint
    Scope                   = $Scope
    CleanOnBoot             = $CleanOnBoot
}

# If UseFullDiskCloneProvisioning is specified, configure the UseFullDiskCloneProvisioning.
if ($UseFullDiskCloneProvisioning) { $newProvSchemeParameters['UseFullDiskCloneProvisioning'] = $UseFullDiskCloneProvisioning }

# If UseWriteBackCache is specified, configure the UseWriteBackCache.
if ($UseWriteBackCache) {
    $newProvSchemeParameters['UseWriteBackCache'] = $UseWriteBackCache
    $newProvSchemeParameters['WriteBackCacheDiskSize'] = $WriteBackCacheDiskSize
    $newProvSchemeParameters['WriteBackCacheMemorySize'] = $WriteBackCacheMemorySize
    $newProvSchemeParameters['WriteBackCacheDriveLetter'] = $WriteBackCacheDriveLetter
}

# If operating in an On-Prem environment, configure the AdminAddress.
if ($AdminAddress) { $newProvSchemeParameters['AdminAddress'] = $AdminAddress }

# Create a Provisoning Scheme
$newProvSchemeResult = & New-ProvScheme @newProvSchemeParameters
$newProvSchemeResult

# Configure the Controller Addresses.
if ($AdminAddress) {
    # OnPrem DDC requires DDC machine addresses as the controller addresses.
    $controllerAddresses = (Get-ConfigZone -Name "Primary").ControllerNames | ForEach-Object { "$_.$Domain" }
} else {
    # Cloud DDC requires connector addresses as the controller addresses.
    $controllerAddresses = Get-ConfigEdgeServer -ZoneUid $ZoneUid | ForEach-Object { $_.MachineAddress }
}

# OnPrem version 2402 or latest cloud release does not require the cmdlet below.
# Any other CR reease or LTSR require it.
Add-ProvSchemeControllerAddress -ControllerAddress $controllerAddresses -ProvisioningSchemeName $ProvisioningSchemeName

################################
# Step 4: Create New ProvVM(s) #
################################
Write-Output "Step 4: Create New ProvVM(s)."

# Get the new ADAccounts for new ProvVMs.
$adAccountNames = @($newAcctADAccountResult.SuccessfulAccounts | Select-Object -ExpandProperty ADAccountName)

# Configure the common parameters for New-ProvVM.
$newProvVMParameters = @{
    ProvisioningSchemeName  = $newProvSchemeResult.ProvisioningSchemeName
    ADAccountName           = $adAccountNames
}

# If operating in an On-Prem environment, configure the AdminAddress.
if ($AdminAddress) { $newProvVMParameters['AdminAddress'] = $AdminAddress }

# Create new ProvVMs
$newProvVmResult = & New-ProvVM @newProvVMParameters
$newProvVmResult

# Lock the new ProvVMs
$newProvVMIds = @($newProvVmResult.CreatedVirtualMachines | Select-Object VMId)
Lock-ProvVM -ProvisioningSchemeName $ProvisioningSchemeName -Tag "Brokered" -VMID $newProvVMIds


###################################
# Step 5: Create a Broker Catalog #
###################################
Write-Output "Step 5: Create a Broker Catalog."

# Configure the common parameters for New-ProvVM.
$newBrokerCatalogParameters = @{
    Name                = $ProvisioningSchemeName
    ProvisioningType    = $ProvisioningType
    SessionSupport      = $SessionSupport
    AllocationType      = $AllocationType
    PersistUserChanges  = $PersistUserChanges
    Scope               = $Scope
    ZoneUid             = $ZoneUid
}

# If operating in an On-Prem environment, configure the AdminAddress.
if ($AdminAddress) { $newBrokerCatalogParameters['AdminAddress'] = $AdminAddress }

# Create new ProvVMs
$newBrokerCatalogResult = & New-BrokerCatalog @newBrokerCatalogParameters
$newBrokerCatalogResult

# Set Broker Cataog Metadata
$brokerCatalogMetadataName = "Citrix_DesktopStudio_IdentityPoolUid"
Set-BrokerCatalogMetadata -CatalogId $newBrokerCatalogResult.Uid -Name $brokerCatalogMetadataName -Value $newAcctIdentityPoolResult.IdentityPoolUid

# Update the Broker Catalog with the new Provisioning Scheme ID.
Set-BrokerCatalog -Name $newProvSchemeResult.ProvisioningSchemeName -ProvisioningSchemeId $newProvSchemeResult.ProvisioningSchemeUid


####################################
# Step 6: Create Broker Machine(s) #
####################################
Write-Output "Step 6: Create Broker Machine(s)."

# Get the broker catalog
$brokerCatalog = Get-BrokerCatalog -CatalogName $ProvisioningSchemeName

# Get the SIDs of the new ProvVMs
$newProvVMSids = @($newProvVmResult.CreatedVirtualMachines | Select-Object ADAccountSid)


# Configure the common parameters for New-ProvVM.
$newBrokerMachineParameters = @{
    CatalogUid = $brokerCatalog.Uid
}

# If operating in an On-Prem environment, configure the AdminAddress.
if ($AdminAddress) { $newBrokerMachineParameters['AdminAddress'] = $AdminAddress }

# Create Broker Machines for the new ProvVMs
$newProvVMSids | ForEach-Object { New-BrokerMachine @newBrokerMachineParameters -MachineName $_.ADAccountSid }


##############################
# Step 7: Remove ProvTask(s) #
##############################
Write-Output "Step 7: Remove ProvTask(s)."

# Delete completed tasks creating Provisioning Scheme and ProvVMs
Remove-ProvTask -TaskId $newProvSchemeResult.TaskId | Out-Null
Remove-ProvTask -TaskId $newProvVmResult.TaskId | Out-Null
