<#
.SYNOPSIS
    Fix boot failure on ESXi 8.0.0 VMs after ESXi 8.0.3 catalog update
    by disabling Secure Boot on all VMs in a given MCS machine catalog.
.DESCRIPTION
    1. Problem:
       VMs originally created on ESXi 8.0.0 only have the Windows UEFI CA 2011 certificate
       in their Secure Boot database. After the ESXi host is upgraded to 8.0.3, an MCS
       catalog update applies a 2023-signed bootloader to these VMs. The VMs fail to boot
       with "No Boot Media" because their Secure Boot DB does not trust the 2023 certificate.

    2. Solution:
       This script disables Secure Boot on all VMs in a machine catalog so that the
       bootloader signature is not checked. This is a quick fix that allows VMs to boot
       regardless of which certificate signed the bootloader.

       Step 1 - Connect to vCenter and resolve the catalog to a list of VMs.
       Step 2 - For each VM, check if it is EFI firmware with Secure Boot enabled.
       Step 3 - Power off the VM (if running and -ForcePowerOff is specified).
       Step 4 - Reconfigure the VM to disable Secure Boot.

    3. Important Notes:
       (1) VMs must be powered off to change Secure Boot settings. Use -ForcePowerOff
           to automatically stop running VMs, or power them off manually beforehand.
       (2) Disabling Secure Boot removes a security layer. Consider using the
           Deploy Certificate script instead if VMs can still boot into Windows.
       (3) For fuller information on the Secure Boot certificate transition, please refer to:
           https://support.microsoft.com/en-us/topic/kb5025885
.NOTES
    Version : 1.0
    Author  : Citrix Systems, Inc.
.EXAMPLE
    # Disable Secure Boot on all VMs in catalog "MyCatalog" (skip powered-on VMs):
    .\Disable-SecureBoot.ps1 -CatalogName "MyCatalog" -VCenterServer "vcenter.domain.local"

    # Disable Secure Boot and force power off running VMs:
    .\Disable-SecureBoot.ps1 -CatalogName "MyCatalog" -VCenterServer "vcenter.domain.local" -ForcePowerOff

    # Specify vCenter credentials explicitly:
    .\Disable-SecureBoot.ps1 -CatalogName "MyCatalog" -VCenterServer "vcenter.domain.local" -VCenterUsername "admin@vsphere.local"
#>

# /*************************************************************************
# * Copyright (c) 2026. Cloud Software Group, Inc. All Rights Reserved.
# * This file is subject to the license terms contained
# * in the license file that is distributed with this file.
# *************************************************************************/

param(
    [Parameter(Mandatory = $true)]
    [string]$CatalogName,
    [Parameter(Mandatory = $true)]
    [string]$VCenterServer,
    [string]$VCenterUsername,
    [switch]$ForcePowerOff
)

# Verify Citrix PowerShell SDK is loaded (snap-in for on-prem DDC, module for Remote PowerShell SDK)
$citrixLoaded = (Get-PSSnapin Citrix.* -ErrorAction SilentlyContinue) -or
                (Get-Module Citrix.MachineCreation.Admin.V2 -ErrorAction SilentlyContinue)
if (-not $citrixLoaded) {
    Write-Host "Citrix PowerShell SDK is not loaded."
    Write-Host "  On-premises: Add-PSSnapin Citrix.*"
    Write-Host "  Citrix Cloud: Import-Module Citrix.MachineCreation.Admin.V2"
    exit 1
}

# Verify VMware PowerCLI module is loaded.
# Install with: Install-Module VMware.PowerCLI -Scope CurrentUser
if (-not (Get-Module VMware.VimAutomation.Core -ErrorAction SilentlyContinue)) {
    Write-Host "VMware PowerCLI module is not loaded."
    Write-Host "  Import-Module VMware.PowerCLI"
    exit 1
}

# Step 1: Connect to vCenter
Write-Host "Connecting to vCenter: $VCenterServer"
try {
    if ($VCenterUsername) {
        $cred = Get-Credential -UserName $VCenterUsername -Message "Enter vCenter password"
        Connect-VIServer -Server $VCenterServer -Credential $cred | Out-Null
    }
    else {
        Connect-VIServer -Server $VCenterServer | Out-Null
    }
}
catch {
    Write-Host "Failed to connect to vCenter: $_"
    exit 1
}

try {
    Write-Host "Resolving VMs from catalog: $CatalogName"
    $scheme = Get-ProvScheme -ProvisioningSchemeName $CatalogName -ErrorAction Stop
    $provVMs = @(Get-ProvVM -ProvisioningSchemeUid $scheme.ProvisioningSchemeUid -ErrorAction Stop)

    if ($provVMs.Count -eq 0) {
        Write-Host "No VMs found in catalog '$CatalogName'."
        exit 0
    }

    Write-Host "Found $($provVMs.Count) VM(s) in catalog."

    # Process each VM
    $changed = 0
    $skipped = 0
    $failed  = 0

    foreach ($provVM in $provVMs) {
        $vmName = $provVM.VMName
        $vm = Get-VM -Name $vmName -ErrorAction SilentlyContinue

        if (-not $vm) {
            Write-Host "  [$vmName] VM not found in vCenter. Skipped."
            $skipped++
            continue
        }

        # Step 2: Check firmware type and Secure Boot status
        $vmView = $vm | Get-View
        if ($vmView.Config.Firmware -ne "efi") {
            Write-Host "  [$vmName] Not EFI firmware. Skipped."
            $skipped++
            continue
        }

        if (-not $vmView.Config.BootOptions.EfiSecureBootEnabled) {
            Write-Host "  [$vmName] Secure Boot already disabled. Skipped."
            $skipped++
            continue
        }

        # Step 3: Ensure VM is powered off
        if ($vm.PowerState -ne "PoweredOff") {
            if (-not $ForcePowerOff) {
                Write-Host "  [$vmName] Powered on and -ForcePowerOff not specified. Skipped."
                $skipped++
                continue
            }

            Write-Host "  [$vmName] Powering off..."
            try {
                Stop-VM -VM $vm -Confirm:$false | Out-Null

                # Wait for VM to power off (timeout 120s)
                $timeout = 120
                $elapsed = 0
                while ($elapsed -lt $timeout) {
                    Start-Sleep -Seconds 5
                    $elapsed += 5
                    $current = Get-VM -Name $vmName
                    if ($current.PowerState -eq "PoweredOff") { break }
                }

                if ((Get-VM -Name $vmName).PowerState -ne "PoweredOff") {
                    Write-Host "  [$vmName] Force stopping..."
                    Stop-VM -VM (Get-VM -Name $vmName) -Kill -Confirm:$false | Out-Null

                    $killTimeout = 30
                    $killElapsed = 0
                    while ($killElapsed -lt $killTimeout) {
                        Start-Sleep -Seconds 5
                        $killElapsed += 5
                        if ((Get-VM -Name $vmName).PowerState -eq "PoweredOff") { break }
                    }
                    if ((Get-VM -Name $vmName).PowerState -ne "PoweredOff") {
                        Write-Host "  [$vmName] Failed to power off after force stop. Skipped."
                        $failed++
                        continue
                    }
                }
            }
            catch {
                Write-Host "  [$vmName] Failed to power off: $_"
                $failed++
                continue
            }
        }

        # Step 4: Disable Secure Boot
        try {
            $spec = New-Object VMware.Vim.VirtualMachineConfigSpec
            $spec.BootOptions = New-Object VMware.Vim.VirtualMachineBootOptions
            $spec.BootOptions.EfiSecureBootEnabled = $false

            $vmView = Get-VM -Name $vmName | Get-View
            $vmView.ReconfigVM($spec)
            Write-Host "  [$vmName] Secure Boot disabled."
            $changed++

            # Power back on if we forced it off
            if ($ForcePowerOff) {
                Start-VM -VM (Get-VM -Name $vmName) -Confirm:$false | Out-Null
                Write-Host "  [$vmName] Powered back on."
            }
        }
        catch {
            Write-Host "  [$vmName] Failed to disable Secure Boot: $_"
            $failed++
        }
    }

    # Summary
    $total = $changed + $skipped + $failed
    Write-Host ""
    Write-Host "=== Summary ==="
    Write-Host "Total: $total | Changed: $changed | Skipped: $skipped | Failed: $failed"
}
catch {
    Write-Host "Error: $_"
    exit 1
}
finally {
    try { Disconnect-VIServer -Server $VCenterServer -Confirm:$false -ErrorAction SilentlyContinue } catch { }
}
