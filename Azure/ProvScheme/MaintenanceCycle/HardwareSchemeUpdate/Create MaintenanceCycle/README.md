# Create Maintenance Cycle
To create a Maintenance Cycle Hardware Update, the following parameters are required:
- `ProvisioningSchemeName`
- `StartTimeForMaintenanceCycle`

The following parameters are optional
- `Description` 
- `MaxDurationInMinutes`
- `DataToBeStoredInDB`
- `SessionWarningTimeInMinutes`
- `SessionWarningLogOffTitle`
- `SessionWarningLogOffMessage`

Create the Hardware Update Maintenance Cycle with `New-ProvSchemeHardwareUpdate`
```powershell
$provisioningSchemeName = "test"
$startTimeForMaintenanceCycle = [datetime]::SpecifyKind([datetime]'2025-11-15 22:14:33', 'utc')
$description = "Updating cpu counts of all virtual machines on 15th Novembers from 4 to 8"
$maxDurationInMinutes = 100
$dataToBeStoredInDB = 30
$sessionWarningTimeInMinutes = 45
$SessionWarningLogOffTitle = "Confirming Maintenance Alert"
$SessionWarningLogOffMessage = "Your workstation will soon be turned down for maintenance work, please save any data"

####################################################
# Create Provisioning Maintenance Cycle for all vms
####################################################
New-ProvSchemeHardwareUpdate -AllVMs `
  -ProvisioningSchemeName $provisioningSchemeName `
  -ScheduledStartTimeInUTC $startTimeForMaintenanceCycle `
  -MaintenanceCycleDescription $description `
  -MaxDurationInMinutes $maxDurationInMinutes `
  -PurgeDBAfterInDays $dataToBeStoredInDB `
  -SessionWarningTimeInMinutes $sessionWarningTimeInMinutes `
  -SessionWarningLogOffTitle $SessionWarningLogOffTitle `
  -SessionWarningLogOffMessage $SessionWarningLogOffMessage `
  -ProvisioningSchemeVersion 2

###########################################################################
# Create Provisioning Maintenance Cycle for new vms only and starting now
###########################################################################
New-ProvSchemeHardwareUpdate -NewVMs `
  -ProvisioningSchemeName $provisioningSchemeName `
  -StartsNow`
  -MaintenanceCycleDescription $description `
  -MaxDurationInMinutes $maxDurationInMinutes `
  -PurgeDBAfterInDays $dataToBeStoredInDB `
  -SessionWarningTimeInMinutes $sessionWarningTimeInMinutes `
  -SessionWarningLogOffTitle $SessionWarningLogOffTitle `
  -SessionWarningLogOffMessage $SessionWarningLogOffMessage `
  -ProvisioningSchemeVersion 2
```