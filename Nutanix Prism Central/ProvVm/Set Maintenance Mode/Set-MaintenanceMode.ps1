<#
.SYNOPSIS
    Set Maintenance mode for VMs from a Provisioning Scheme
.DESCRIPTION
    `Set-MaintenanceMode.ps1` toggles maintenance mode for VMs in a Provisioning Scheme.
    The original version of this script is compatible with  Citrix DaaS July 2025 Release.
.INPUTS
    1. ProvisioningSchemeName: The name of the provisioning scheme
    2. VMName: Names of the VMs
    3. MaintenanceMode: Value of maintenance mode to set
    4. AdminAddress: Address of the DDC
.EXAMPLE
    .\Set-MaintenanceMode.ps1 -ProvisioningSchemeName "myProvScheme" -VmName "vm-1" -MaintenanceMode $true
#>
# /*************************************************************************
# * Copyright © 2025. Cloud Software Group, Inc. All Rights Reserved.
# * This file is subject to the license terms contained
# * in the license file that is distributed with this file.
# *************************************************************************/

param(
    [Parameter(mandatory=$true)]  [string]   $ProvisioningSchemeName,
    [Parameter(mandatory=$true)]  [string[]] $VmName,
    [Parameter(mandatory=$true)]  [bool]     $MaintenanceMode,
    [Parameter(mandatory=$false)] [string]   $AdminAddress = $null
)

# Enable Citrix PowerShell Cmdlets
Add-PSSnapin -Name "Citrix.Host.Admin.V2","Citrix.MachineCreation.Admin.V2"

Write-Verbose "Getting Broker Machines and setting maintenance mode for each"
# Get the broker machines to remove
$brokerMachines = $VmName | ForEach-Object { Get-BrokerMachine -CatalogName $ProvisioningSchemeName -MachineName $_ }

$brokerMachines | ForEach-Object {
    $MaintenanceModeParams = @{
        InputObject = $_
        MaintenanceMode = $MaintenanceMode
    }
    # If operating in an On-Prem environment, configure the AdminAddress.
    if ($AdminAddress)
    {
        $MaintenanceModeParams['AdminAddress'] = $AdminAddress
    }
    # Remove Broker Machines
    & Set-BrokerMachineMaintenanceMode @MaintenanceModeParams
}