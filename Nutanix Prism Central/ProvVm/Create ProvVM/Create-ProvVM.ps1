<#
.SYNOPSIS
    Add a VM to a Provisioning Scheme
.DESCRIPTION
    Create-ProvVM.ps1 adds a new VM to a Provisioning Scheme
    The original version of this script is compatible with  Citrix DaaS July 2025 Release.
.INPUTS
    1. ProvisioningSchemeName: Name of Provisioning Scheme to add VMs to
    2. UserName:               OPTIONAL: Username for creating AD account. Omit if WORKGROUp Identity Pool
    3. IdentityPoolName:       OPTIONAL: Name of Identity Pool associated with the catalog (default is ProvisioningSchemeName)
    4. CatalogName:            OPTIONAL: Name of Broker Catalog  (default is ProvisioningSchemeName)
    5. Count:                  OPTIONAL: Number of VMs to create (default is 1)
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
# * Copyright © 2025. Cloud Software Group, Inc. All Rights Reserved.
# * This file is subject to the license terms contained
# * in the license file that is distributed with this file.
# *************************************************************************/

param(
    [Parameter(mandatory=$true)]  [string] $ProvisioningSchemeName,
    [Parameter(mandatory=$false)] [string] $UserName,
    [Parameter(mandatory=$false)] [string] $IdentityPoolName=$ProvisioningSchemeName,
    [Parameter(mandatory=$false)] [string] $CatalogName=$ProvisioningSchemeName,
    [Parameter(mandatory=$false)] [int]    $Count = 1
)

# Add Citrix snap-ins
Add-PSSnapin -Name "Citrix.Host.Admin.V2","Citrix.MachineCreation.Admin.V2","Citrix.Broker.Admin.V2","Citrix.ADIdentity.Admin.V2"

Write-Output "Creating $($Count) machines in Catalog $($CatalogName) ProvisioninScheme $($ProvisioningSchemeName) using IdentityPool $($IdentityPoolName)"


Write-Verbose "Creating AD Accounts"
try
{
    if ($UserName)
    {
        $secureUserInput = Read-Host "Enter your AD account password for $($UserName)" -AsSecureString
        $encryptedInput = ConvertFrom-SecureString -SecureString $secureUserInput
        $SecurePassword = ConvertTo-SecureString -String $encryptedInput
        $createdAccounts = New-AcctADAccount -ADUserName $UserName -ADPassword $SecurePassword -Count $Count -IdentityPoolName $IdentityPoolName
    }
    else
    {
        Write-Output "Assuming Workgroup IdentityPool"
        $createdAccounts = New-AcctADAccount -Count $Count -IdentityPoolName $IdentityPoolName
    }
}
catch
{
    Write-Error "New-AcctADAccount: $($_)"
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
try
{
    $createdProvVms = New-ProvVM -ProvisioningSchemeName $provisioningSchemeName -ADAccountName $createdAccounts.SuccessfulAccounts.ADAccountName
}
catch
{
    Write-Error "New-ProvVM: $($_)"
    exit
}

if($createdProvVms.VirtualMachinesCreatedCount -ne $Count)
{
    $failedProvVms = $createdProvVms.VirtualMachinesCreationFailedCount
    throw "$($failedProvVms) VMs failed to be created"
}

try
{
    Write-Verbose "Get Catalog"
    $brokerCatalog = Get-BrokerCatalog -Name $catalogName -ErrorAction Stop
    Write-Verbose "Get AD Account SIDs for VMs"
    $CreatedProvVmSids = @($createdProvVms.CreatedVirtualMachines | Select-Object ADAccountSid)
    Write-Verbose "Creating Broker Machines"
    $CreatedProvVmSids | ForEach-Object {
        New-BrokerMachine -CatalogUid $brokerCatalog[0].Uid -MachineName $_.ADAccountSid
    }
}
catch
{
    Write-Error "New-BrokerMachine: $($_)"
    exit
}
