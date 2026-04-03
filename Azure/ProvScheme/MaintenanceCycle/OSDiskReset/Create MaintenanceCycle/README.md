# Create Maintenance Cycle
To create a Maintenance Cycle for OS Disk Reset, the following parameters are required:
- `ProvisioningSchemeName`
- `StartTimeForMaintenanceCycle`
- `Operation`

The following parameters are optional
- `Description` 
- `MaxDurationInMinutes`
- `DataToBeStoredInDB`
- `SessionWarningTimeInMinutes`
- `SessionWarningLogOffTitle`
- `SessionWarningLogOffMessage`

Create the OS Disk Reset Maintenance Cycle with `New-ProvMaintenanceCycle`
```powershell
$provisioningSchemeName = "test"
$startTimeForMaintenanceCycle = [datetime]::SpecifyKind([datetime]'2025-11-15 22:14:33', 'utc')
$description = "Resetting the OS disk of all virtual machines on 15th Novembers"
$maxDurationInMinutes = 100
$dataToBeStoredInDB = 30
$sessionWarningTimeInMinutes = 45
$SessionWarningLogOffTitle = "Confirming Maintenance Alert"
$SessionWarningLogOffMessage = "Your workstation will soon be turned down for maintenance work, please save any data"

####################################################
# Create Provisioning Maintenance Cycle for all vms
####################################################
New-ProvMaintenanceCycle -AllVMs `
  -ProvisioningSchemeName $provisioningSchemeName `
  -ScheduledStartTimeInUTC $startTimeForMaintenanceCycle `
  -Operation ResetOSDisk `
  -MaintenanceCycleDescription $description `
  -MaxDurationInMinutes $maxDurationInMinutes `
  -PurgeDBAfterInDays $dataToBeStoredInDB `
  -SessionWarningTimeInMinutes $sessionWarningTimeInMinutes `
  -SessionWarningLogOffTitle $SessionWarningLogOffTitle `
  -SessionWarningLogOffMessage $SessionWarningLogOffMessage

########################################################
# Create Provisioning Maintenance Cycle for list of vms
########################################################
New-ProvMaintenanceCycle -VMName reset03, reset05 `
  -ProvisioningSchemeName $provisioningSchemeName `
  -ScheduledStartTimeInUTC $startTimeForMaintenanceCycle `
  -Operation ResetOSDisk `
  -MaintenanceCycleDescription $description `
  -MaxDurationInMinutes $maxDurationInMinutes `
  -PurgeDBAfterInDays $dataToBeStoredInDB `
  -SessionWarningTimeInMinutes $sessionWarningTimeInMinutes `
  -SessionWarningLogOffTitle $SessionWarningLogOffTitle `
  -SessionWarningLogOffMessage $SessionWarningLogOffMessage
```