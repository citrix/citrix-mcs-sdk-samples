<#
.SYNOPSIS
    Creating a Machine Catalog.
.DESCRIPTION
    `Create-MachineCatalog.ps1` creates a Machine Catalog.
    The original version of this script is compatible with Citrix Virtual Apps and Desktops 7 2402 Long Term Service Release (LTSR).
.INPUTS
    - ZoneUid: The UID that corresponds to the Zone in which these AD accounts will be created
    - NamingScheme: Template for AD account names
    - NamingSchemeType: Naming scheme type for the catalog
    - AdminAddress: The primary DDC address
    - WorkGroupMachine: Indicates whether the accounts created should be part of a workgroup rather than a domain
    - Domain: The AD domain name for the pool. Specify this in FQDN format; for example, MyDomain.local
    - Scope: The administration scopes to be applied
    - ProvisioningSchemeName: Name of the new provisioning scheme
    - ProvisioningSchemeType: The Provisioning Scheme Type
    - HostingUnitName: Name of the hosting unit used
    - NetworkMapping: Specifies how the attached NICs are mapped to networks
    - CustomProperties: Used to provide Container Path(as hypervisor path), vCPU count, Memory, and CPUCores(Cores per CPU) values
    - MasterImageVM: Path to VM snapshot or template
    - VMCpuCount: Number of vCPUs
    - VMMemoryMB: VM memory in MB
    - CleanOnBoot: Reset VM's to their initial state on each power on
    - RunAsynchronously: Run command asynchronously, returns ProvTask ID
    - PersistUserChanges: User data persistence method
    - Count: Number of VMs to create (default is 1)
    - UserName: Username for AD account
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
    $customProperties = @"
        <CustomProperties xmlns="http://schemas.citrix.com/2014/xd/machinecreation">
            <StringProperty Name="ContainerPath" Value="/myContainer.storage"/>
            <StringProperty Name="vCPU" Value="3"/>
            <StringProperty Name="RAM" Value="6144"/>
            <StringProperty Name="CPUCores" Value="3"/>    
        </CustomProperties>
    "@
    .\Add-MachineCatalog.ps1 `
        -ProvisioningSchemeName "MyCatalog" `
        -ProvisioningSchemeType MCS
        -HostingUnitName "Myresource" `
        -Domain "MyDomain.local" `
        -UserName "MyUserName" `
        -ZoneUid "00000000-0000-0000-0000-000000000000" `
        -NetworkMapping @{"0"="XDHyp:\HostingUnits\myHostingUnit\myNetwork.network"} `
        -AdminAddress "MyDDC.MyDomain.local" `
        -NamingScheme "MyVM###" `
        -NamingSchemeType "Numeric" `
        -ProvisioningType "MCS" `
        -SessionSupport "Single" `
        -AllocationType "Random" `
        -PersistUserChanges "Discard" `
        -CleanOnBoot $True `
        -VMCpuCount 3 `
        -VMMemoryMB 6144 `
        -MasterImageVM "XDHyp:\HostingUnits\myHostingUnit\myMasterImage.template" `
        -CustomProperties $customProperties `
        -Scope @() `
        -Count 2
#>

# /*************************************************************************
# * Copyright © 2024. Cloud Software Group, Inc. All Rights Reserved.
# * This file is subject to the license terms contained
# * in the license file that is distributed with this file.
# *************************************************************************/

param(
    [Parameter(mandatory=$true)]
    [guid] $ZoneUid,
    [Parameter(mandatory=$true)]
    [string] $NamingScheme,
    [Parameter(mandatory=$true)]
    [string] $NamingSchemeType,
    [Parameter(mandatory=$true)]
    [string] $UserName,
    [Parameter(mandatory=$true)]
    [string] $ProvisioningSchemeName,
    [Parameter(mandatory=$true)]
    [string] $ProvisioningSchemeType,
    [Parameter(mandatory=$true)]
    [string] $HostingUnitName,
    [Parameter(mandatory=$true)]
    [hashtable] $NetworkMapping,
    [Parameter(mandatory=$true)]
    [string] $CustomProperties,
    [Parameter(mandatory=$true)]
    [string] $MasterImageVM,
    [Parameter(mandatory=$true)]
    [int] $VMCpuCount,
    [Parameter(mandatory=$true)]
    [int] $VMMemoryMB,
    [Parameter(mandatory=$true)]
    [string] $PersistUserChanges,
    [Parameter(mandatory=$true)]
    [string] $AllocationType,
    [Parameter(mandatory=$true)]
    [string] $SessionSupport,
    [string] $AdminAddress = $null,
    [switch] $WorkGroupMachine = $false,
    [string] $Domain,
    [string[]] $Scope = @(),
    [string] $InitialBatchSizeHint = 1,
    [switch] $CleanOnBoot = $false,
    [switch] $RunAsynchronously = $false,
    [int] $Count = 1
)

# Enable Citrix PowerShell Cmdlets
Add-PSSnapin -Name "Citrix.Host.Admin.V2","Citrix.MachineCreation.Admin.V2"

Write-Verbose "Creating a New Identity Pool."

# Configure the common parameters for New-AcctIdentityPool.
$idpParams = @{
    IdentityPoolName    = $ProvisioningSchemeName
    ZoneUid             = $ZoneUid
    NamingScheme        = $NamingScheme
    NamingSchemeType    = $NamingSchemeType
    Scope               = $Scope
    AllowUnicode        = $true
}

# Add conditional parameters
if ($WorkGroupMachine) {
    $idpParams['WorkGroupMachine'] = $WorkGroupMachine
}else {
    if(!$PSBoundParameters.ContainsKey("Domain")){
        Write-Error "Either provide a Domain, or use the WorkGroupMachine flag"
        exit
    }
    $idpParams['Domain'] = $Domain
}
if ($AdminAddress) { $idpParams['AdminAddress'] = $AdminAddress }

& New-AcctIdentityPool @idpParams

Write-Verbose "Create a Provisioning Scheme."

$newProvSchemeParameters = @{
    ProvisioningSchemeName  = $ProvisioningSchemeName
    ProvisioningSchemeType  = $ProvisioningSchemeType
    HostingUnitName         = $HostingUnitName
    IdentityPoolName        = $ProvisioningSchemeName
    NetworkMapping          = $NetworkMapping
    CustomProperties        = $CustomProperties
    MasterImageVM           = $MasterImageVM
    InitialBatchSizeHint    = $InitialBatchSizeHint
    CleanOnBoot             = $CleanOnBoot
    Scope                   = $Scope
    RunAsynchronously       = $RunAsynchronously
    VMCpuCount              = $VMCpuCount
    VMMemoryMB              = $VMMemoryMB
}

# Create a Provisoning Scheme
try{
    $newProvSchemeResult = & New-ProvScheme @newProvSchemeParameters
} catch {
    Write-Error $_
    exit
}


Write-Verbose "Create New ProvVM(s)."

$secureUserInput = Read-Host 'Enter your AD account password' -AsSecureString
$encryptedInput = ConvertFrom-SecureString -SecureString $secureUserInput
$SecurePassword = ConvertTo-SecureString -String $encryptedInput

Write-Verbose "Creating AD Accounts for VMs"
try{
    $createdAccounts = New-AcctADAccount -ADUserName $UserName -ADPassword $SecurePassword -Count $Count -IdentityPoolName $ProvisioningSchemeName
}
catch{
    Write-Error $_
    exit
}
if ($createdAccounts.FailedAccounts.Count -gt 0)
{
    $failedAccounts = $createdAccounts.FailedAccounts.Count
    $terminatingError = $createdAccounts.FailedAccounts.DiagnosticInformation
    Write-Error "$($failedAccounts) AD accounts failed to be created with the error: $($terminatingError)"
    exit
}

Write-Verbose "Creating VMs"
try{
    $createdProvVms = New-ProvVM -ProvisioningSchemeName $provisioningSchemeName -ADAccountName $createdAccounts.SuccessfulAccounts.ADAccountName
}
catch{
    Write-Error $_
    exit
}

if($createdProvVms.VirtualMachinesCreatedCount -ne $Count)
{
    $failedProvVms = $createdProvVms.VirtualMachinesCreationFailedCount
    throw "$($failedProvVms) VMs failed to be created"
}

Write-Verbose "Create a Broker Catalog."

# Configure the common parameters for new Broker Catalog
$newBrokerCatalogParameters = @{
    Name                = $ProvisioningSchemeName
    ProvisioningType    = $ProvisioningSchemeType
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

# Update the Broker Catalog with the new Provisioning Scheme ID.
Set-BrokerCatalog -Name $newProvSchemeResult.ProvisioningSchemeName -ProvisioningSchemeId $newProvSchemeResult.ProvisioningSchemeUid

try{
    Write-Verbose "Get Catalog"
    $brokerCatalog = Get-BrokerCatalog -Name $ProvisioningSchemeName -ErrorAction Stop
    Write-Verbose "Get AD Account SIDs for VMs"
    $CreatedProvVmSids = @($createdProvVms.CreatedVirtualMachines | Select-Object ADAccountSid)
    Write-Verbose "Creating Broker Machines"
    $CreatedProvVmSids | ForEach-Object {
        New-BrokerMachine -CatalogUid $brokerCatalog[0].Uid -MachineName $_.ADAccountSid
    }
}
catch{
    Write-Error $_
    exit
}