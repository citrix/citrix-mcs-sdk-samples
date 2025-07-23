<#
.SYNOPSIS
    Detects and converts MCS-provisioned VMs using unmanaged disks to managed disks. Note: This script is not applicable for power-managed-only VMs (i.e. non-MCS-provisioned)

.DESCRIPTION
    This script detects MCS Provisioning Schemes (optionally filtered by name) where VMs are using unmanaged disks (or VHDs).
    It identifies both legacy VMs (which always use unmanaged disks) and non-legacy VMs
    For each affected Provisioning Scheme, it updates the configuration to use managed disks.
    Optionally, the script can also initiate a restart for the impacted VMs.
	The original version of this script is compatible with Citrix Virtual Apps and Desktops 7 2507 Long Term Service Release (LTSR).

.PARAMETER ProvisioningSchemeName
    (Optional) Specify a single Provisioning Scheme to check for unmanaged disks. Otherwise, all Provisioning Scheme are considered.

.PARAMETER Restart
    (Switch) If specified, the script will trigger a restart for all unmanaged disk VMs. This will apply the update/conversion immediately.
.EXAMPLE
    .\DetectAndConvertUnmanagedDisks.ps1
    .\DetectAndConvertUnmanagedDisks.ps1 -ProvisioningSchemeName "DemoProvScheme" -Restart
#>

# /*************************************************************************
# * Copyright © 2025. Cloud Software Group, Inc. All Rights Reserved.
# * This file is subject to the license terms contained
# * in the license file that is distributed with this file.
# *************************************************************************/

param(
    [string]$ProvisioningSchemeName,
    [switch]$Restart
)

# Add Citrix snap-ins
Add-PSSnapin -Name "Citrix.Host.Admin.V2","Citrix.MachineCreation.Admin.V2"

#####################################################
# Step 1: For each VM in each ProvScheme, check if it should be converted #
#####################################################

# Get ProvScheme(s)
if ($ProvisioningSchemeName) {
    $provSchemes = Get-ProvScheme -ProvisioningSchemeName $ProvisioningSchemeName
} else {
    $provSchemes = Get-ProvScheme
}

$vmsToConvert = @()

foreach ($provScheme in $provSchemes) {
    # Only consider Azure ProvSchemes
	$hostingUnitName = $provScheme.HostingUnitName
    $hostingUnit = Get-Item -Path "XDHyp:\HostingUnits\$hostingUnitName"
    if ($hostingUnit.HypervisorConnection.PluginId -ine "AzureRmFactory") { continue }

    $connectionName = $hostingUnit.HypervisorConnection.HypervisorConnectionName

    # Fetch all the VMs for the ProvSchemes and determine if they use unmanaged disks. If so, add them to $vmsToConvert
    $vms = Get-ProvVM -ProvisioningSchemeName $provScheme.ProvisioningSchemeName
    foreach ($vm in $vms) {
		$customVmData = $vm.CustomVmData
        $isLegacyVM = [string]::IsNullOrEmpty($customVmData)

		if ($isLegacyVM) {
			# Legacy VMs always use unmanaged disks
			$isUsingUnmanagedDisks = $true
		}
		else {
			$customVmDataJSON = $customVmData | ConvertFrom-Json
			$isUsingUnmanagedDisks = $customVmDataJSON.PSObject.Properties['IsUsingManagedDisks'] -and
            -not $customVmDataJSON.IsUsingManagedDisks
		}

        if ($isUsingUnmanagedDisks) {
            # Construct the Broker MachineName from the ProvVM
			$fullDomain = $vm.Domain
			$splitDomain = $fullDomain -split "\."
			if ($splitDomain.Length -ne 2) {
				Write-Warning "Domain name '$fullDomain' for VM '$($vm.VMName)' is not in the expected format. Skipping..."
				continue
			}

            $domain = $splitDomain[0]
			$brokerMachineName = "$domain\$($vm.VMName)"

			# Store the VM info in an object so we can access it later
            $vmsToConvert += [PSCustomObject]@{
                ProvScheme = $provScheme.ProvisioningSchemeName
                VMName = $vm.VMName
                MachineName = $brokerMachineName
                IsLegacy = $isLegacyVM
                HypervisorConnectionName = $connectionName
            }
        }
    }
}

#####################################################
# Step 2: Display VMs to be converted & prompt user to confirm #
#####################################################
if (-not $vmsToConvert) {
    Write-Output "No unmanaged disk VMs found."
    return
}

Write-Output "VMs with unmanaged disks were identified:"
$vmsToConvert | Format-Table HypervisorConnectionName, ProvScheme, VMName, IsLegacy -AutoSize

$userInput = Read-Host "Would you like to convert these VMs and their provisioning schemes? (Y/N)"
if ($userInput -notin @("Y", "y")) {
    Write-Output "Disks will not be converted. Ending operation..."
    return
}

#####################################################
# Step 3: For each ProvScheme, update ProvScheme properties     #
# (UseManagedDisks for non-legacy, DeploymentSchema for legacy) #
#####################################################
$provSchemesToUpdate = $vmsToConvert | Group-Object ProvScheme

foreach ($provSchemeEntry in $provSchemesToUpdate) {
    $provSchemeName = $provSchemeEntry.Name
    $provSchemeVMsToConvert = $provSchemeEntry.Group
    $hasLegacyVMs = $provSchemeVMsToConvert | Where-Object { $_.IsLegacy }

    # Choose custom properties based on if the ProvScheme has legacy VMs or not
    $customProperties = if ($hasLegacyVMs) {
@"
<CustomProperties xmlns="http://schemas.citrix.com/2014/xd/machinecreation" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">
<Property xsi:type="StringProperty" Name="DeploymentSchema" Value="1.1" />
</CustomProperties>
"@
    } else {
@"
<CustomProperties xmlns="http://schemas.citrix.com/2014/xd/machinecreation" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">
<Property xsi:type="StringProperty" Name="UseManagedDisks" Value="true" />
</CustomProperties>
"@
    }

    #####################################################
    # Step 4: Update the ProvScheme and schedule update via Set-ProvVmUpdateTimeWindow #
    #####################################################
    Write-Output "Updating ProvScheme with name '$provSchemeName'..."
    Set-ProvScheme -ProvisioningSchemeName $provSchemeName -CustomProperties $customProperties
    Set-ProvVmUpdateTimeWindow -ProvisioningSchemeName $provSchemeName

    #####################################################
    # Step 5: Restart the VMs, if requested #
    #####################################################
    if ($Restart) {
		if ($provSchemeVMsToConvert.Count -eq 0) {
			Write-Output "No VMs to restart for ProvScheme '$provSchemeName'."
		}
		else {
			$provSchemeVMsToConvert | ForEach-Object {
				$machineName = $_.MachineName
                $powerAction = New-BrokerHostingPowerAction -Action Restart -MachineName $machineName
				$powerActionUid = $powerAction.Uid
				Write-Output "PowerAction with ActionUid '$powerActionUid' issued for $machineName"
            }
		}
    } else {
        Write-Output "Skipping restart for ProvScheme '$provSchemeName'."
    }
}