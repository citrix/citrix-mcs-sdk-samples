<#
.SYNOPSIS
    Prevent boot failure on XenServer VMs by deploying the Windows UEFI CA 2023 certificate
    to all VMs in a given MCS machine catalog.
.DESCRIPTION
    1. Problem:
       VMs with Secure Boot enabled may fail to boot with "No Boot Media" when an MCS catalog
       update applies a 2023-signed bootloader but the VM's Secure Boot DB only trusts the
       2011 certificate.

    2. Solution:
       XenServer provides a native API to deploy the 2023 certificate to VMs.
       This script marks VMs for certificate update on their next reboot, keeping
       Secure Boot enabled.

       Step 1 - Check required modules are loaded and connect to XenServer host.
       Step 2 - Resolve the catalog to a list of VMs.
       Step 3 - For each VM, check secureboot_certificates_state.
       Step 4 - Mark VMs with update_available state for certificate update on next reboot.
.NOTES
    Version : 1.0
    Author  : Citrix Systems, Inc.
.EXAMPLE
    # Mark all VMs in catalog for certificate update:
    .\Deploy-SecureBoot2023Cert.ps1 -CatalogName "MyCatalog" -XenServerHost "xenserver.domain.local"

    # Specify XenServer credentials explicitly:
    .\Deploy-SecureBoot2023Cert.ps1 -CatalogName "MyCatalog" -XenServerHost "xenserver.domain.local" -XenServerUsername "root"
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
    [string]$XenServerUsername
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
    $marked = 0
    $skipped = 0
    $failed  = 0
    $markedVMs = @()

    foreach ($provVM in $provVMs) {
        $vmName = $provVM.VMName

        # Get XenServer VM object
        $vm = Get-XenVM -Name $vmName -ErrorAction SilentlyContinue
        if (-not $vm) {
            Write-Host "  [$vmName] VM not found in XenServer. Skipped."
            $skipped++
            continue
        }

        # Step 3: Check certificate state
        $certState = $vm.secureboot_certificates_state
        switch ($certState) {
            "ok" {
                Write-Host "  [$vmName] Already has 2023 certificate. Skipped."
                $skipped++
            }
            "update_on_boot" {
                Write-Host "  [$vmName] Already marked for update. Skipped."
                $skipped++
            }
            "update_available" {
                # Step 4: Mark VM for certificate update on next reboot
                try {
                    Invoke-XenVM -XenAction UpdateSecurebootCertificatesOnBoot -VM $vm -Mark $true
                    Write-Host "  [$vmName] Marked for certificate update on next reboot."
                    $marked++
                    $markedVMs += $vmName
                }
                catch {
                    Write-Host "  [$vmName] Failed to mark for update: $_"
                    $failed++
                }
            }
            default {
                $msg = if ([string]::IsNullOrEmpty($certState)) {
                    "Certificate state not available. The XenServer version may not support this API."
                } else {
                    "Unknown certificate state: '$certState'."
                }
                Write-Host "  [$vmName] $msg Skipped."
                $skipped++
            }
        }
    }

    # --- Summary ---

    $total = $marked + $skipped + $failed
    Write-Host ""
    Write-Host "=== Summary ==="
    Write-Host "Total: $total | Marked: $marked | Skipped: $skipped | Failed: $failed"

    if ($markedVMs.Count -gt 0) {
        Write-Host ""
        Write-Host "The following VMs have been marked for certificate update:"
        $markedVMs | ForEach-Object { Write-Host "  - $_" }
        Write-Host ""
        Write-Host "Please reboot these VMs to complete the 2023 certificate deployment."
    }
}
catch {
    Write-Host "Error: $_"
    exit 1
}
finally {
    try { Disconnect-XenServer } catch { }
}
