# Provisioning Maintenance Cycle (XenServer)

The Maintenance Cycle feature allows scheduling and automating maintenance operations on MCS‑provisioned VMs on XenServer. Instead of performing updates manually, you can define when tasks such as image updates, OS disk resets, identity disk resets, and hardware configuration changes should run, and then return later to confirm their completion.

Maintenance Cycles can be configured for a specific set of VMs or for an entire machine catalog, giving flexibility in how broadly changes are applied. Each scheduled operation runs at its configured time, and multiple operations can be queued for the same VM, with the exception that only a single hardware update can be scheduled per VM at any given time.

## XenServer-Specific Behavior

- **VM Recreation** — During hardware updates, XenServer destroys the original VM and creates a new one with the updated configuration. Disks (OS, identity, WBC) are preserved and re-attached to the new VM. This differs from Azure, which modifies VMs in-place.
- **XenPlugin MCS Power Managed** — This feature needs XenPlugin MCS Power Managed to be enabled for maintenance cycle operations. Without it, hardware update capabilities are not advertised by the XenServer plugin.
- **vTPM Validation** — If the master image has vTPM enabled, disabling vTPM on the updated configuration returns an `InconsistentVtpmSetting` error. Adding vTPM to a catalog whose master image does not have it is allowed.
- **Catalog Types** — Both persistent and non-persistent MCS catalogs are supported. Persistent catalogs use full-clone disks while non-persistent catalogs use differencing disks.

## Known Limitations

- **MoveVm** — Moving VMs to a different host or storage is not supported on XenServer.
- **Snapshot backup/restore** — Snapshot-based backup during maintenance is not supported on XenServer.
- **Single hardware update per VM** — Only one hardware update can be pending per VM at any given time.

## Key Benefits

- **Graceful session handling** — users are notified in advance and given time to save their work before the VM is restarted or powered down.
- **Planned downtime** — schedule maintenance during off‑peak hours so administrators don’t need to perform actions manually at inconvenient times.
- **Cost‑efficient hardware updates** — automatically determine whether a VM requires a reboot, avoiding unnecessary reboots across large environments.

## Operations Supported

| Operation | Description | Create cmdlet |
|-----------|-------------|---------------|
| [ImageUpdate](./ImageUpdate/) | Update the master image on provisioned VMs | `New-ProvSchemeImageUpdate` |
| [OSDiskReset](./OSDiskReset/) | Reset OS disks to their original state | `New-ProvMaintenanceCycle -Operation ResetOSDisk` |
| [IdentityDiskReset](./IdentityDiskReset/) | Reset identity disk information | `New-ProvMaintenanceCycle -Operation ResetIDDisk` |
| [HardwareSchemeUpdate](./HardwareSchemeUpdate/) | Update hardware configuration (CPU, memory, network, etc.) | `New-ProvSchemeHardwareUpdate` |

## Common Operations

The following operations work identically across **all** operation types and are located in the [Common](./Common/) folder:

| Operation | Cmdlet | Script |
|-----------|--------|--------|
| Cancel | `Cancel-ProvMaintenanceCycle` | [Cancel-MaintenanceCycle.ps1](./Common/Cancel-MaintenanceCycle.ps1) |
| Delete | `Remove-ProvMaintenanceCycle` | [Remove-MaintenanceCycle.ps1](./Common/Remove-MaintenanceCycle.ps1) |
| Restart | `Restart-ProvMaintenanceCycle` | [Restart-MaintenanceCycle.ps1](./Common/Restart-MaintenanceCycle.ps1) |
| Update | `Update-ProvMaintenanceCycle` | [Update-MaintenanceCycle.ps1](./Common/Update-MaintenanceCycle.ps1) |

## Shared Utilities

| Utility | Cmdlet | Script |
|---------|--------|--------|
| Scheme History | `Get-ProvSchemeHistory` | [Get-SchemeHistory.ps1](./SchemeHistory/Get-SchemeHistory.ps1) |
