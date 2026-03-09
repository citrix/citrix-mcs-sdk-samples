#Restart a maintenance Cycle
To restart a cancelled/failed/not processed maintenance Cycle

The following parameters are required
- `MaintenanceCycleId
- `NewStartTime
- `NewMaxDuration

```
#real maintenance cycle guid should be passed in
$maintenanceCycleId = "00000000-0000-0000-0000-000000000000"
$newStartTime = [datetime]::SpecifyKind([datetime]'2025-11-18 22:14:33', 'utc')
$newMaxDuration = 400

####################################################
# Restarts Provisioning Maintenance Cycle
####################################################
Restart-ProvMaintenanceCycle -MaintenanceCycleId $maintenanceCycleId -ScheduledStartTimeInUTC $newStartTime -MaxDurationInMinutes $newMaxDuration
```
