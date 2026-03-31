#Update a maintenance Cycle
To update a pending maintenance Cycle

The following parameters are required
- `MaintenanceCycleId
- `ProvisioningSchemeUid = "00000000-0000-0000-0000-000000000000"

The following parameters are optional
- `NewStartTimeForMaintenanceCycle
- `NewDescription
- `NewMaxDurationInMinutes
- `NewDataToBeStoredInDB
- `NewSessionWarningTimeInMinutes
- `NewSessionWarningLogOffTitle
- `NewSessionWarningLogOffMessage

```
#real maintenance cycle guid should be passed in
$maintenanceCycleId = "00000000-0000-0000-0000-000000000000"
#real provisioning scheme guid should be passed in
$provisioningSchemeUid = "00000000-0000-0000-0000-000000000000"
$newStartTimeForMaintenanceCycle = [datetime]::SpecifyKind([datetime]'2025-11-24 22:14:33', 'utc')
$newDescription = "Updating cpu counts on 24th November"
$newMaxDurationInMinutes = 400
$newDataToBeStoredInDB = 40
$newSessionWarningTimeInMinutes = 100
$newSessionWarningLogOffTitle = "Confirming Maintenance Alert - Sunday"
$newSessionWarningLogOffMessage = "Your workstation will soon be turned down for maintenance work, please save any data to avoid data loss"

#####################################################################################
# Updates a Provisioning Maintenance Cycle with new list of vms and other attributes
#####################################################################################
#real maintenance cycle guid should be passed in
Update-ProvMaintenanceCycle -MaintenanceCycleId $maintenanceCycleId `
  -ScheduledStartTimeInUTC $newStartTimeForMaintenanceCycle `
  -MaintenanceCycleDescription $newDescription `
  -MaxDurationInMinutes $newMaxDurationInMinutes `
  -PurgeDBAfterInDays $newDataToBeStoredInDB `
  -SessionWarningTimeInMinutes $newSessionWarningTimeInMinutes `
  -SessionWarningLogOffTitle $newSessionWarningLogOffTitle `
  -SessionWarningLogOffMessage $newSessionWarningLogOffMessage `
  -ProvisioningSchemeUid $provisioningSchemeUid
```