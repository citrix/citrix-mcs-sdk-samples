# Maintenance Cycle — Hardware Scheme Update (XenServer)

Scripts for creating and querying Hardware Scheme Update maintenance cycles on XenServer. For common operations (cancel, delete, restart, update), see [Common](../Common/). For scheme history, see [SchemeHistory](../SchemeHistory/).

## End-to-End Examples

| Scenario | Script |
|----------|--------|
| Update CPU and Memory | [Update-CpuAndMemoryWithServiceWindow.ps1](./Update-CpuAndMemoryWithServiceWindow.ps1) |
| Update Persistent Catalog | [Update-PersistentCatalogWithServiceWindow.ps1](./Update-PersistentCatalogWithServiceWindow.ps1) |
| Validate Before Update | [Validate-ConfigurationBeforeUpdate.ps1](./Validate-ConfigurationBeforeUpdate.ps1) |
| Verify Disk Preservation | [Verify-DiskPreservationAfterHardwareUpdate.ps1](./Verify-DiskPreservationAfterHardwareUpdate.ps1) |
| Verify Old VM Cleanup | [Verify-OldVMCleanupAfterUpdate.ps1](./Verify-OldVMCleanupAfterUpdate.ps1) |

## Create a Maintenance Cycle

Creates a Hardware Scheme Update maintenance cycle for all VMs or new VMs only.

**Required parameters:**
- `ProvisioningSchemeName`
- `ScheduledStartTimeInUTC` or `-StartsNow`
- `-AllVMs` or `-NewVMs`
- `ProvisioningSchemeVersion`

**Optional parameters:**
- `MaintenanceCycleDescription`
- `MaxDurationInMinutes`
- `PurgeDBAfterInDays`
- `SessionWarningTimeInMinutes`
- `SessionWarningLogOffTitle`
- `SessionWarningLogOffMessage`

```powershell
New-ProvSchemeHardwareUpdate -AllVMs `
  -ProvisioningSchemeName $provisioningSchemeName `
  -ScheduledStartTimeInUTC $startTime `
  -ProvisioningSchemeVersion 2
```

See [Create-MaintenanceCycle.ps1](./Create-MaintenanceCycle.ps1)

## Apply Hardware Update to a Single VM

Targets a single VM by AD account SID. Useful for testing the update on one machine before rolling out to the full catalog.

```powershell
$testVM = Get-BrokerMachine -DNSName "your-vm-name.domain.local"

New-ProvVmHardwareUpdate `
  -ProvisioningSchemeName $provisioningSchemeName `
  -ScheduledStartTimeInUTC $startTime `
  -ProvisioningSchemeVersion 2 `
  -ADAccountSid $($testVM.SID)
```

## Get Maintenance Cycle

Retrieves maintenance cycle details with optional filters.

```powershell
Get-ProvSchemeHardwareUpdate -MaintenanceCycleId $maintenanceCycleId
```

See [Get-MaintenanceCycle.ps1](./Get-MaintenanceCycle.ps1)

## Get Maintenance Cycle VM Instances

Retrieves per-VM status for a maintenance cycle.

```powershell
Get-ProvMaintenanceCycleVM -MaintenanceCycleId $maintenanceCycleId -MaintenanceOperation HardwareUpdate
```

See [Get-MaintenanceCycleVM.ps1](./Get-MaintenanceCycleVM.ps1)

## Updating Hardware Configuration

Before creating a Hardware Update maintenance cycle, create a new provisioning scheme version with the desired hardware configuration using `New-ProvSchemeVersion`.

### Create Scheme Version

Creates a new provisioning scheme version with modified hardware properties.

**Required parameters:**
- `ProvisioningSchemeName`

**At least one of:**
- `CpuCount`
- `MemoryMB`
- `MachineProfile`
- `CustomProperties`
- `NetworkMapping`
- `WriteBackCacheDiskSize`
- `WriteBackCacheMemorySize`

```powershell
# Update CPU and memory
New-ProvSchemeVersion -ProvisioningSchemeName $provisioningSchemeName `
  -CpuCount 8 `
  -MemoryMB 8192

# Update machine profile
New-ProvSchemeVersion -ProvisioningSchemeName $provisioningSchemeName `
  -MachineProfile "XDHyp:\HostingUnits\XenServerUnit\<profile-vm>.vm"

# Update custom properties
New-ProvSchemeVersion -ProvisioningSchemeName $provisioningSchemeName `
  -ConfigurationInfo $ConfigurationInfo `
  -CustomProperties $CustomProperties
```

See [Create-SchemeVersion.ps1](./Create-SchemeVersion.ps1)

### Get Scheme Version

```powershell
Get-ProvSchemeVersion -ProvisioningSchemeName $provisioningSchemeName -Version $Version
```

See [Get-SchemeVersion.ps1](./Get-SchemeVersion.ps1)

### Delete Scheme Version

Removes an inactive scheme version.

```powershell
Remove-ProvSchemeVersion -ProvisioningSchemeName $provisioningSchemeName -Version $Version
```

See [Remove-SchemeVersion.ps1](./Remove-SchemeVersion.ps1)
