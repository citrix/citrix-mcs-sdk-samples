# Hosting Connection Creation

This page explains the details of creating a hosting connection and associate resources on Citrix Virtual Apps and Desktops (CVAD).



## 1. Base Script: Add-HostingConnection.ps1

The `Add-HostingConnection.ps1` script facilitates the creation of a hosting connection and associated resources. It requires the following parameters:

    1. ConnectionName: The name for the new hosting connection.
    
    2. ResourceName: The name for the network resource of the hosting connection.
    
    3. ConnectionType: The type of hosting connection (e.g., "VCenter").
    
    4. HypervisorAddress: The IP address of the hypervisor.
    
    5. ZoneUid: The UID that corresponds to the Zone in which the hosting connection is associated.

    6. AdminAddress: The primary DDC address.
    
    7. UserName: Username for hypervisor access.
    
    8. StoragePaths: Names of the storages available on the hypervisor.
    
    9. NetworkPaths: Names of the networks available on the hypervisor.
    
    10. RootPath: The root path of the networks available on the hypervisor.
    
    11. Metadata: The metadata of the hosting connection.
    
    12. CustomProperties: The CustomProperties of the hosting connection.
    
    13. Scope: Administration scopes for the hosting connection.

The script can be executed with parameters as shown in the example below:

```powershell
.\Add-HostingConnection.ps1 `
    -ConnectionName "MyConnection" `
    -ResourceName "Myresource" `
    -ConnectionType "VMware" `
    -HypervisorAddress "https://0.0.0.0" `
    -ZoneUid "00000000-0000-0000-0000-000000000000" `
    -AdminAddress "MyDDC.MyDomain.local" `
    -UserName "MyUserName" `
    -StoragePaths "MyStorage.storage", "MyStorage2.storage" `
    -NetworkPaths "MyNetwork.network" `
    -RootPath "/" `
    -Metadata @{"Citrix_Orchestration_Hypervisor_Secret_Allow_Edit"="false"}
```

Administrators should tailor these parameters to fit their specific environment.



## 2. Overview of the Base Script

The base script is segmented into three key steps, providing a structured approach to catalog creation:

    1. Create a Hosting Connection.
    2. Create a Storage Resource.
    3. Create a Network Resource.


## 3. Detail of the Base Script

In this section, we dive into the specifics of each step in the base script for creating a Hosting Connection to VMware. For each step, key parameters and their roles are outlined to give you a comprehensive understanding of the process.


**Step 1: Create a Hosting Connection.**

Creates a new hypervisor connection by using New-Item and New-BrokerHypervisorConnection. 

The parameters for New-Item are described below.

    1. ConnectionType
    Specifies the type of hosting connection, e.g., "VMware".

    2. CustomProperties
    Defines the custom properties of hosting connection specific to the target hosting infrastructure.

    3. HypervisorAddress
    The IP address of the target hypervisor, e.g., @("http://xxx.xxx.xxx.xxx").

    4. Metadata
    Associates metadata with the hosting connection, e.g., @{"Citrix_Orchestration_Hypervisor_Secret_Allow_Edit"="false"}.

    5. Path
    The path for the hosting connection, e.g., @("XDHyp:\Connections\MyHostingConnection").

    6. Persist
    This parameter determines whether the hosting connection item should be permanently saved, retaining the hosting connection item even after the PowerShell session ends or the system is rebooted. 

    7. Scope
    Specifies the administration scopes applied to the hosting connection.

    8. UserName
    The username for hypervisor credentials, e.g., "root".

    9. Password
    The password for hypervisor credentials, e.g., "root".

    10. ZoneUid
    Zone Uid associated with the hosting connection.

The parameters for New-BrokerHypervisorConnection are described below.

    1. HypHypervisorConnectionUid.
    The Guid that identifies the hypervisor connection, as defined in DUM.

**Step 2: Create a Storage Resource.**

Creates a new storage tier definition for use in a subsequent New-Item operation by using New-HypStorage. The parameters for New-HypStorage are described below.

    1. JobGroup
    Specifies the JobGroup uid that is used to associate data from calls to this cmdlet with the subsequent New-Item operation.	

    2. StoragePath
    Specifies the path to the storage that will be added. For example, @("XDHyp:\Connections\MyConnection\MyStorage.storage")

    3. StorageType
    The type of the new storage tier. Currently the only storage type is TemporaryStorage.	

**Step 3: Create a Network Resource.**

Creates a new network resouce by using New-Item. The parameters for New-Item are described below.

    1. HypervisorConnectionName
    Specifies the name of the hypervisor connection given by the administrator. 

    2. JobGroup
    Specifies the JobGroup uid that is used to associate data from calls to this cmdlet with the subsequent New-Item operation.	The same job group object that used for New-HypStorage should be given. 

    3. NetworkPath
    The network path to access the network available on the hypervisor, e.g., @("XDHyp:\Connections\MyConnection\MyNetwork.network")

    4. Path
    Specifies the path of the network resource, e.g., @("XDHyp:\HostingUnits\MyNetworkResouce") 

    5. RootPath
    Specifies the path of the hosting connection, e.g., @("XDHyp:\Connections\MyConnection")

    6. StoragePath
    Specifies the path of the storage resource, e.g., @("XDHyp:\Connections\MyConnection\MyStorage.storage")



## 4. Common Errors During Operation

1. If the connection name is invalid, the error message is "New-Item : The HypervisorConnection object could not be created as an object with the same name already exists."



## 5. Reference Documents

For comprehensive information and further reading, the following resources are recommended. These include CVAD SDK documentation and other relevant references (as applicable):

1. [CVAD SDK - New-BrokerHypervisorConnection](https://developer-docs.citrix.com/en-us/citrix-virtual-apps-desktops-sdk/current-release/Broker/New-BrokerHypervisorConnection/)
2. [CVAD SDK - New-HypStorage](https://developer-docs.citrix.com/en-us/citrix-daas-sdk/HostService/New-HypStorage.html)
3. [Microsoft PowerShell SDK - New-Item](https://learn.microsoft.com/en-us/powershell/module/microsoft.powershell.management/new-item?view=powershell-7.4)
