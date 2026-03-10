# Get Maintenance Cycle Vm instances
To get the maintenance cycle vm instances created, the following parameters are optional and can be passed as a filter parameters

- `MaintenanceCycleId
- `VirtualMachineSid
- `OperationType
- `Status

```
#real maintenance cycle guid should be passed in
$maintenanceCycleId = "00000000-0000-0000-0000-000000000000"
#real virtual machine sid should be passed in
$virtualMachineSid = "00000000-0000-0000-0000-000000000000"
$operationType = ResetOSDisk
$Status = "Completed"

#####################################################################################
# Gets Provisioning Maintenance Cycle virtual machine info for maintenance cycle id
#####################################################################################
Get-ProvMaintenanceCycleVM -MaintenanceCycleId $maintenanceCycleId -VirtualMachineSid $virtualMachineSid -MaintenanceOperation $operationType -MaintenanceStatus $Status
```
