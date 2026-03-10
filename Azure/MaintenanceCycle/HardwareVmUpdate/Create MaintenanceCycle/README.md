# Create Maintenance Cycle
To create a Maintenance Cycle for Hardware Update, the following parameters are required:
- `ProvisioningSchemeName`
- `StartTimeForMaintenanceCycle`

The following parameters are optional
- `Description` 
- `MaxDurationInMinutes`
- `DataToBeStoredInDB`
- `SessionWarningTimeInMinutes`
- `SessionWarningLogOffTitle`
- `SessionWarningLogOffMessage`

Create the Hardware Update Maintenance Cycle with `New-ProvVmHardwareUpdate`
```powershell
#####################
# Prepare Parameters
#####################
$provisioningSchemeName = "test"
#real ADAccountsid should be passed in
$accountSid = "00000000-0000-0000-0000-000000000000"
$startTimeForMaintenanceCycle = [datetime]::SpecifyKind([datetime]'2025-11-15 22:14:33', 'utc')
$description = "Updating cpu count of the machine on 15th Novembers from 4 to 8"
$maxDurationInMinutes = 100
$dataToBeStoredInDB = 30
$sessionWarningTimeInMinutes = 45
$SessionWarningLogOffTitle = "Confirming Maintenance Alert"
$SessionWarningLogOffMessage = "Your workstation will soon be turned down for maintenance work, please save any data"

##################################################################################
# Create Provisioning Maintenance Cycle for changing ProvisionedVmConfiguration
##################################################################################
New-ProvVmHardwareUpdate
  -ProvisioningSchemeName $provisioningSchemeName `
  -ScheduledStartTimeInUTC $startTimeForMaintenanceCycle `
  -MaintenanceCycleDescription $description `
  -MaxDurationInMinutes $maxDurationInMinutes `
  -PurgeDBAfterInDays $dataToBeStoredInDB `
  -SessionWarningTimeInMinutes $sessionWarningTimeInMinutes `
  -SessionWarningLogOffTitle $SessionWarningLogOffTitle `
  -SessionWarningLogOffMessage $SessionWarningLogOffMessage `
  -ProvisionedVmConfiguration 4
  -ADAccountSid $accountSid

##################################################################################################
# Create Provisioning Maintenance Cycle for changing provisioning scheme version and starting now
##################################################################################################
New-ProvVmHardwareUpdate
  -ProvisioningSchemeName $provisioningSchemeName `
  -StartsNow`
  -MaintenanceCycleDescription $description `
  -MaxDurationInMinutes $maxDurationInMinutes `
  -PurgeDBAfterInDays $dataToBeStoredInDB `
  -SessionWarningTimeInMinutes $sessionWarningTimeInMinutes `
  -SessionWarningLogOffTitle $SessionWarningLogOffTitle `
  -SessionWarningLogOffMessage $SessionWarningLogOffMessage `
  -ProvisioningSchemeVersion 2
  -ADAccountSid $accountSid