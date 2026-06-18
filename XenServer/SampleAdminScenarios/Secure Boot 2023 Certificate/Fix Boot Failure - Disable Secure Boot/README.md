# Fix Boot Failure - Disable Secure Boot (XenServer)

## Problem

VMs with Secure Boot enabled may fail to boot with **"No Boot Media"** when an MCS catalog update applies a 2023-signed bootloader but the VM's Secure Boot DB only trusts the 2011 certificate.

XenServer does not allow guest-side scripts to access NVRAM or the Secure Boot DB, so disabling Secure Boot from the hypervisor is the available script-based fix.

## Solution

The `Disable-SecureBoot.ps1` script disables Secure Boot on all VMs in a given MCS machine catalog using the XenServer PowerShell Module. With Secure Boot disabled, VMs boot without checking the bootloader's certificate signature.

## Parameters

| Parameter | Required | Description |
|-----------|----------|-------------|
| `-CatalogName` | Yes | MCS machine catalog name |
| `-XenServerHost` | Yes | XenServer host address |
| `-XenServerUsername` | No | XenServer username (you will be prompted for credentials if omitted) |
| `-ForcePowerOff` | No | If specified, force shut down running VMs. Otherwise, powered-on VMs are skipped. |

## Usage Examples

```powershell
# Disable Secure Boot on all VMs in catalog (skip powered-on VMs):
.\Disable-SecureBoot.ps1 -CatalogName "MyCatalog" -XenServerHost "xenserver.domain.local"

# Disable Secure Boot and force shut down running VMs:
.\Disable-SecureBoot.ps1 -CatalogName "MyCatalog" -XenServerHost "xenserver.domain.local" -ForcePowerOff

# Specify XenServer credentials explicitly:
.\Disable-SecureBoot.ps1 -CatalogName "MyCatalog" -XenServerHost "xenserver.domain.local" -XenServerUsername "root"
```

## How the Script Works

For each VM in the catalog:

1. **Check Secure Boot status** — reads the VM's `platform` map. Skips VMs with Secure Boot not enabled.
2. **Check power state** — if the VM is running:
   - With `-ForcePowerOff`: gracefully shuts down the VM (force-kills after 120s timeout).
   - Without `-ForcePowerOff`: skips the VM.
3. **Disable Secure Boot** — sets `platform:secureboot=false` via `Set-XenVM`.
4. **Power on** — if the VM was force-stopped, powers it back on.

## Prerequisites

1. **XenServer PowerShell Module (XenServerPSModule)** must be installed and loaded before running the script (`Import-Module XenServerPSModule`). This module is **not available on PSGallery**. To install:
   1. Download the XenServer SDK from [xenserver.com/downloads](https://www.xenserver.com/downloads).
   2. Unblock the downloaded ZIP before extracting:
      ```powershell
      Unblock-File XenServer-SDK.*.zip
      ```
   3. Extract the ZIP.
   4. Copy the module to a standard PowerShell module directory:
      ```powershell
      Copy-Item "XenServer-SDK\XenServerPowerShell\PowerShell_51\XenServerPSModule" `
          -Destination "$env:ProgramFiles\WindowsPowerShell\Modules\XenServerPSModule" -Recurse
      ```
      Use `PowerShell_51` for Windows PowerShell 5.1 or `PowerShell_7` for PowerShell 7+.
   5. Verify the module loads:
      ```powershell
      Import-Module XenServerPSModule
      ```
2. **Citrix PowerShell SDK** must be loaded before running the script (for `Get-ProvScheme` and `Get-ProvVM` cmdlets). For on-premises: `Add-PSSnapin Citrix.*`. For Citrix Cloud: `Import-Module Citrix.MachineCreation.Admin.V2` and run `Get-XDAuthentication` first.
3. XenServer credentials with permission to reconfigure VMs.
4. VMs must be **powered off** to change Secure Boot settings (or use `-ForcePowerOff`).

## References

- [KB5025885 - Managing the Windows Boot Manager revocations for Secure Boot changes](https://support.microsoft.com/en-us/topic/kb5025885)
