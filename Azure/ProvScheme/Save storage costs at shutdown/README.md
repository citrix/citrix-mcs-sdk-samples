# Save storage costs at shutdown (StorageTypeAtShutdown)
## Overview
Using MCS Provisioning, you can save storage costs when your machines are deallocated. 
With this feature, your persistent disks will use a lower storage type when shutdown. On power on, the disk storage type will be restored to its original type. More information on this feature can be found [here][Documentation]. **Note:** Azure has a limitation on the number of times the disk storage type can be changed per day. For more information, see Azure's documentation: https://learn.microsoft.com/en-us/azure/virtual-machines/disks-convert-types?tabs=azure-powershell#restrictions

## How to use StorageTypeAtShutdown
To configure StorageTypeAtShutdown through PowerShell, use the `StorageTypeAtShutdown` custom property available with the New-ProvScheme operation. The StorageTypeAtShutdown property is a string containing an Azure Storage Type. As of CVAD 2511, there are 3 supported values:
1. **Standard_LRS**: When your VM is shutdown, the persistent disks will use the Standard_LRS type.
2. **StandardSSD_LRS**: When your VM is shutdown, the persistent disks will use the StandardSSD_LRS type. This value is newly added for CVAD 2511.
3. **Empty** or **""**: When your VM is shutdown, the persistent disk storage type will not be updated to save costs. This is equivalent to not using the feature.

In this example, we specify `StorageTypeAtShutdown` as Standard_LRS:
```powershell
$customProperties = @"
<CustomProperties xmlns="http://schemas.citrix.com/2014/xd/machinecreation" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">
<Property xsi:type="StringProperty" Name="StorageType" Value="Premium_LRS" />
<Property xsi:type="StringProperty" Name="StorageTypeAtShutdown" Value="Standard_LRS" />
</CustomProperties>
"@
```

You can also change the StorageTypeAtShutdown configuration on an existing catalog using the Set-ProvScheme command. You can update existing VMs in the catalog using the Set-ProvVmUpdateTimeWindow command. An example is provided in the Set-StorageTypeAtShutdown.ps1 script. 

**Note**: To stop using the StorageTypeAtShutdown feature, you can use Set-ProvScheme with `StorageTypeAtShutdown` set to "".

StorageTypeAtShutdown only applies to persistent disks. Currently, this includes persisted OS and WBC disks (if MCSIO is enabled).

## Common error cases
If a user enters an invalid or unsupported value for StorageTypeAtShutdown, these errors will be caught early when running New-ProvScheme and will return helpful error messages.

1. If a user attempts to set StorageTypeAtShutdown to something other than Standard_LRS, StandardSSD_LRS, or "", they will receive an error: "Error: Invalid storage type for StorageTypeAtShutdown. Valid values are StandardLRS, StandardSSDLRS, or empty"
2. If a user attempts to set StorageTypeAtShutdown but the base storage type is ZRS, they will receive an error: "Error: StorageTypeAtShutdown is not supported for ZRS disks. The following custom properties have invalid storage type values: 'xxx'" 
3. If a user attempts to use StorageTypeAtShutdown without managed disks, they will receive an error: "Error: StorageTypeAtShutdown is not supported for unmanaged disks."

Documentation:  https://docs.citrix.com/en-us/citrix-daas/install-configure/machine-catalogs-manage/manage-machine-catalog-azure.html#change-the-storage-type-to-a-lower-tier-when-a-vm-is-shut-down 


[Documentation]: < https://docs.citrix.com/en-us/citrix-daas/install-configure/machine-catalogs-manage/manage-machine-catalog-azure.html#change-the-storage-type-to-a-lower-tier-when-a-vm-is-shut-down >