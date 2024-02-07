# Set the disk storage type (StorageType)
## Overview
Using MCS Provisioning, you can set the storage type of your provisioned disks. If not supplied, the Standard_LRS storage type is used.

To learn more about Azure Storage Types, please see Azure's documentation: https://learn.microsoft.com/en-us/azure/virtual-machines/disks-types

## How to use StorageType
To configure StorageType through PowerShell, use the `StorageType` custom property available with the New-ProvScheme operation. The StorageType property is a string containing an Azure Storage Type. Currently, supported storage types include:
1. Standard_LRS
2. Premium_LRS
3. StandardSSD_LRS
4. StandardSSD_ZRS
5. Premium_ZRS

If not supplied, Standard_LRS is used by default.

In this example, we specify StorageType as Premium_LRS:
```powershell
$customProperties = @"
<CustomProperties xmlns="http://schemas.citrix.com/2014/xd/machinecreation" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">
<Property xsi:type="StringProperty" Name="StorageType" Value="Premium_LRS" />
</CustomProperties>
"@
```
**Note**: This storage type will be applied to your OsDisk and WbcDisk. Setting this property will not change the storage type of the identity disk. A separate custom property called IdentityDiskStorageType can be used to set the identity disk storage type.

You can also change the StorageType configuration on an existing catalog using the Set-ProvScheme command. You can update existing VMs in the catalog using the Set-ProvVmUpdateTimeWindow command. An example is provided in the Set-StorageType.ps1 script. 

## Common error cases
If a user enters an invalid or unsupported value for StorageType, these errors will be caught early when running New-ProvScheme and will return helpful error messages.

1. If a user attempts to use an unknown or unsupported StorageType, they will receive an error: "Error: The following custom properties have invalid storage type values: 'xxx'" 
2. If a user attempts to set StorageType to ZRS but ZRS is not supported in the region, they will receive an error: "Error: The following custom properties have storage type values that are not supported in the specified region: 'xxx'"
3. If a user attempts to set StorageType to ZRS without managed disks, they will receive an error: "Error: ZRS Disk Storage must be used with Azure Managed Disks"

Documentation: 
https://developer-docs.citrix.com/en-us/citrix-virtual-apps-desktops-sdk/current-release/MachineCreation/about_Prov_CustomProperties.html#custom-properties-for-azure