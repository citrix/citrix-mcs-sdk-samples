<#
.SYNOPSIS
    Creating a Machine Catalog.
.DESCRIPTION
    `Create-MachineCatalog.ps1` creates a Machine Catalog.
    The original version of this script is compatible with  Citrix DaaS July 2025 Release.
.INPUTS
    - ZoneUid:                The UID that corresponds to the Zone in which these AD accounts will be created
    - NamingScheme:           Template for AD account names
    - NamingSchemeType:       Naming scheme type for the catalog
    - AdminAddress:           The primary DDC address
    - WorkGroupMachine:       Indicates whether the accounts created should be part of a workgroup rather than a domain
    - Domain:                 The AD domain name for the pool. Specify this in FQDN format; for example, MyDomain.local
    - Scope:                  The administration scopes to be applied
    - ProvisioningSchemeName: Name of the new provisioning scheme
    - ProvisioningSchemeType: The Provisioning Scheme Type
    - HostingUnitName:        Name of the hosting unit used
    - NetworkMapping:         Specifies how the attached NICs are mapped to networks
    - CustomProperties:       Used to provide Container Path(as hypervisor path), vCPU count, Memory, and CPUCores(Cores per CPU) values
    - MasterImageVM:          Path to VM snapshot or template
    - VMCpuCount:             Number of vCPUs
    - VMMemoryMB:             VM memory in MB
    - CleanOnBoot:            Reset VM's to their initial state on each power on
    - RunAsynchronously:      Run command asynchronously, returns ProvTask ID
    - PersistUserChanges:     User data persistence method
    - Count:                  Number of VMs to create (default is 1)
    - UserName:               Username for AD account
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
        <StringProperty Name="ClusterId" Value="00001111-2222-3333-4444-555556666666"/>
        <StringProperty Name="CPUCores" Value="1"/>
    </CustomProperties>
"@

    .\Add-MachineCatalog.ps1 `
        -ProvisioningSchemeName "MyCatalog" `
        -ProvisioningSchemeType MCS `
        -HostingUnitName "myHostingUnit" `
        -Domain "MyDomain.local" `
        -UserName "MyUserName" `
        -ZoneUid "00000000-0000-0000-0000-000000000000" `
        -NetworkMapping @{"0"="XDHyp:\HostingUnits\myHostingUnit\Clusters.folder\cluster01.cluster\Network-A.network"} `
        -AdminAddress "MyDDC.MyDomain.local" `
        -NamingScheme "MyVM###" `
        -NamingSchemeType "Numeric" `
        -SessionSupport "Single" `
        -AllocationType "Random" `
        -PersistUserChanges "Discard" `
        -CleanOnBoot $True `
        -VMCpuCount 3 `
        -VMMemoryMB 6144 `
        -MasterImageVM "XDHyp:\HostingUnits\myHostingUnit\Templates.folder\CitrixVda.template\win2022-vda-2411.templateversion" `
        -CustomProperties $customProperties `
        -Scope @() `
        -Count 2
#>

# /*************************************************************************
# * Copyright © 2025. Cloud Software Group, Inc. All Rights Reserved.
# * This file is subject to the license terms contained
# * in the license file that is distributed with this file.
# *************************************************************************/

param(
    [Parameter(mandatory=$true)]    [guid]      $ZoneUid,
    [Parameter(mandatory=$true)]    [string]    $NamingScheme,
    [Parameter(mandatory=$true)]    [string]    $NamingSchemeType,
    [Parameter(mandatory=$true)]    [string]    $UserName,
    [Parameter(mandatory=$true)]    [string]    $ProvisioningSchemeName,
    [Parameter(mandatory=$true)]    [string]    $ProvisioningSchemeType,
    [Parameter(mandatory=$true)]    [string]    $HostingUnitName,
    [Parameter(mandatory=$true)]    [hashtable] $NetworkMapping,
    [Parameter(mandatory=$true)]    [string]    $CustomProperties,
    [Parameter(mandatory=$true)]    [string]    $MasterImageVM,
    [Parameter(mandatory=$true)]    [int]       $VMCpuCount,
    [Parameter(mandatory=$true)]    [int]       $VMMemoryMB,
    [Parameter(mandatory=$true)]    [string]    $PersistUserChanges,
    [Parameter(mandatory=$true)]    [string]    $AllocationType,
    [Parameter(mandatory=$true)]    [string]    $SessionSupport,
    [Parameter(mandatory=$false)]   [string]    $AdminAddress = $null,
    [Parameter(mandatory=$false)]   [switch]    $WorkGroupMachine = $false,
    [Parameter(mandatory=$false)]   [string]    $Domain,
    [Parameter(mandatory=$false)]   [string[]]  $Scope = @(),
    [Parameter(mandatory=$false)]   [string]    $InitialBatchSizeHint = 1,
    [Parameter(mandatory=$false)]   [switch]    $CleanOnBoot = $false,
    [Parameter(mandatory=$false)]   [switch]    $RunAsynchronously = $false,
    [Parameter(mandatory=$false)]   [int]       $Count = 1
)

# Enable Citrix PowerShell Cmdlets
Add-PSSnapin -Name "Citrix.Host.Admin.V2","Citrix.MachineCreation.Admin.V2"

Write-Output "Creating a New Identity Pool."

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
if ($WorkGroupMachine)
{
    Write-Output "Identity Pool: WorkGroupMachine."
    $idpParams['WorkGroupMachine'] = $WorkGroupMachine
}
else
{
    if (!$PSBoundParameters.ContainsKey("Domain"))
    {
        Write-Error "Either provide a Domain, or use the WorkGroupMachine flag"
        exit
    }
    Write-Output "Identity Pool Domain: $($Domain).get"
    $idpParams['Domain'] = $Domain
}

if ($AdminAddress)
{
     $idpParams['AdminAddress'] = $AdminAddress
}

& New-AcctIdentityPool @idpParams

Write-Output "Create a Provisioning Scheme."

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
try
{
    $newProvSchemeResult = & New-ProvScheme @newProvSchemeParameters
    if ($newProvSchemeResult.TerminatingError)
    {
        Write-Error "Provisioning Scheme creation failed: $($newProvSchemeResult.TaskState) : $($newProvSchemeResult.TerminatingError)"
        exit
    }
}
catch
{
    Write-Error $_
    exit
}


Write-Output "Create New ProvVM(s)."

if ($WorkGroupMachine)
{
    Write-Output "Creating AD Accounts for VMs"
    try
    {
        $createdAccounts = New-AcctADAccount -Count $Count -IdentityPoolName $ProvisioningSchemeName
    }
    catch
    {
        Write-Error $_
        exit
    }
}
else
{
    $secureUserInput = Read-Host 'Enter your AD account password' -AsSecureString
    $encryptedInput = ConvertFrom-SecureString -SecureString $secureUserInput
    $SecurePassword = ConvertTo-SecureString -String $encryptedInput

    Write-Output "Creating AD Accounts for VMs"
    try
    {
        $createdAccounts = New-AcctADAccount -ADUserName $UserName -ADPassword $SecurePassword -Count $Count -IdentityPoolName $ProvisioningSchemeName
    }
    catch
    {
        Write-Error $_
        exit
    }
}

if ($createdAccounts.FailedAccounts.Count -gt 0)
{
    $failedAccounts = $createdAccounts.FailedAccounts.Count
    $terminatingError = $createdAccounts.FailedAccounts.DiagnosticInformation
    Write-Error "$($failedAccounts) AD accounts failed to be created with the error: $($terminatingError)"
    exit
}

Write-Output "Creating VMs"
try
{
    $createdProvVms = New-ProvVM -ProvisioningSchemeName $provisioningSchemeName -ADAccountName $createdAccounts.SuccessfulAccounts.ADAccountName
}
catch
{
    Write-Error $_
    exit
}

if($createdProvVms.VirtualMachinesCreatedCount -ne $Count)
{
    $failedProvVms = $createdProvVms.VirtualMachinesCreationFailedCount
    throw "$($failedProvVms) VMs failed to be created"
}

Write-Output "Create a Broker Catalog."

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
if ($AdminAddress)
{
    $newBrokerCatalogParameters['AdminAddress'] = $AdminAddress
}

# Create new ProvVMs
$newBrokerCatalogResult = & New-BrokerCatalog @newBrokerCatalogParameters
$newBrokerCatalogResult

# Update the Broker Catalog with the new Provisioning Scheme ID.
Set-BrokerCatalog -Name $newProvSchemeResult.ProvisioningSchemeName -ProvisioningSchemeId $newProvSchemeResult.ProvisioningSchemeUid

try
{
    Write-Verbose "Get Catalog"
    $brokerCatalog = Get-BrokerCatalog -Name $ProvisioningSchemeName -ErrorAction Stop
    Write-Verbose "Get AD Account SIDs for VMs"
    $CreatedProvVmSids = @($createdProvVms.CreatedVirtualMachines | Select-Object ADAccountSid)
    Write-Verbose "Creating Broker Machines"
    $CreatedProvVmSids | ForEach-Object {
        New-BrokerMachine -CatalogUid $brokerCatalog[0].Uid -MachineName $_.ADAccountSid
    }
}
catch
{
    Write-Error $_
    exit
}