# Set the disk storage types
## Overview
Using MCS Provisioning, you can set the storage type of your provisioned disks. You can control the cost of provisioned machines by choosing the appropriate storage type for OS disk, identity disk and Write-back Cache (WBC) disk for your catalogs. 
If not supplied, 'pd-balanced' storage type is used for OS disk, 'pd-standard' is used for Identity and WBC disks.

To learn more about GCP Storage Types, please refer to the [GCP documentation](https://cloud.google.com/compute/docs/disks)

## How to use StorageType
In this example, we specify StorageType as pd-standard:
```powershell
$customProperties = @"
<CustomProperties xmlns="http://schemas.citrix.com/2014/xd/machinecreation" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">
<Property xsi:type="StringProperty" Name="StorageType" Value="pd-standard" />
</CustomProperties>
"@
```
Similarly, you can set storage type for Identity disk and WBC disk using custom properties 'IdentityDiskStorageType' and 'WBCDiskStorageType' respectively. 

You can also change the storage types of new VMs on an existing catalog using the Set-ProvScheme command. To update storage types of existing VMs in the catalog, use the Set-ProvVmUpdateTimeWindow command. An example is provided in the Set-StorageTypes.ps1 script. 


## Errors users may encounter during New-ProvScheme
* If invalid storage type is provided, the error would look like "Cannot find Os Disk disktype 'invalid-storage' in zones 'my-zone'".

## Errors users may encounter during Set-ProvScheme
* If the storage type is invalid, the error would look like "Set-prov scheme validation failed. Cannot find Boot disktype 'my-storage-type' in zones 'my-zone'".
