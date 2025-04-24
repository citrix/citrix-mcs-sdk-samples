# Hosting Unit Creation

This page explains the details of creating a hosting unit on Citrix Virtual Apps and Desktops (CVAD).  

## 1. Base Script: Add-HostingUnit.ps1

The `Add-HostingUnit.ps1` script facilitates the creation of a hosting unit. It requires the following parameters:

    1. ConnectionName: The name for the new hosting connection.
    
    2. ResourceName: The name for the network resource of the hosting connection.
    
    3. StoragePaths: Names of the storages available on the hypervisor.
    
    4. NetworkPaths: Names of the networks available on the hypervisor.
    
    5. RootPath: The Root Path of the networks available on the hypervisor.
    
    6. AdminAddress: The primary DDC address.
    
    7. UseLocalStorageCaching: Flag to enable IntelliCache (local storage caching).
    
    8. GpuTypePath: The path of the vGPU available on the hypervisor.

Note: While Hosting Connections support CustomProperties, it's worth to note that Hosting Units do not utilize CustomProperties. The script can be executed with parameters as shown in the example below:

```powershell
# Create a hosting connection.
.\Add-HostingUnit.ps1 `
    -ConnectionName "MyConnection" `
    -ResourceName "Myresource" `
    -Domain "YourDomain.domain" `
    -ConnectionType "VCenter" `
    -StoragePaths "/Datacenter.datacenter/0.0.0.0.computeresource/MyStorage.storage", "/Datacenter.datacenter/0.0.0.0.computeresource/MyStorage2.storage" `
    -NetworkPaths "/Datacenter.datacenter/0.0.0.0.computeresource/VM Network.network" `
    -RootPath "/Datacenter.datacenter/0.0.0.0.computeresource" `
    -AdminAddress "MyDDC.MyDomain.local"
```

Administrators should tailor these parameters to fit their specific environment.



## 2. Overview of the Base Script

The base script is segmented into two key steps, providing a structured approach to catalog creation:

    1. Create a Storage Resource.
    2. Create a Network Resource.



## 3. Detail of the Base Script

In this section, we dive into the specifics of each step in the base script for creating a Hosting Connection to VMware. For each step, key parameters and their roles are outlined to give you a comprehensive understanding of the process.

**Step 1: Create a Storage Resource.**

Creates a new storage tier definition for use in a subsequent New-Item operation by using New-HypStorage. The parameters for New-HypStorage are described below.

    1. JobGroup
    Specifies the JobGroup uid that is used to associate data from calls to this cmdlet with the subsequent New-Item operation.	

    2. StoragePath
    Specifies the path to the storage that will be added. For example, @("XDHyp:\Connections\MyConnection\MyStorage.storage")

    3. StorageType
    The type of the new storage tier. Currently the only storage type is TemporaryStorage.	

**Step 2: Create a Network Resource.**

Creates a new network resouce by using New-Item. The parameters for New-Item are described below.

    1. HypervisorConnectionName.
    Specifies the name of the hypervisor connection given by the administrator. 

    2. JobGroup.
    Specifies the JobGroup uid that is used to associate data from calls to this cmdlet with the subsequent New-Item operation.	The same job group object that used for New-HypStorage should be given. 

    3. NetworkPath.
    The network path to access the network available on the hypervisor, e.g., @("XDHyp:\Connections\MyConnection\MyNetwork.network")

    4. Path.
    Specifies the path of the network resource, e.g., @("XDHyp:\HostingUnits\MyNetworkResouce") 

    5. RootPath.
    Specifies the path of the hosting connection, e.g., @("XDHyp:\Connections\MyConnection")

    6. StoragePath.
    Specifies the path of the storage resource, e.g., @("XDHyp:\Connections\MyConnection\MyStorage.storage")



## 4. Common Errors During Operation

1. If the connection name is invalid, the error message is "New-Item : The HypervisorConnection object not found."


## 5. Reference Documents

For comprehensive information and further reading, the following resources are recommended. These include CVAD SDK documentation and other relevant references (as applicable):

1. [CVAD SDK - New-HypStorage](https://developer-docs.citrix.com/en-us/citrix-daas-sdk/HostService/New-HypStorage.html)
2. [Microsoft PowerShell SDK - Get-ChildItem](https://learn.microsoft.com/en-us/powershell/module/microsoft.powershell.management/get-childitem?view=powershell-7.4)
3. [Microsoft PowerShell SDK - New-Item](https://learn.microsoft.com/en-us/powershell/module/microsoft.powershell.management/new-item?view=powershell-7.4)


