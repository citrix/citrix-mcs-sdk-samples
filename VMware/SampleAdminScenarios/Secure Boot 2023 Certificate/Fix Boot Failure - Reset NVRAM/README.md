# Fix Boot Failure - Reset NVRAM

## Problem

After an MCS catalog update with a 2023-signed bootloader, VMs fail to boot with **"No Boot Media"**. This happens because the VMs were created on ESXi 8.0.0, which only included the 2011 certificate in the NVRAM Secure Boot database. The VM does not trust the 2023-signed bootloader and refuses to start.

These VMs cannot boot into Windows, so the issue cannot be resolved from inside the guest OS.

## Solution

The `Reset-SecureBootNvram.ps1` script resolves this by deleting the VM's NVRAM file from the VMware datastore. When ESXi 8.0.3+ regenerates the NVRAM on next boot, it includes both the 2011 and 2023 certificates in the Secure Boot database, allowing the VM to trust the 2023-signed bootloader.

The script runs from an **admin machine with PowerCLI** and talks directly to vCenter — not to the VM's Windows OS. Each VM's NVRAM is scanned for the 2023 certificate before deletion, and VMs that already have the cert are automatically skipped.

By default, VMs are left powered off after NVRAM deletion, waiting for the next boot cycle. Use `-PowerOnAndVerify` to power on VMs and optionally verify certificates immediately.

**Note**: To prevent this issue on VMs that can still boot, use the [Prevent Boot Failure - Deploy Certificate](../Prevent%20Boot%20Failure%20-%20Deploy%20Certificate/) script instead.



## 1. Script: Reset-SecureBootNvram.ps1

The `Reset-SecureBootNvram.ps1` script resets Secure Boot NVRAM and requires the following parameters:

    1. VMName: One or more VM names. Supports wildcards (e.g., "VDA*"). Cannot be used with CatalogName.

    2. CatalogName: MCS machine catalog name. Resolves all Secure Boot (EFI) VMs in the catalog. Requires Citrix PowerShell SDK. Cannot be used with VMName.

    3. VCenterServer: The vCenter server address to connect to.

    4. VCenterUsername: vCenter username. If provided, you will only be prompted for the password. If omitted, Windows SSO is used.

    5. ForceTurnOff: Force power off VMs that are currently running before deleting NVRAM.

    6. PowerOnAndVerify: Power on VMs after NVRAM deletion and optionally verify certificates. Without this switch, VMs are left powered off after NVRAM deletion.

    7. GuestUsername: Guest OS admin username. When used with -PowerOnAndVerify, enables certificate verification inside the guest OS. Requires VMware Tools.

The script also supports the `-WhatIf` parameter for dry-run mode, which shows what would happen without making any changes.

The script can be executed with parameters as shown in the examples below:

```powershell
    # Reset NVRAM for VMs by name. VMs are left powered off after NVRAM deletion.
    .\Reset-SecureBootNvram.ps1 `
        -VMName "VDA001","VDA002" `
        -VCenterServer "vcenter.example.com" `
        -VCenterUsername "administrator@vsphere.local" `
        -ForceTurnOff

    # Reset NVRAM for all Secure Boot VMs in an MCS catalog.
    # VMs are put in maintenance mode, NVRAM is reset, then maintenance mode is turned off.
    .\Reset-SecureBootNvram.ps1 `
        -CatalogName "MyCatalog" `
        -VCenterServer "vcenter.example.com" `
        -VCenterUsername "administrator@vsphere.local" `
        -ForceTurnOff

    # Reset NVRAM and power on VMs with certificate verification.
    .\Reset-SecureBootNvram.ps1 `
        -CatalogName "MyCatalog" `
        -VCenterServer "vcenter.example.com" `
        -VCenterUsername "administrator@vsphere.local" `
        -GuestUsername "YOURDOMAIN\admin" `
        -ForceTurnOff `
        -PowerOnAndVerify
```

Dry run:

```powershell
    # Dry run showing what would happen without making any changes.
    .\Reset-SecureBootNvram.ps1 `
        -VMName "VDA001","VDA002" `
        -VCenterServer "vcenter.example.com" `
        -VCenterUsername "administrator@vsphere.local" `
        -ForceTurnOff `
        -WhatIf

    # Dry run with catalog mode and full verification.
    .\Reset-SecureBootNvram.ps1 `
        -CatalogName "MyCatalog" `
        -VCenterServer "vcenter.example.com" `
        -VCenterUsername "administrator@vsphere.local" `
        -GuestUsername "YOURDOMAIN\admin" `
        -ForceTurnOff `
        -PowerOnAndVerify `
        -WhatIf
```

Administrators should tailor these parameters to fit their specific environment.



## 2. Overview of the Script

The script operates in up to 7 phases for efficient batch processing:

    1. Get VM Details: Resolves VMs by name or MCS catalog. For catalog mode, lists all machines in the catalog via Citrix PowerShell SDK and resolves each to a VMware VM. Checks firmware type (EFI vs BIOS) and Secure Boot status — only EFI VMs are processed.

    2. Set Maintenance Mode ON (Optional): Sets maintenance mode on all VMs via Citrix Broker to prevent user sessions during the reset.

    3. Stop Running VMs: Powers off all running VMs using batched async power operations. Skips VMs that are already powered off. Requires -ForceTurnOff to be specified.

    4. Back Up and Delete NVRAM Files: Groups VMs by datastore and mounts one PSDrive per datastore for efficiency. For each VM, scans the NVRAM file for the 2023 certificate. If the cert is already present, the VM is skipped. Otherwise, the NVRAM file is backed up (.nvram.bak) and deleted.

    5. Power On VMs (Optional): Enabled with -PowerOnAndVerify. Powers on all VMs whose NVRAM was deleted, using batched async power operations. ESXi regenerates the NVRAM with both 2011 and 2023 certificates on boot. Without -PowerOnAndVerify, VMs are left powered off.

    6. Verify Certificates (Optional): Enabled with -PowerOnAndVerify and -GuestUsername. Uses Invoke-VMScript via VMware Tools to remotely verify the 2023 certificate was added to each VM's NVRAM in batches. Checks NVRAM cert database, bootloader signature, and servicing registry status.

    7. Set Maintenance Mode OFF (Optional): Turns off maintenance mode on all VMs via Citrix Broker.



## 3. Detail of the Script

**Phase 1: Get VM Details.**

Resolves VMs from either direct names (with wildcard support) or an MCS machine catalog:
- **By name (`-VMName`)**: Resolves each name via `Get-VM`, supporting wildcards (e.g., `"VDA*"`). VMs not found in vCenter are skipped with a warning.
- **By catalog (`-CatalogName`)**: Verifies the catalog exists via `Get-ProvScheme`, lists all machines via `Get-ProvVM`, and resolves each to a VMware VM. Checks firmware type — only EFI VMs are included; BIOS VMs are skipped as they are not affected by the Secure Boot issue. Displays a VM resolution summary showing EFI, BIOS, and not-found counts.

**Phase 2: Set Maintenance Mode ON (Optional).**

Sets maintenance mode on all VMs via `Set-BrokerMachine -InMaintenanceMode $true` to prevent user sessions during the reset process. VMs not found in the Citrix Broker are skipped with a warning.

**Phase 3: Stop Running VMs.**

Sends `Stop-VM -RunAsync` commands to running VMs in batches, then polls each batch until all VMs are powered off or a timeout is reached. VMs that are already powered off are passed through. If `-ForceTurnOff` is not specified, running VMs are skipped with a warning.

**Phase 4: Back Up and Delete NVRAM Files.**

Groups VMs by datastore and mounts a single PSDrive per datastore for efficiency. For each VM:
- Checks firmware type — BIOS VMs are skipped (only EFI VMs are affected).
- Determines the NVRAM file path from the VM configuration.
- Downloads the NVRAM file to a temp directory and scans it for the ASCII string "Windows UEFI CA 2023". VMs with the cert already present are skipped.
- Backs up the NVRAM file (`.nvram.bak`) on the datastore before deletion. The backup is overwritten on re-runs. Delete it manually once the VM boots successfully (e.g., via the datastore browser or `Remove-DatastoreItem`).
- Deletes the NVRAM file so ESXi regenerates it on next boot.

**Phase 5: Power On VMs (Optional).**

Enabled with `-PowerOnAndVerify`. Sends `Start-VM -RunAsync` commands to VMs whose NVRAM was deleted, in batches. Polls each batch until all VMs are powered on or a timeout is reached. Without `-PowerOnAndVerify`, VMs are left powered off after NVRAM deletion.

**Phase 6: Verify Certificates (Optional).**

Enabled with `-PowerOnAndVerify` and `-GuestUsername`. For each VM in batches:
- Waits for VMware Tools to become ready.
- Runs a PowerShell script inside the guest OS via `Invoke-VMScript` to check:
    - Whether the NVRAM Secure Boot database contains "Windows UEFI CA 2023".
    - The bootloader signer certificate and expiry date.
    - The UEFI CA 2023 servicing status in the registry.
- Updates the result table with verification status (Yes/No/Error).

**Phase 7: Set Maintenance Mode OFF (Optional).**

Turns off maintenance mode on all VMs via `Set-BrokerMachine -InMaintenanceMode $false`. This phase is always executed last, regardless of whether `-PowerOnAndVerify` is used.



## 4. Prerequisites

    1. VMware PowerCLI module must be installed and loaded before running the script. Install with: `Install-Module VMware.PowerCLI -Scope CurrentUser`. Load with: `Import-Module VMware.PowerCLI`.

    2. ESXi 8.0.3 or later is required for NVRAM regeneration with 2023 certificates.

    3. Citrix PowerShell SDK must be installed and loaded before running the script (both MachineCreation and Broker modules). Run on a Delivery Controller or a machine with the SDK installed. For on-premises: `Add-PSSnapin Citrix.*`. For Citrix Cloud: `Import-Module Citrix.MachineCreation.Admin.V2` and `Import-Module Citrix.Broker.Admin.V2`, and run `Get-XDAuthentication` first.

    4. For verification (-PowerOnAndVerify with -GuestUsername): VMware Tools must be installed and running inside each VM. Guest credentials must have administrator privileges.



## 5. Outputs

    1. A timestamped log file with detailed per-VM results in the current directory (e.g., `Reset-SecureBootNvram_20260504_143000.log`).

    2. Console output with phase progress, per-VM status, and a summary table showing Success/Skipped/Failed counts.
