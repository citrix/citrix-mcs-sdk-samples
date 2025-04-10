# DataDisk Feature during Catalog Creation
This page describes the use of Azure's Data Disk feature while creating a ProvScheme in Citrix Virtual Apps and Desktops (CVAD). The script [Create-ProvScheme-DataDisk.ps1](./Create-ProvScheme-DataDisk.ps1) shows an example usage of `New-ProvScheme` with the Data Disk Feature. Use [Create-ProvScheme.ps1](../Create%20ProvScheme/Create-ProvScheme.ps1) to use it with other parameters. 

## 1. Feature Description

You can create and assign a persistent data disk to an MCS created persistent or non-persistent VM of an MCS machine catalog in Azure.
The data disk must be provisioned from a managed disk as an image source.

## 2. How to use DataDisk Feature
To provision a MCS machine catalog with data disk, include the following parameters in the New-ProvScheme PowerShell command.
1. **DataDisk**: Path to a valid ManagedDisk type of inventory item. Other source types such as snapshot or gallery image are not allowed. For example:
```powershell
$datadisk = "XDHyp:\HostingUnits\$hostingUnitName\image.folder\$resourceGroupName.resourcegroup\xxxx-datadisk.manageddisk"
```
2. **DataDiskPersistence**: To indicate whether the DataDisk is persistent or non-persistent. However, currently, only persistent data disks are supported. For example:
```powershell
$datadiskPersistence = "Persistent"
```

When using New-ProvScheme, specify the `-DataDisk` and `-DataDiskPersistence` parameters as follows:
```powershell
New-ProvScheme -CleanOnBoot:$isCleanOnBoot 
-ProvisioningSchemeName $provisioningSchemeName 
-HostingUnitName $hostingUnitName 
-IdentityPoolName $identityPoolName 
-InitialBatchSizeHint $numberOfVms 
-MasterImageVM $masterImageVm 
-NetworkMapping $networkMapping 
-CustomProperties $customProperties 
-MachineProfile $machineProfile 
-DataDisk $datadisk 
-DataDiskPersistence $datadiskPersistence
```

**Note**: DataDisk can only be enabled for new catalogs. We currently do no support enabling it for existing catalogs or VMs.

## 3. DataDisk Properties
The data disk derives properties from custom properties or OS disk template if the properties are not specified in the custom properties.

Properties derived from custom properties:
  1. DiskEncryptionSetId
  2. Zones
  3. StorageType

Properties derived from OS disk template if not specified in custom properties
  1. DiskEncryptionSetId
  2. Zones
  3. StorageType
  
**Note**: If Zone Redundant Storage (ZRS) is not specified in custom properties or OS disk template, then the data disk is placed in the same zone as the OS disk and Identity disk.
Tags are derived only from the OS disk template.
  
## 4. Limitations
The following operations are currently not supported:

  1. Provisioning of more than one data disk.
  2. Provisioning of non-persistent data disks.
  3. Creating a data disk with a template.
  4. Modifying existing catalogs and VMs to use data disks.
  5. Resetting the data disk.
  6. Image update of the data disk.
  7. Using a source other than a managed disk. 
  8. Storing data disk in Azure Compute Gallery (ACG).
  9. Using StorageTypeAtShutdown for the data disk

Documentation:  
https://docs.citrix.com/en-us/citrix-daas/install-configure/machine-catalogs-create/create-machine-catalog-citrix-azure#provision-data-disk
