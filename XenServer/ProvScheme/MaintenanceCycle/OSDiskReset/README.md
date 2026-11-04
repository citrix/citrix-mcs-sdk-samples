# Maintenance Cycle — OS Disk Reset (XenServer)

Scripts for creating and querying OS Disk Reset maintenance cycles on XenServer. For common operations (cancel, delete, restart, update), see [Common](../Common/).

## Create a Maintenance Cycle

Creates an OS Disk Reset maintenance cycle for all VMs or a specific list.

**Required parameters:**
- `ProvisioningSchemeName`
- `ScheduledStartTimeInUTC`
- `-AllVMs` or `-VMName`

**Optional parameters:**
- `MaintenanceCycleDescription`
- `MaxDurationInMinutes`
- `PurgeDBAfterInDays`
- `SessionWarningTimeInMinutes`
- `SessionWarningLogOffTitle`
- `SessionWarningLogOffMessage`

```powershell
# For all VMs
New-ProvMaintenanceCycle -AllVMs `
  -ProvisioningSchemeName $provisioningSchemeName `
  -ScheduledStartTimeInUTC $startTime `
  -Operation ResetOSDisk

# For specific VMs
New-ProvMaintenanceCycle -VMName reset03, reset05 `
  -ProvisioningSchemeName $provisioningSchemeName `
  -ScheduledStartTimeInUTC $startTime `
  -Operation ResetOSDisk
```

See [Create-MaintenanceCycle.ps1](./Create-MaintenanceCycle.ps1)

## Get Maintenance Cycle

Retrieves maintenance cycle details with optional filters.

**Optional filter parameters:**
- `MaintenanceCycleId`
- `ProvisioningSchemeUid`
- `ProvisioningSchemeName`

```powershell
Get-ProvMaintenanceCycle -MaintenanceCycleId $maintenanceCycleId
```

See [Get-MaintenanceCycle.ps1](./Get-MaintenanceCycle.ps1)

## Get Maintenance Cycle VM Instances

Retrieves per-VM status for a maintenance cycle.

**Optional filter parameters:**
- `MaintenanceCycleId`
- `VirtualMachineSid`
- `MaintenanceOperation`
- `MaintenanceStatus`

```powershell
Get-ProvMaintenanceCycleVM -MaintenanceCycleId $maintenanceCycleId -MaintenanceOperation ResetOSDisk
```

See [Get-MaintenanceCycleVM.ps1](./Get-MaintenanceCycleVM.ps1)
