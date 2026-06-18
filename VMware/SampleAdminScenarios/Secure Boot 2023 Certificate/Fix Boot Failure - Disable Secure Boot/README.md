# Fix Boot Failure - Disable Secure Boot

## Problem

VMs originally created on ESXi 8.0.0 only have the **Windows UEFI CA 2011** certificate in their Secure Boot database. After the ESXi host is upgraded to 8.0.3, an MCS catalog update applies a 2023-signed bootloader to these VMs. The VMs fail to boot with **"No Boot Media"** because their Secure Boot DB does not trust the 2023 certificate.

## Solution

The `Disable-SecureBoot.ps1` script disables Secure Boot on all VMs in a given MCS machine catalog. With Secure Boot disabled, the VM boots without checking the bootloader's certificate signature.

> **Note**: Disabling Secure Boot removes a security layer. If VMs can still boot into Windows, consider using the [Prevent Boot Failure - Deploy Certificate](../Prevent%20Boot%20Failure%20-%20Deploy%20Certificate/) script instead, which deploys the 2023 certificate while keeping Secure Boot enabled.

## Parameters

| Parameter | Required | Description |
|-----------|----------|-------------|
| `-CatalogName` | Yes | MCS machine catalog name |
| `-VCenterServer` | Yes | vCenter server address |
| `-VCenterUsername` | No | vCenter username (omit for Windows SSO) |
| `-ForcePowerOff` | No | If specified, force power off running VMs. Otherwise, powered-on VMs are skipped. |

## Usage Examples

```powershell
# Disable Secure Boot on all VMs in catalog (skip powered-on VMs):
.\Disable-SecureBoot.ps1 -CatalogName "MyCatalog" -VCenterServer "vcenter.domain.local"

# Disable Secure Boot and force power off running VMs:
.\Disable-SecureBoot.ps1 -CatalogName "MyCatalog" -VCenterServer "vcenter.domain.local" -ForcePowerOff

# Specify vCenter credentials explicitly:
.\Disable-SecureBoot.ps1 -CatalogName "MyCatalog" -VCenterServer "vcenter.domain.local" -VCenterUsername "admin@vsphere.local"
```

## How the Script Works

For each VM in the catalog:

1. **Check firmware and Secure Boot** — skips non-EFI VMs and VMs with Secure Boot already disabled.
2. **Check power state** — if the VM is powered on:
   - With `-ForcePowerOff`: gracefully stops the VM (force-kills after 120s timeout).
   - Without `-ForcePowerOff`: skips the VM.
3. **Disable Secure Boot** — reconfigures the VM via `ReconfigVM` API to set `EfiSecureBootEnabled = false`.
4. **Power on** — if the VM was force-stopped, powers it back on.

## Prerequisites

1. **VMware PowerCLI** must be installed and loaded before running the script: `Install-Module VMware.PowerCLI` and `Import-Module VMware.PowerCLI`.
2. **Citrix PowerShell SDK** must be loaded before running the script (for `Get-ProvScheme` and `Get-ProvVM` cmdlets). For on-premises: `Add-PSSnapin Citrix.*`. For Citrix Cloud: `Import-Module Citrix.MachineCreation.Admin.V2` and run `Get-XDAuthentication` first.
3. vCenter credentials with permission to reconfigure VMs.
4. VMs must be **powered off** to change Secure Boot settings (or use `-ForcePowerOff`).

## References

- [KB5025885 - Managing the Windows Boot Manager revocations for Secure Boot changes](https://support.microsoft.com/en-us/topic/kb5025885)
