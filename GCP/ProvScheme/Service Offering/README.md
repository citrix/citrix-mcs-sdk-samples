# Service Offering
## Overview
The Citrix-specific resource "Service Offering" is equivalent to machine types in GCP. Machine types determine physical specification of machines such as the amount of memory, type of processor, number of virtual cores, and accelerator to use. You should choose the right machine type depending on the intended use e.g. compute optimized, storage optimized etc. To know more about GCP machine types, please refer to the [GCP documentation](https://cloud.google.com/compute/docs/machine-resource).
You can specify the machine type while creating a new catalog. The machine type that you specify is used for all the machines that are created from the catalog. You can also modify the machine type of a catalog that is already created. 

## How to use ServiceOffering
When using New-ProvScheme or Set-ProvScheme, you should specify a new parameter: `-ServiceOffering`. The ServiceOffering parameter is a string containing a Citrix inventory item path. 

```powershell
New-ProvScheme -CleanOnBoot:$isCleanOnBoot 
-ProvisioningSchemeName $provisioningSchemeName 
-HostingUnitName $hostingUnitName 
-IdentityPoolName $identityPoolName 
-InitialBatchSizeHint $numberOfVms 
-MasterImageVM $masterImageVm 
-NetworkMapping $networkMapping
-MachineProfile $machineProfile
-ServiceOffering $serviceOfferingPath
```

To list all the service offering inventory items, use below command-
```powershell
Get-ChildItem "XDHyp:\HostingUnits\GcpHostingUnitName\machineTypes.folder"
```

To see details of a specific service offering, use below command. e.g to view details of n2-standard-4 machinetype -
```powershell
$machineType = Get-Item XDHyp:\HostingUnits\GcpHostingUnitName\machineTypes.folder\n2-standard-4.serviceoffering
$machineType.AdditionalData
```

## Troubleshooting Create ProvScheme
If, for some reason, New-ProvScheme fails, you might see an error message from the New-BrokerCatalog command "New-BrokerCatalog : Invalid provisioning scheme". This error message indicates that provScheme was never created hence the ProvisioningSchemeId parameter is null. To understand what caused the failure in New-ProvScheme, you can try executing the script without the New-BrokerCatalog command.
* If the service offering is invalid, you would see an error - "No MachineType named 'my-invalid-machine-type' was found in the MachineTypes of project ID 'my-project-id'".

## Troubleshooting Set ProvScheme
* If the service offering is invalid, you would see an error - "Set-prov scheme validation failed".
* If the Provisioning scheme does not exist/invalid, you would see an error - "The specified ProvisioningScheme could not be located."