<#
.SYNOPSIS
    Add a VM to a Provisioning Scheme
.DESCRIPTION
    Create-ProvVM.ps1 adds a new VM to a Provisioning Scheme
    The original version of this script is compatible with Citrix Virtual Apps and Desktops 7 2402 Long Term Service Release (LTSR).
.INPUTS
    1. ProvisioningSchemeName: Name of Provisioning Scheme to add VMs to
    2. Count: Number of VMs to create (default is 1)
    3. UserName: Username for AD account
    4. IdentityPoolName: Name of Identity Pool associated with the catalog
    5. CatalogName: Name of Broker Catalog
.EXAMPLE
    # Create 1 new VM
    .\Create-ProvVM.ps1 `
        -ProvisioningSchemeName "MyCatalog" `
        -UserName "myUserName"
        -IdentityPoolName "myIdentityPool"
        -CatalogName "myBrokerCatalog"

    # Create 5 new VMs
    .\Create-ProvVM.ps1 `
        -ProvisioningSchemeName "MyCatalog" `
        -UserName "myUserName"
        -IdentityPoolName "myIdentityPool"
        -CatalogName "myBrokerCatalog"
        -Count 5
#>

# /*************************************************************************
# * Copyright © 2024. Cloud Software Group, Inc. All Rights Reserved.
# * This file is subject to the license terms contained
# * in the license file that is distributed with this file.
# *************************************************************************/

# Add Citrix snap-ins
Add-PSSnapin -Name "Citrix.Host.Admin.V2","Citrix.MachineCreation.Admin.V2","Citrix.Broker.Admin.V2","Citrix.ADIdentity.Admin.V2"

param(
    [Parameter(mandatory=$true)]
    [string] $ProvisioningSchemeName,
    [int] $Count = 1,
    [Parameter(mandatory=$true)]
    [string] $UserName,
    [Parameter(mandatory=$true)]
    [string] $IdentityPoolName,
    [Parameter(mandatory=$true)]
    [string] $CatalogName
)

$secureUserInput = Read-Host 'Enter your AD account password:' -AsSecureString
$encryptedInput = ConvertFrom-SecureString -SecureString $secureUserInput
$SecurePassword = ConvertTo-SecureString -String $encryptedInput

Write-Verbose "Creating AD Accounts"
try{
    $createdAccounts = New-AcctADAccount -ADUserName $UserName -ADPassword $SecurePassword -Count $Count -IdentityPoolName $IdentityPoolName
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

try{
    Write-Verbose "Get Catalog"
    $brokerCatalog = Get-BrokerCatalog -Name $catalogName -ErrorAction Stop
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