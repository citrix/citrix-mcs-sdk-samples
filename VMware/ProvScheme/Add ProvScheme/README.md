# Creating a Provisioning Scheme

This page outlines the base script for creating a Provisioning Scheme on Citrix Virtual Apps and Desktops (CVAD). 


## 1. Base Script: Add-ProvScheme.ps1

The `Add-ProvScheme.ps1` script creates a Machine Catalog and requires the following parameters

    1. ProvisioningSchemeName: Name of the new provisioning scheme.
    
    2. HostingUnitName: Name of the hosting unit used.
    
    3. IdentityPoolName: Name of the Identity Pool used.
    
    4. ProvisioningSchemeType: The Provisioning Scheme Type.
    
    5. MasterImageVM: Path to VM snapshot or template.
    
    6. CustomProperties: Specific properties for the hosting infrastructure.
    
    7. NetworkMapping: Specifies how the attached NICs are mapped to networks.
    
    8. VMCpuCount: The number of processors that will be used to create VMs from the provisioning scheme.
    
    9. VMMemoryMB: The maximum amount of memory that will be used to created VMs from the provisioning scheme in MB.
    
    10. InitialBatchSizeHint: The number of initial VMs that will be added to the MCS catalog.
    
    11. Scope: Administration scopes for the identity pool.
    
    12. CleanOnBoot: Reset VMs to initial state on start.
    
    13. AdminAddress: The primary DDC address.
    
    14. UseFullDiskCloneProvisioning: This flag enables the use of Full Clone provisioning.
    
    15. UseWriteBackCache: A flag to enable the Write-Back Cache feature. This should be set to True to enable the 
    Write-Back Cache.
    
    16. WriteBackCacheDiskSize: Specifies the disk size of the Write-Back Cache.
    
    17. WriteBackCacheMemorySize: Defines the memory size of the Write-Back Cache.
    
    18. WriteBackCacheDriveLetter: Assigns the drive letter for the Write-Back Cache disk.
    
    19. DataDiskPersistence: Sets disk persistence for the data disk. Supported Values: 'Persistent' and 'NonPersistent'.
    
It's important to note the usage of the `CleanOnBoot` parameter: Set this to `$True` for creating `a non-persistent catalog` where VMs revert to their original state at each reboot. For `a persistent catalog` where changes are maintained, set it to `$False`.

The script can be executed with parameters as shown in the example below:

```powershell
.\Add-ProvScheme.ps1 `
    -ProvisioningSchemeName "MyMachineCatalog" `
    -HostingUnitName "MyHostingUnit" `
    -IdentityPoolName "MyMachineCatalog" `
    -ProvisioningSchemeType "MCS" `
    -MasterImageVM "XDHyp:\HostingUnits\MyHostingUnit\MyVM.vm\MySnapshot.snapshot" `
    -CustomProperties "" `
    -NetworkMapping @{"0"="XDHyp:\HostingUnits\MyHostingUnit\MyNetwork.network"} `
    -VMCpuCount 1 `
    -VMMemoryMB 1024 `
    -Scope @() `
    -InitialBatchSizeHint 1 `
    -CleanOnBoot:$true `
    -AdminAddress "MyDDC.MyDomain.local"
```

Administrators should tailor these parameters to fit their specific environment.



## 2. Overview of the Base Script

The base script is segmented into the following key steps, providing a structured approach to ProvScheme creation:

    1. Create a New Provisioning Scheme.
       1. Adds feature specific parameters passed in the script
    


## 3. Detail of the Base Script

In this section, we dive into the specifics of each step in the base script for creating a Provisioning Scheme. For each step, key parameters and their roles are outlined to give you a comprehensive understanding of the process.

**Step 1: Create a Provisioning Scheme.**

Creating a provisioning scheme for managing virtual machines by using New-ProvScheme. The parameters for New-ProvScheme are described below.

    1. ProvisioningSchemeName.
    The name of the provisioning scheme to be created. This must not be a name that is being used by an existing provisioning scheme, and must not contain any of the following characters \/;:#.*?=<>|[]()””’	

    2. HostingUnitName.
    The name of the hosting unit to be used for the provisioning scheme.	

    3. IdentityPoolName.
    The name of the identity pool to be used for the provisioning scheme.	

    4. ProvisioningSchemeType.
    The type of Provisioning Scheme to created. The default type is MCS. Values can be:
    - PVS: Machine provisioned by PVS (machine may be physical, blade, VM, etc). 
    - MCS: Machine provisioned by MCS (machine must be VM).
    
    5. MasterImageVM.
    The path in the hosting unit provider to the VM snapshot or template that will be used. This identifies the hard disk to be used and the default values for the memory and processors. This must be a path to a Snapshot or Template item in the same hosting unit specified by HostingUnitName or HostingUnitUid. Valid paths are of the format:	

    6. CleanOnBoot.
    Indicates whether the VMs created from this provisioning scheme are reset to their initial condition each time they are started.

    7. UseWriteBackCache.
    Indicates whether write-back cache is enabled for the VMs created from this provisioning scheme. Use additional parameters to configure the write-back cache. 
    
    8. WriteBackCacheDiskSize.
    The size in GB of any temporary storage disk used by the write-back cache. Should be used in conjunction with WriteBackCacheMemorySize. 

    9. WriteBackCacheMemorySize.
    The size in MB of any write-back cache if required. Should be used in conjunction with WriteBackCacheDiskSize. Setting RAM Cache to 0 but specifying Disk Cache effectively disables the RAM Cache. However, there will be some memory still used to allow the I/O Optimization to operate.

    10. WriteBackCacheDriveLetter. 
    The customized drive letter of write-back cache disk which can be any character between ‘E’ and ‘Z’. If not specified, the drive letter is auto assigned by operating system, i.e. generally ‘D’, but ‘E’ when ‘D’ is assigned to other disk like Azure temp disk. It only works with VDA 2305 or higher.

    11. CustomProperties.
    The properties of the provisioning scheme that are specific to the target hosting infrastructure. See about_ProvCustomProperties for more information.	

    12. MachineProfile.
    Currently only supported with Azure. Defines the inventory path to the source VM used by the provisioning scheme as a template. This profile identifies the properties for the VMs created from the scheme. The VM must be in the hosting unit that HostingUnitName or HostingUnitUid refers to. If any properties are present in the MachineProfile but not the CustomProperties, values from the template will be written back to the CustomProperties.	

    13. VMCpuCount.
    The number of processors that will be used to create VMs from the provisioning scheme.	

    14. VMMemoryMB.
    The maximum amount of memory that will be used to created VMs from the provisioning scheme in MB.	

    15. NetworkMapping.
    Specifies how the attached NICs are mapped to networks. If this parameter is omitted, VMs are created with a single NIC, which is mapped to the default network in the hosting unit. If this parameter is supplied, machines are created with the number of NICs specified in the map, and each NIC is attached to the specified network.	

    16. InitialBatchSizeHint.
    Provides a predictive hint for the number of initial VMs that will be added to the MCS catalog when the scheme is successfully created. Callers should supply this parameter in situations where the completion of New-ProvScheme will be closely followed by a New-ProvVM call to create an initial batch of VMs in the catalog.	

    17. DataDiskPersistence.
    Supported Values: 'Persistent' and 'NonPersistent'.
    Indicates whether the changes to the disk contents of the Prov-VMs will persist accross reboot.
    When the value to this parameter is set to 'Persistent' or 'NonPersistent', the data disk created will have 'Dependent' or 'Independent - Nonpersistent' Disk Mode in VMware respectively.

    18. Scope
    The administration scopes to be applied to the new provisioning scheme.	



## 4. Specialized Scenario - Using Full Clone:

Utilizing the Full Clone feature, necessitates the following additional parameters for its operation:

    1. CleanOnBoot: A flag to set non-persistent catalog, ensuring VMs are reset to their baseline state at each startup. This should be set to false to enable the Full Clone feature.
    2. UseFullDiskCloneProvisioning: Indicates whether VMs should be created using the dedicated full disk clone feature. By default, the Fast Clone approach is used unless this parameter is explicitly set to enable Full Clone.
    
The script can be executed with parameters as shown in the example below:

```powershell
.\Add-ProvScheme.ps1 `
    -ProvisioningSchemeName "MyMachineCatalog" `
    -HostingUnitName "MyHostingUnit" `
    -IdentityPoolName "MyMachineCatalog" `
    -ProvisioningSchemeType "MCS" `
    -MasterImageVM "XDHyp:\HostingUnits\MyHostingUnit\MyVM.vm\MySnapshot.snapshot" `
    -CustomProperties "" `
    -NetworkMapping @{"0"="XDHyp:\HostingUnits\MyHostingUnit\MyNetwork.network"} `
    -VMCpuCount 1 `
    -VMMemoryMB 1024 `
    -Scope @() `
    -InitialBatchSizeHint 1 `
    -CleanOnBoot:$false `
    -ZoneUid "00000000-0000-0000-0000-000000000000" `
    -UseFullDiskCloneProvisioning:$true
```

The following page provides the details of the VMware feature - Full Clone: 

* [The Full Clone Feature of VMware](../Full%20Clone/)


## 5. Specialized Scenario - using Write-Back Cache:

Utilizing the Write-Back Cache feature, necessitates the following additional parameters for its operation:

    1. CleanOnBoot: A flag to set non-persistent catalog, ensuring VMs are reset to their baseline state at each startup. This should be set to True to enable the Write-Back Cache.
    
    2. UseWriteBackCache: A flag to enable the Write-Back Cache feature. This should be set to True to enable the Write-Back Cache.
    
    3. WriteBackCacheDiskSize: Specifies the disk size of the Write-Back Cache.
    
    4. WriteBackCacheMemorySize: Defines the memory size of the Write-Back Cache.
    
    5. WriteBackCacheDriveLetter: Assigns the drive letter for the Write-Back Cache disk.

The script can be executed with parameters as shown in the example below:

```powershell
.\Add-ProvScheme.ps1 `
    -ProvisioningSchemeName "MyMachineCatalog" `
    -HostingUnitName "MyHostingUnit" `
    -IdentityPoolName "MyMachineCatalog" `
    -ProvisioningSchemeType "MCS" `
    -MasterImageVM "XDHyp:\HostingUnits\MyHostingUnit\MyVM.vm\MySnapshot.snapshot" `
    -CustomProperties "" `
    -NetworkMapping @{"0"="XDHyp:\HostingUnits\MyHostingUnit\MyNetwork.network"} `
    -VMCpuCount 1 `
    -VMMemoryMB 1024 `
    -Scope @() `
    -InitialBatchSizeHint 1 `
    -CleanOnBoot:$true `
    -ZoneUid "00000000-0000-0000-0000-000000000000" `
    -UseWriteBackCache:$true `
    -WriteBackCacheDiskSize 128 `
    -WriteBackCacheMemorySize 256 `
    -WriteBackCacheDriveLetter "W"
```

The following page provides the details of the VMware feature - Write-Back Cache: 

* [The Write-Back Cache Feature of VMware](../Write-Back%20Cache/)


## 6. Specialized Scenario - Using Data Disk:

Utilizing the Data Disk feature, necessitates the following additional parameters for its operation:

    1. DataDiskPersistence: Supported Values: `'Persistent'` and `'NonPersistent'`. Indicates whether the changes to the disk contents of the Prov-VMs will persist accross reboot.
    2. CleanOnBoot: Required to be enabled, if using NonPersistent data disk. 

The script can be executed with parameters as shown in the example below:

```powershell
.\Add-ProvScheme.ps1 `
    -ProvisioningSchemeName "MyMachineCatalog" `
    -HostingUnitName "MyHostingUnit" `
    -IdentityPoolName "MyMachineCatalog" `
    -ProvisioningSchemeType "MCS" `
    -MasterImageVM "XDHyp:\HostingUnits\MyHostingUnit\MyVM.vm\MySnapshot.snapshot" `
    -CustomProperties "" `
    -NetworkMapping @{"0"="XDHyp:\HostingUnits\MyHostingUnit\MyNetwork.network"} `
    -VMCpuCount 1 `
    -VMMemoryMB 1024 `
    -Scope @() `
    -InitialBatchSizeHint 1 `
    -ZoneUid "00000000-0000-0000-0000-000000000000" `
    -DataDiskPersistence "Persistent"
```

The following page provides the details of the VMware feature - Data Disk: 

* [The Data Disk Feature of VMware](../Data%20Disk/)
* **IMPORTANT** [VMware Data Disk Supported Scenarios](../Data%20Disk/README.md#3-vmware-data-disk-supported-scenarios)

## 7. Common Errors During Operation

1. If the hosting unit path of the master image is invalid, the error message is "New-ProvScheme : Path XDHyp:\HostingUnits\MyHostingUnit\MyVM.vm\MySnapshot.snapshot is not valid: Cannot find path 'XDHyp:\HostingUnits\MyHostingUnit' because it does not exist."

2. If the hosting unit path of the network mapping is invalid, the error message is "New-ProvScheme : Path XDHyp:\HostingUnits\MyHostingUnit\MyNetwork.network is not valid: Cannot find path 'XDHyp:\HostingUnits\MyHostingUnit' because it does not exist."

## 8. Reference Documents

For comprehensive information and further reading, the following resources are recommended. These include CVAD SDK documentation and other relevant references (as applicable):

1. [CVAD SDK - New-AcctIdentityPool](https://developer-docs.citrix.com/en-us/citrix-virtual-apps-desktops-sdk/current-release/ADIdentity/New-AcctIdentityPool.html)
2. [CVAD SDK - New-AcctADAccount](https://developer-docs.citrix.com/en-us/citrix-virtual-apps-desktops-sdk/current-release/ADIdentity/New-AcctADAccount.html)
3. [CVAD SDK - New-BrokerCatalog](https://developer-docs.citrix.com/en-us/citrix-virtual-apps-desktops-sdk/current-release/Broker/New-BrokerCatalog.html)
4. [CVAD SDK - Set-BrokerCatalog](https://developer-docs.citrix.com/en-us/citrix-daas-sdk/broker/set-brokercatalog)
5. [CVAD SDK - Set-BrokerCatalogMetadata](https://developer-docs.citrix.com/en-us/citrix-virtual-apps-desktops-sdk/current-release/Broker/Set-BrokerCatalogMetadata.html)
6. [CVAD SDK - New-BrokerMachine](https://developer-docs.citrix.com/en-us/citrix-virtual-apps-desktops-sdk/current-release/Broker/New-BrokerMachine.html)
7. [CVAD SDK - New-HypVMSnapshot](https://developer-docs.citrix.com/en-us/citrix-daas-sdk/HostService/New-HypVMSnapshot.html)
8. [CVAD SDK - New-ProvScheme](https://developer-docs.citrix.com/en-us/citrix-virtual-apps-desktops-sdk/current-release/MachineCreation/New-ProvScheme.html)
9. [CVAD SDK - Add-ProvSchemeControllerAddress](https://developer-docs.citrix.com/en-us/citrix-virtual-apps-desktops-sdk/current-release/MachineCreation/Add-ProvSchemeControllerAddress.html)
10. [CVAD SDK - New-ProvVM](https://developer-docs.citrix.com/en-us/citrix-virtual-apps-desktops-sdk/current-release/MachineCreation/New-ProvVM.html)
11. [CVAD SDK - Lock-ProvVM](https://developer-docs.citrix.com/en-us/citrix-virtual-apps-desktops-sdk/current-release/MachineCreation/Lock-ProvVM.html)
12. [CVAD SDK - Get-HypConfigurationObjectForItem](https://developer-docs.citrix.com/en-us/citrix-virtual-apps-desktops-sdk/current-release/HostService/Get-HypConfigurationObjectForItem.html)


