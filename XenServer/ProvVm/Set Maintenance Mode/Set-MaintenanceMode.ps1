<#
.SYNOPSIS
    Set the maintenance of a machine.
.DESCRIPTION
    The `Set-MaintenanceMode.ps1` script is designed to set the maintenance of a machine.
    The original version of this script is compatible with Citrix Virtual Apps and Desktops 7 2203 Long Term Service Release (LTSR).
.INPUTS
    1. MachineName: The name of the machine to set the maintenance mode.
    2. MaintenanceMode: Sets whether the machine is in maintenance mode or not. A machine in maintenance mode is not available for new sessions, and for managed machines all automatic power management is disabled.
    3. AdminAddress: The primary DDC address.
.OUTPUTS
    N/A
.NOTES
    Version      : 1.0.0
    Author       : Citrix Systems, Inc.
.EXAMPLE
    # Turn on the maintenance mode for the machine named "MyMachine" in the "MyDomain" domain
    .\Set-MaintenanceMode.ps1 -MachineName "MyDomain\MyMachine" -MaintenanceMode $True -AdminAddress "MyDDC.MyDomain.local"

    # Turn off the maintenance mode for the machine named "MyMachine" in the "MyDomain" domain
    .\Set-MaintenanceMode.ps1 -MachineName "MyDomain\MyMachine" -MaintenanceMode $False -AdminAddress "MyDDC.MyDomain.local"
#>

# /*************************************************************************
# * Copyright © 2024. Cloud Software Group, Inc. All Rights Reserved.
# * This file is subject to the license terms contained
# * in the license file that is distributed with this file.
# *************************************************************************/

param(
    [string] $MachineName,
    [bool] $MaintenanceMode = $false,
    [string] $AdminAddress = $null
)

# Enable Citrix PowerShell Cmdlets
Add-PSSnapin citrix*

####################################
# Step 1: Set the Maintenance Mode #
####################################
Write-Output "Set the Maintenance Mode."

# Get the Broker Machine Object
$brokerMachine= Get-BrokerMachine -MachineName $MachineName

# Configure the common parameters for Set-BrokerMachineMaintenanceMode.
$setBrokerMachineMaintenanceModeParameters = @{
    InputObject = @($brokerMachine.Uid)
    MaintenanceMode = $MaintenanceMode
}

# If operating in an On-Prem environment, configure the AdminAddress.
if ($AdminAddress) { $setBrokerMachineMaintenanceModeParameters['AdminAddress'] = $AdminAddress }

# Set the Maintenance Mode
& Set-BrokerMachineMaintenanceMode @setBrokerMachineMaintenanceModeParameters
