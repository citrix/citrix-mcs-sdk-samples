<#
.SYNOPSIS
    Create a power action for a machine.
.DESCRIPTION
    The `PowerAction.ps1` script is designed to create a power action for a machine.
    The original version of this script is compatible with Citrix Virtual Apps and Desktops 7 2203 Long Term Service Release (LTSR).
.INPUTS
    1. Action: Specifies the power state change action that is to be performed on the specified machine. Valid values are:
        - TurnOn: Power on a machine.
        - TurnOff: Force shutdown a machine.
        - ShutDown: Shutdown a machine.
        - Reset: Force to reboot a machine.
        - Restart: Reboot a machine.
        - Suspend: Suspend a machine.
        - Resume: Resume a machine
    2. MachineName: Specifies the machine that the action is to be performed on.
    3. AdminAddress: The primary DDC address.
.OUTPUTS
    N/A
.NOTES
    Version      : 1.0.0
    Author       : Citrix Systems, Inc.
.EXAMPLE
    # Power on the machine named "MyMachine"
    .\PowerAction.ps1 -Action "TurnOn"  -MachineName "MyMachine" -AdminAddress "MyDDC.MyDomain.local"

    # Force shutdown the machine named "MyMachine"
    .\PowerAction.ps1 -Action "TurnOff"  -MachineName "MyMachine" -AdminAddress "MyDDC.MyDomain.local"

    # Shutdown the machine named "MyMachine"
    .\PowerAction.ps1 -Action "ShutDown"  -MachineName "MyMachine" -AdminAddress "MyDDC.MyDomain.local"

    # Force to reboot the machine named "MyMachine"
    .\PowerAction.ps1 -Action "Reset"  -MachineName "MyMachine" -AdminAddress "MyDDC.MyDomain.local"

    # Reboot the machine named "MyMachine"
    .\PowerAction.ps1 -Action "Restart"  -MachineName "MyMachine" -AdminAddress "MyDDC.MyDomain.local"

    # Suspend the machine named "MyMachine"
    .\PowerAction.ps1 -Action "Suspend"  -MachineName "MyMachine" -AdminAddress "MyDDC.MyDomain.local"

    # Resume the machine named "MyMachine"
    .\PowerAction.ps1 -Action "Resume"  -MachineName "MyMachine" -AdminAddress "MyDDC.MyDomain.local"
#>

# /*************************************************************************
# * Copyright © 2024. Cloud Software Group, Inc. All Rights Reserved.
# * This file is subject to the license terms contained
# * in the license file that is distributed with this file.
# *************************************************************************/

param(
    [string] $MachineName,
    [string] $Action,
    [guid] $AdminAddress
)

# Enable Citrix PowerShell Cmdlets
Add-PSSnapin citrix*

#########################################################
# Step 1: Create a New Action in the Power Action Queue #
#########################################################
Write-Output "Step 1: Power On Machine."

# Configure the common parameters for New-BrokerHostingPowerAction.
$newBrokerHostingPowerActionParameters = @{
    Action = $Action
    MachineName = $MachineName
}

# If operating in an On-Prem environment, configure the AdminAddress.
if ($AdminAddress) { $newBrokerHostingPowerActionParameters['AdminAddress'] = $AdminAddress }

# Create a New Action in the Power Action Queue
& New-BrokerHostingPowerAction @newBrokerHostingPowerActionParameters
