# Prevent Boot Failure - Deploy Certificate (XenServer)

## Problem

VMs with Secure Boot enabled may fail to boot with **"No Boot Media"** when an MCS catalog update applies a 2023-signed bootloader but the VM's Secure Boot DB only trusts the 2011 certificate.

MCS catalog updates replace the OS disk (including the bootloader) but do not touch the VM's NVRAM. Newly provisioned VMs added to existing catalogs also inherit the old certificates from the master image.

## Solution

The `Deploy-SecureBoot2023Cert.ps1` script uses the native XenServer API to mark VMs for certificate update on their next reboot. This deploys the 2023 certificate into each VM's Secure Boot database while keeping Secure Boot enabled.

## Parameters

| Parameter | Required | Description |
|-----------|----------|-------------|
| `-CatalogName` | Yes | MCS machine catalog name |
| `-XenServerHost` | Yes | XenServer host address |
| `-XenServerUsername` | No | XenServer username (you will be prompted for credentials if omitted) |

## Usage Examples

```powershell
# Mark all VMs in catalog for certificate update:
.\Deploy-SecureBoot2023Cert.ps1 -CatalogName "MyCatalog" -XenServerHost "xenserver.domain.local"

# Specify XenServer credentials explicitly:
.\Deploy-SecureBoot2023Cert.ps1 -CatalogName "MyCatalog" -XenServerHost "xenserver.domain.local" -XenServerUsername "root"
```

## References

- [KB5025885 - Managing the Windows Boot Manager revocations for Secure Boot changes](https://support.microsoft.com/en-us/topic/kb5025885)
