# Persist Disk
## Overview
Machine Creation Service does not persist the disks for non-persistent catalogs, but there might be a need to persist the boot disks in case of some scenarios like troubleshooting.
PersistOsDisk property is used to persist the OS disk of a machine in a non-persistent catalog. 
PersistWbc property is used to persist the write-back cache disk of a machine in a non-persistent catalog. 
Both the properties are strings, their values should be "true" or "false", and are a part of the 'CustomProperty' parameter of New-ProvScheme and Set-ProvScheme cmdlets.

## Example usage of CustomProperty
```powershell
$CustomProperties = '<CustomProperties xmlns="http://schemas.citrix.com/2014/xd/machinecreation" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">' `
+ '<Property xsi:type="StringProperty" Name="PersistOsDisk" Value="' + $PersistOsDisk +'"/>' `
+ '<Property xsi:type="StringProperty" Name="PersistWbc" Value="' + $PersistWbcDisk +'"/>' `
+ '</CustomProperties>'

 New-ProvScheme -CleanOnBoot:$isCleanOnBoot `
-ProvisioningSchemeName $provisioningSchemeName `
-HostingUnitName $hostingUnitName `
-IdentityPoolName $identityPoolName `
-InitialBatchSizeHint $numberOfVms `
-MasterImageVM $masterImageVm `
-NetworkMapping $networkMapping `
-MachineProfile $machineProfile `
-CustomProperties $customProperties `
```

These properties can be set/reset later after the catalog is created using Set-ProvScheme cmdlet.
```powershell
Set-ProvScheme -ProvisioningSchemeName $provisioningSchemeName -CustomProperties $CustomProperties
```

## Errors users may encounter during Set-ProvScheme operation
* If you are trying to set PersistOsDisk in CustomProperties for a catalog with WBC disabled, it would show error "PersistOsDisk property can be set only for non-persistent catalog with WBC enabled.".