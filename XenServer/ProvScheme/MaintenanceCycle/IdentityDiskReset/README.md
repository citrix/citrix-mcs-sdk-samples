# Maintenance Cycle — Identity Disk Reset (XenServer)

Scripts for creating and querying Identity Disk Reset maintenance cycles on XenServer. For common operations (cancel, delete, restart, update), see [Common](../Common/).

## Create a Maintenance Cycle

Creates an Identity Disk Reset maintenance cycle for all VMs or a specific list.

> **Important:** Before creating the maintenance cycle, repair the identity information using `Repair-AcctIdentity`.

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
# Repair identity first
Get-ProvVm | Repair-AcctIdentity -Target IdentityInfo

# For all VMs
New-ProvMaintenanceCycle -AllVMs `
  -ProvisioningSchemeName $provisioningSchemeName `
  -ScheduledStartTimeInUTC $startTime `
  -Operation ResetIDDisk

# For specific VMs
New-ProvMaintenanceCycle -VMName reset03, reset05 `
  -ProvisioningSchemeName $provisioningSchemeName `
  -ScheduledStartTimeInUTC $startTime `
  -Operation ResetIDDisk
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
Get-ProvMaintenanceCycleVM -MaintenanceCycleId $maintenanceCycleId -MaintenanceOperation ResetIDDisk
```

See [Get-MaintenanceCycleVM.ps1](./Get-MaintenanceCycleVM.ps1)
