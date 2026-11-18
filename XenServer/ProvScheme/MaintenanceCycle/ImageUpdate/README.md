# Maintenance Cycle — Image Update (XenServer)

Scripts for creating and querying Image Update maintenance cycles on XenServer. For common operations (cancel, delete, restart, update), see [Common](../Common/).

## Create a Maintenance Cycle

Creates an Image Update maintenance cycle using either the traditional (master image path) or decoupled (image version) workflow.

**Required parameters:**
- `ProvisioningSchemeName`
- `ScheduledStartTimeInUTC` or `-StartsNow`

**Optional parameters:**
- `MaintenanceCycleDescription`
- `MaxDurationInMinutes`
- `PurgeDBAfterInDays`
- `SessionWarningTimeInMinutes`
- `SessionWarningLogOffTitle`
- `SessionWarningLogOffMessage`
- `MasterImageVM` *(traditional workflow)*
- `ImageVersionSpecUid` *(decoupled workflow)*
- `ProvisioningSchemeVersion`

```powershell
# Traditional workflow — specify master image path
New-ProvSchemeImageUpdate `
  -ProvisioningSchemeName $provisioningSchemeName `
  -ScheduledStartTimeInUTC $startTime `
  -MasterImageVM "XDHyp:\HostingUnits\XenServerUnit\<vm-name>.vm\<snapshot-name>.snapshot" `
  -ProvisioningSchemeVersion 2

# Decoupled workflow — specify image version UID
New-ProvSchemeImageUpdate `
  -ProvisioningSchemeName $provisioningSchemeName `
  -StartsNow `
  -ImageVersionSpecUid $imageVersionSpecUid
```

See [Create-MaintenanceCycle.ps1](./Create-MaintenanceCycle.ps1)

## Get Maintenance Cycle

Retrieves maintenance cycle details with optional filters.

**Optional filter parameters:**
- `MaintenanceCycleId`
- `ProvisioningSchemeUid`
- `ProvisioningSchemeName`

```powershell
Get-ProvSchemeImageUpdate -MaintenanceCycleId $maintenanceCycleId
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
Get-ProvMaintenanceCycleVM -MaintenanceCycleId $maintenanceCycleId -MaintenanceOperation ImageUpdate
```

See [Get-MaintenanceCycleVM.ps1](./Get-MaintenanceCycleVM.ps1)
