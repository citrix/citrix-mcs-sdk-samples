# Get Maintenance Cycle
To get the maintenance cycle created, the following parameters are optional and can be passed as a filter parameters

- `MaintenanceCycleId
- `ProvisioningSchemeUid
- `ProvisioningSchemeName

```
#real maintenance cycle guid should be passed in
$maintenanceCycleId = "00000000-0000-0000-0000-000000000000"
#real provisioning scheme guid should be passed in
$provisioningSchemeUid = "00000000-0000-0000-0000-000000000000"
$provisioningSchemeName = "ScaleTest"

###############################################################
# Gets Provisioning Maintenance Cycle for maintenance cycle id
###############################################################
Get-ProvSchemeHardwareUpdate -MaintenanceCycleId $maintenanceCycleId -ProvisioningSchemeName $provisioningSchemeName -ProvisioningSchemeUid $provisioningSchemeUid
```
