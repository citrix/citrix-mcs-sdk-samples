<#
.SYNOPSIS
    Fix boot failure on XenServer VMs by disabling Secure Boot on all VMs in a given MCS machine catalog.
.DESCRIPTION
    1. Problem:
       VMs with Secure Boot enabled may fail to boot with "No Boot Media" when an MCS catalog
       update applies a 2023-signed bootloader but the VM's Secure Boot DB only trusts the
       2011 certificate.

    2. Solution:
       This script disables Secure Boot on all VMs in a machine catalog so that the bootloader
       signature is not checked. This allows VMs to boot regardless of which certificate signed
       the bootloader.

       Step 1 - Check required modules are loaded and connect to XenServer host.
       Step 2 - Resolve the catalog to a list of VMs.
       Step 3 - For each VM, check Secure Boot status and power state.
       Step 4 - Disable Secure Boot by setting platform:secureboot=false.

    3. Important Notes:
       (1) VMs must be powered off to change Secure Boot settings. Use -ForcePowerOff
           to automatically shut down running VMs, or power them off manually beforehand.
       (2) Disabling Secure Boot removes a security layer.
       (3) XenServer does not allow guest-side scripts to access NVRAM or the Secure Boot DB,
           so disabling Secure Boot from the hypervisor is the available script-based fix.
       (4) For fuller information on the Secure Boot certificate transition, please refer to:
           https://support.microsoft.com/en-us/topic/kb5025885
.NOTES
    Version : 1.0
    Author  : Citrix Systems, Inc.
.EXAMPLE
    # Disable Secure Boot on all VMs in catalog (skip powered-on VMs):
    .\Disable-SecureBoot.ps1 -CatalogName "MyCatalog" -XenServerHost "xenserver.domain.local"

    # Disable Secure Boot and force power off running VMs:
    .\Disable-SecureBoot.ps1 -CatalogName "MyCatalog" -XenServerHost "xenserver.domain.local" -ForcePowerOff

    # Specify XenServer credentials explicitly:
    .\Disable-SecureBoot.ps1 -CatalogName "MyCatalog" -XenServerHost "xenserver.domain.local" -XenServerUsername "root"
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
    [string]$XenServerHost,
    [string]$XenServerUsername,
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

# Verify XenServer PowerShell Module is loaded.
# The XenServer SDK can be downloaded from https://www.xenserver.com/downloads
if (-not (Get-Module XenServerPSModule -ErrorAction SilentlyContinue)) {
    Write-Host "XenServer PowerShell Module is not loaded."
    Write-Host "  Import-Module XenServerPSModule"
    exit 1
}

# Step 1: Connect to XenServer
Write-Host "Connecting to XenServer: $XenServerHost"
try {
    if ($XenServerUsername) {
        $cred = Get-Credential -UserName $XenServerUsername -Message "Enter XenServer password"
        Connect-XenServer -Server $XenServerHost -Cred $cred -SetDefaultSession | Out-Null
    }
    else {
        $cred = Get-Credential -Message "Enter XenServer credentials"
        Connect-XenServer -Server $XenServerHost -Cred $cred -SetDefaultSession | Out-Null
    }
}
catch {
    Write-Host "Failed to connect to XenServer: $_"
    exit 1
}

try {
    # Step 2: Resolve catalog VMs
    Write-Host "Resolving VMs from catalog: $CatalogName"
    $scheme = Get-ProvScheme -ProvisioningSchemeName $CatalogName -ErrorAction Stop
    $provVMs = @(Get-ProvVM -ProvisioningSchemeUid $scheme.ProvisioningSchemeUid -ErrorAction Stop)

    if ($provVMs.Count -eq 0) {
        Write-Host "No VMs found in catalog '$CatalogName'."
        exit 0
    }

    Write-Host "Found $($provVMs.Count) VM(s) in catalog."

    # Step 3-4: Process each VM
    $changed = 0
    $skipped = 0
    $failed  = 0

    foreach ($provVM in $provVMs) {
        $vmName = $provVM.VMName

        # Get XenServer VM object
        $vm = Get-XenVM -Name $vmName -ErrorAction SilentlyContinue
        if (-not $vm) {
            Write-Host "  [$vmName] VM not found in XenServer. Skipped."
            $skipped++
            continue
        }

        # Step 3: Check Secure Boot status
        $platform = $vm.platform
        $secureBoot = $platform["secureboot"]
        if ($secureBoot -ne "true") {
            Write-Host "  [$vmName] Secure Boot not enabled. Skipped."
            $skipped++
            continue
        }

        # Check power state
        $powerState = $vm.power_state
        if ($powerState -ne "Halted") {
            if (-not $ForcePowerOff) {
                Write-Host "  [$vmName] Powered on and -ForcePowerOff not specified. Skipped."
                $skipped++
                continue
            }

            Write-Host "  [$vmName] Shutting down..."
            try {
                Invoke-XenVM -VM $vm -XenAction CleanShutdown -Async | Out-Null

                # Wait for VM to shut down (timeout 120s)
                $timeout = 120
                $elapsed = 0
                while ($elapsed -lt $timeout) {
                    Start-Sleep -Seconds 5
                    $elapsed += 5
                    $current = Get-XenVM -Name $vmName
                    if ($current.power_state -eq "Halted") { break }
                }

                if ((Get-XenVM -Name $vmName).power_state -ne "Halted") {
                    Write-Host "  [$vmName] Force stopping..."
                    Invoke-XenVM -VM (Get-XenVM -Name $vmName) -XenAction HardShutdown | Out-Null
                    Start-Sleep -Seconds 5
                }
            }
            catch {
                Write-Host "  [$vmName] Failed to shut down: $_"
                $failed++
                continue
            }
        }

        # Step 4: Disable Secure Boot
        try {
            $vm = Get-XenVM -Name $vmName
            $platform = $vm.platform
            $platform["secureboot"] = "false"
            Set-XenVM -VM $vm -Platform $platform
            Write-Host "  [$vmName] Secure Boot disabled."
            $changed++

            # Power back on if we forced it off
            if ($ForcePowerOff) {
                Invoke-XenVM -VM (Get-XenVM -Name $vmName) -XenAction Start | Out-Null
                Write-Host "  [$vmName] Powered back on."
            }
        }
        catch {
            Write-Host "  [$vmName] Failed to disable Secure Boot: $_"
            $failed++
        }
    }

    # --- Summary ---

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
    try { Disconnect-XenServer } catch { }
}
