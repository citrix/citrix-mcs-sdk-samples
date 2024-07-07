# Superseding Storage from Hosting Unit

This page outlines the base script for superseding a storage from a Hosting Unit on Citrix Virtual Apps and Desktops (CVAD). 



## 1. Base Script: Supersede-Storage.ps1

The `Supersede-Storage.ps1` script is designed to supersede a storage from an existing hosting unit. It requires the following parameters:

    1. ConnectionName: The name of the hosting connection associated with the storage.
    
    2. HostingUnitName: The name of the hosting unit from which the storage will be superseded.
    
    3. StoragePaths: The paths of the stroage to be superseded from the hosting unit.
    
    4. StorageType: The storage type to be superseded from the hosting unit.
    
    5. Superseded: Flag to indicate if the storage of the hosting unit is to be superseded.
    
    6. AdminAddress: The primary DDC address.

The script can be executed with parameters as shown in the example below:

```powershell
.\Supersede-Storage.ps1 `
    -ConnectionName "MyConnection" `
    -HostingUnitName "MyHostingUnit" `
    -StoragePaths "/Datacenter.datacenter/0.0.0.0.computeresource/MyStorage.storage", "/Datacenter.datacenter/0.0.0.0.computeresource/MyStorage2.storage" `
    -StorageType "OSStorage" `
    -Superseded $true `
    -AdminAddress "MyDDC.MyDomain.local"
```

Administrators should tailor these parameters to fit their specific environment.



## 2. Overview of the Base Script

The process of superseding a storage from a hosting unit is simplified into one key step:

    1. Supersede the Storage From the Hosting Unit.



## 3. Detail of the Base Script

This section explores each step in the base script, outlining the key parameters involved.

**Step 1: Supersede the Storage of the Hosting Unit.**

Supersede the storage of a hosting unit by using ``Set-HypHostingUnitStorage``. The parameters for ``Set-HypHostingUnitStorage`` are described below.

    1. LiteralPath.
    Specifies the path of the hosting unit, e.g., "XDHyp:\HostingUnits\MyHostingUnit"

    2. StoragePath.
    Specifies the path of storage available on the hypervisor, "XDHyp:\Connections\MyConnection\MyStorage1.storage"

    3. StorageType.
    Specifies the type of storage available on the hypervisor, e.g., "OSStorage"

    4. Superseded
    Flag to indicate if the storage of the hosting unit is to be superseded, e.g., "$true"
    

## 4. Common Errors During Operation

1. If hosting connection name, hosting unit name, or the storage name is invalid, the error message is "Set-HypHostingUnitStorage : 'Citrix.Hypervisor' resolved to more than one provider name. Possible matches include: Citrix.Host.PowerShellSnapIn\Citrix.Hypervisor Citrix.Host.Admin.V2\Citrix.Hypervisor."



## 5. Reference Documents

For comprehensive information and further reading, the following resources are recommended. These include CVAD SDK documentation and other relevant references (as applicable):

1. [CVAD SDK - Set-HypHostingUnitStorage](https://developer-docs.citrix.com/en-us/citrix-virtual-apps-desktops-sdk/current-release/HostService/Set-HypHostingUnitStorage.html)


