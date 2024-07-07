# Removing Storage from Hosting Unit

This page outlines the base script for removing a storage from a Hosting Unit on Citrix Virtual Apps and Desktops (CVAD). 



## 1. Base Script: Remove-Storage.ps1

The `Remove-Storage.ps1` script is designed to remove a storage from existing hosting unit. It requires the following parameters:

    1. ConnectionName: The name of the hosting connection associated with the storage.
    
    2. HostingUnitName: The name of the hosting unit which the storage will be removed.
    
    3. StoragePaths: The paths of the stroage to be removed from the hosting unit.
    
    4. StorageType: The storage type to be removed from the hosting unit.
    
    5. AdminAddress: The primary DDC address.

The script can be executed with parameters as shown in the example below:

```powershell
.\Remove-Storage.ps1 `
    -ConnectionName "MyConnection" `
    -HostingUnitName "MyHostingUnit" `
    -StoragePaths "MyStorage1.storage" `
    -StorageType "OSStorage" `
    -AdminAddress "MyDDC.MyDomain.local"
```

Administrators should tailor these parameters to fit their specific environment.



## 2. Overview of the Base Script

The process of removing a storage from a hosting unit is simplified into one key step:

    1. Remove the Storage From the Hosting Unit.



## 3. Detail of the Base Script

This section explores each step in the base script, outlining the key parameters involved.

**Step 1: Remove the Storage From the Hosting Unit.**

Remove storage from the hosting unit by using ``Remove-HypHostingUnitStorage``. The parameters for ``Remove-HypHostingUnitStorage`` are described below.

    1. LiteralPath.
    Specifies the path of the hosting unit, e.g., "XDHyp:\HostingUnits\MyHostingUnit"

    2. StoragePath.
    Specifies the path of storage available on the hypervisor, "XDHyp:\Connections\MyConnection\MyStorage1.storage"

    3. StorageType.
    Specifies the type of storage available on the hypervisor, e.g., "OSStorage"
    


## 4. Common Errors During Operation

1. If hosting connection name, hosting unit name, or the storage name is invalid, the error message is "Remove-HypHostingUnitStorage : 'Citrix.Hypervisor' resolved to more than one provider name. Possible matches include: Citrix.Host.PowerShellSnapIn\Citrix.Hypervisor Citrix.Host.Admin.V2\Citrix.Hypervisor."



## 5. Reference Documents

For comprehensive information and further reading, the following resources are recommended. These include CVAD SDK documentation and other relevant references (as applicable):

1. [CVAD SDK - Remove-HypHostingUnitStorage](https://developer-docs.citrix.com/en-us/citrix-virtual-apps-desktops-sdk/current-release/HostService/Remove-HypHostingUnitStorage.html)


