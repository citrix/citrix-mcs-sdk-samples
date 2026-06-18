# Prevent Boot Failure - Deploy Certificate

## Problem

VMs originally created on ESXi 8.0.0 only have the **Windows UEFI CA 2011** certificate in their Secure Boot database. After the ESXi host is upgraded to 8.0.3, an MCS catalog update applies a 2023-signed bootloader to these VMs. The VMs fail to boot with **"No Boot Media"** because their Secure Boot DB does not trust the 2023 certificate.

**Important**: This script only works on VMs that can boot into Windows. For VMs that are already stuck at "No Boot Media", use the [Fix Boot Failure - Reset NVRAM](../Fix%20Boot%20Failure%20-%20Reset%20NVRAM/) or [Fix Boot Failure - Disable Secure Boot](../Fix%20Boot%20Failure%20-%20Disable%20Secure%20Boot/) script instead.

## Solution

The `Deploy-SecureBoot2023Cert.ps1` script deploys the 2023 certificate into each VM's Secure Boot database using Microsoft's built-in servicing mechanism. It is idempotent and safe to run on every boot.

### Steps

| Step | Condition | Action |
|------|-----------|--------|
| 1 | 2023 cert already in Secure Boot DB | Exit (done) |
| 2 | Servicing data or scheduled task missing | Trigger Windows Update to install the required cumulative update (July 2025+), then exit |
| 3 | Servicing data and task both available | Set regkey `AvailableUpdates=0x5944`, trigger `Secure-Boot-Update` task, then exit |

### Multi-Boot Flow

Multiple reboots are required to complete the full deployment:

```
Boot 1: Step 2 triggers Windows Update to download servicing data
Boot 2: Step 3 deploys the cert (applied on next reboot)
Boot 3: Step 1 confirms cert is present (done)
```

> **Note on Step 2**: `usoclient` may fail silently depending on enterprise restrictions (WSUS/SCCM/Intune policies, Windows Update service disabled, network/proxy blocks). If no updates appear, manually open **Settings > Windows Update > Check for updates**.



## How to Deploy via GPO

The script requires UEFI-level access to read Secure Boot data. Standard GPO startup scripts do not have this privilege, so it must be deployed as a **GPO Immediate Scheduled Task** with "Run with highest privileges" enabled.

### Step 1: Open Group Policy Management

On a domain controller or a machine with RSAT tools, press Win + R, type `gpmc.msc`, and press Enter.

### Step 2: Create a New GPO

1. Expand **Forest** > **Domains** > **yourdomain.local**.
2. Right-click the **OU (Organizational Unit)** where the target machines are located.
3. Click **"Create a GPO in this domain, and Link it here..."**.
4. Name it: `Deploy UEFI CA 2023 Certificate`.
5. Click OK.

### Step 3: Copy the Script to SYSVOL

Copy `Deploy-SecureBoot2023Cert.ps1` to a shared folder accessible by all target machines, for example:

```
\\yourdomain.local\SYSVOL\yourdomain.local\scripts\Deploy-SecureBoot2023Cert.ps1
```

### Step 4: Add an Immediate Scheduled Task

Right-click the new GPO and click **"Edit..."**. Navigate to:

```
Computer Configuration > Preferences > Control Panel Settings > Scheduled Tasks
```

1. Right-click > **New** > **Immediate Task (At least Windows 7)**.
2. **General** tab:
   - Change user to: `NT AUTHORITY\SYSTEM`
   - Check **"Run with highest privileges"**
3. **Actions** tab > **New**:
   - Action: **Start a program**
   - Program: `powershell.exe`
   - Arguments: `-ExecutionPolicy Bypass -File "\\yourdomain.local\SYSVOL\yourdomain.local\scripts\Deploy-SecureBoot2023Cert.ps1"`
4. Click OK on all dialogs.

### Step 5: Reboot Target Machines

The task runs automatically on the next Group Policy refresh. It will:
- Skip machines that already have the 2023 certificate.
- Deploy the certificate on machines that have the required Windows update.
- Trigger Windows Update on machines that are missing the required update.

A second reboot may be needed after the script deploys the certificate.



## Prerequisites

1. The machine must have **Secure Boot enabled** (EFI firmware).
2. **Windows cumulative update July 2025 or later** is required for certificate deployment. If the update is not installed, the script will trigger Windows Update to install it.
3. The script must run with **administrator privileges** and **UEFI access** (GPO Immediate Scheduled Task with "Run with highest privileges", or elevated PowerShell).

For manual testing: `powershell -ExecutionPolicy Bypass -File .\Deploy-SecureBoot2023Cert.ps1`



## References

- [KB5025885 - Managing the Windows Boot Manager revocations for Secure Boot changes](https://support.microsoft.com/en-us/topic/kb5025885)
- [Sample Secure Boot inventory data collection script](https://support.microsoft.com/en-us/topic/sample-secure-boot-inventory-data-collection-script-d02971d2-d4b5-42c9-b58a-8527f0ffa30b)
