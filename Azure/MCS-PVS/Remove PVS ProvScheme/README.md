# Remove PVS Catalog (Including VMs) on Azure

This folder contains an example PowerShell script for **completely removing** a PVS-backed MCS catalog on **Azure**, including all provisioned VMs, AD computer accounts, and associated Citrix objects.

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

---

## Parameters

| Parameter | Required | Description |
|-----------|----------|-------------|
| `ProvisioningSchemeName` | Yes | Name of the PVS catalog to remove |
| `IdentityPoolName` | Yes | Name of the identity pool associated with the catalog |
| `ForgetVM` | No | Disassociate VMs from Citrix but keep them in Azure |

---

## Examples

### Full removal (deletes VMs from Azure)

```powershell
.\Remove-PvsProvScheme.ps1 `
    -ProvisioningSchemeName "MyCatalog" `
    -IdentityPoolName "MyCatalog"
```

### Remove catalog but keep VMs in Azure

```powershell
.\Remove-PvsProvScheme.ps1 `
    -ProvisioningSchemeName "MyCatalog" `
    -IdentityPoolName "MyCatalog" `
    -ForgetVM
```

---

## Prerequisites

- Compatible with **CVAD** and **Citrix DaaS**.
- The Citrix PowerShell SDK must be available (snap-ins: `Citrix.Host.Admin.V2`, `Citrix.MachineCreation.Admin.V2`, `Citrix.Broker.Admin.V2`).
- Ensure machines are **not in a delivery group** with active sessions, or power them off / drain sessions first.
