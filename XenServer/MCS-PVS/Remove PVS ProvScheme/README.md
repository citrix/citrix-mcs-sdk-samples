# Remove PVS Catalog (Including VMs) on XenServer

This folder contains an example PowerShell script for **completely removing** a PVS-backed MCS catalog on **XenServer**, including all provisioned VMs, AD computer accounts, and associated Citrix objects.

- Script: [`Remove-PvsProvScheme.ps1`](./Remove-PvsProvScheme.ps1)

---

## Overview

The script performs a full teardown in the following order:

| Step | Action | Cmdlet |
|------|--------|--------|
| 1 | Unlock and remove ProvVM(s) | `Unlock-ProvVM` / `Remove-ProvVM` |
| 2 | Remove AD computer accounts | `Remove-AcctADAccount` |
| 3 | Remove the identity pool | `Remove-AcctIdentityPool` |
| 4 | Remove Broker Machine(s) from the catalog | `Remove-BrokerMachine` |
| 5 | Remove the provisioning scheme | `Remove-ProvScheme` |
| 6 | Remove the broker catalog | `Remove-BrokerCatalog` |
| 7 | Clean up provisioning tasks | `Remove-ProvTask` |

---

## Parameters

| Parameter | Required | Description |
|-----------|----------|-------------|
| `ProvisioningSchemeName` | Yes | Name of the PVS catalog to remove |
| `IdentityPoolName` | No | Name of the identity pool (defaults to `ProvisioningSchemeName`) |
| `Domain` | Yes | AD domain (e.g. `corp.local`) |
| `UserName` | Yes | AD user with permissions to delete computer accounts |
| `AdminAddress` | No | Delivery Controller address (on-prem only) |
| `PurgeDBOnly` | No | Remove records from MCS database only; VMs remain on the hypervisor |
| `ForgetVM` | No | Disassociate VMs from Citrix but keep them on the hypervisor |

> **Note:** `-PurgeDBOnly` and `-ForgetVM` are mutually exclusive. The script will prompt for the AD password at runtime.

---

## Examples

### Full removal (deletes VMs from XenServer)

```powershell
.\Remove-PvsProvScheme.ps1 `
    -ProvisioningSchemeName "MyCatalog" `
    -Domain "corp.local" `
    -UserName "admin1"
```

### Remove catalog but keep VMs on the hypervisor

```powershell
.\Remove-PvsProvScheme.ps1 `
    -ProvisioningSchemeName "MyCatalog" `
    -Domain "corp.local" `
    -UserName "admin1" `
    -ForgetVM
```

### Remove catalog records from DB only (no hypervisor changes)

```powershell
.\Remove-PvsProvScheme.ps1 `
    -ProvisioningSchemeName "MyCatalog" `
    -Domain "corp.local" `
    -UserName "admin1" `
    -PurgeDBOnly
```

---

## Prerequisites

- Run from a **Delivery Controller (DDC)** with the Citrix PowerShell SDK installed.
- The AD account specified must have permissions to **delete computer accounts** in the target OU.
- Ensure machines are **not in a delivery group** with active sessions, or power them off / drain sessions first.
- Compatible with **CVAD** and **Citrix DaaS**.
