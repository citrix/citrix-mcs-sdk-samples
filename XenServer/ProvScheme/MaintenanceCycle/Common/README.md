# Common Maintenance Cycle Operations

These scripts apply to **all** maintenance cycle operation types (ImageUpdate, OSDiskReset, IdentityDiskReset, HardwareSchemeUpdate). They operate on an existing maintenance cycle identified by its `MaintenanceCycleId`.

## Cancel a Maintenance Cycle

Cancels an in-progress or pending maintenance cycle.

**Required parameters:**
- `MaintenanceCycleId`

```powershell
Cancel-ProvMaintenanceCycle -MaintenanceCycleId $maintenanceCycleId
```

See [Cancel-MaintenanceCycle.ps1](./Cancel-MaintenanceCycle.ps1)

## Delete a Maintenance Cycle

Permanently removes a maintenance cycle record.

**Required parameters:**
- `MaintenanceCycleId`

```powershell
Remove-ProvMaintenanceCycle -MaintenanceCycleId $maintenanceCycleId
```

See [Remove-MaintenanceCycle.ps1](./Remove-MaintenanceCycle.ps1)

## Restart a Maintenance Cycle

Restarts a cancelled, failed, or unprocessed maintenance cycle with a new schedule.

**Required parameters:**
- `MaintenanceCycleId`
- `ScheduledStartTimeInUTC`
- `MaxDurationInMinutes`

```powershell
Restart-ProvMaintenanceCycle -MaintenanceCycleId $maintenanceCycleId `
  -ScheduledStartTimeInUTC $newStartTime `
  -MaxDurationInMinutes $newMaxDuration
```

See [Restart-MaintenanceCycle.ps1](./Restart-MaintenanceCycle.ps1)

## Update a Maintenance Cycle

Updates attributes of a pending maintenance cycle. Optionally update the VM list for OSDiskReset / IdentityDiskReset cycles.

**Required parameters:**
- `MaintenanceCycleId`
- `ProvisioningSchemeUid`

**Optional parameters:**
- `ScheduledStartTimeInUTC`
- `MaintenanceCycleDescription`
- `MaxDurationInMinutes`
- `PurgeDBAfterInDays`
- `SessionWarningTimeInMinutes`
- `SessionWarningLogOffTitle`
- `SessionWarningLogOffMessage`
- `VMName` *(for OSDiskReset / IdentityDiskReset only)*

```powershell
Update-ProvMaintenanceCycle -MaintenanceCycleId $maintenanceCycleId `
  -ScheduledStartTimeInUTC $newStartTime `
  -MaintenanceCycleDescription $newDescription `
  -MaxDurationInMinutes $newMaxDuration `
  -ProvisioningSchemeUid $provisioningSchemeUid
```

See [Update-MaintenanceCycle.ps1](./Update-MaintenanceCycle.ps1)
