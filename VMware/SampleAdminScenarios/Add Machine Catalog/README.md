# Machine Catalog Creation

This page explains the details of creating a hosting unit on Citrix Virtual Apps and Desktops (CVAD). It includes a base script for basic configurations and specialized scripts for advanced VMware features: Full Clone and Write-Back Cache. 

    1. Base Script: Forms base layer, suitable for standard setups and adaptable for advanced, VMware-specific customizations. 

    2. Special Scripts: Extend the base script to utilize Full Clone and Write-Back Cache.



## 1. Base Script: Add-MachineCatalog.ps1

The `Add-MachineCatalog.ps1` script creates a Machine Catalog and requires the following parameters

    1. ProvisioningSchemeName: Name of the new provisioning scheme.
    
    2. HostingUnitName: Name of the hosting unit used.
    
    3. NetworkName: Names of the networks available on the hypervisor.
    
    4. Domain: Active Directory domain name.
    
    5. UserName: The username for an AD user account with Write Permissions.
        
    6. ZoneUid: The UID that corresponds to the Zone in which these AD accounts will be created.

    7. AdminAddress: The primary DDC address.
    
    8. NamingScheme: Template for AD account names. 
    
    8. NamingSchemeType: Naming scheme type for the catalog.
    
    9. ProvisioningType: Type of provisioning used.
    
    10. SessionSupport: Single or multi-session capability.
    
    11. AllocationType: User assignment method for machines.
    
    12. PersistUserChanges: User data persistence method.
    
    13. CleanOnBoot: Reset VMs to initial state on start.
    
    14. MasterImage: Path to VM snapshot or template.
    
    15. CustomProperties: Specific properties for the hosting infrastructure.
    
    16. Scope: Administration scopes for the identity pool.
    
    17. Count: Number of accounts to be created.

It's important to note the usage of the `CleanOnBoot` parameter: Set this to `$True` for creating `a non-persistent catalog` where VMs revert to their original state at each reboot. For `a persistent catalog` where changes are maintained, set it to `$False`.

The script can be executed with parameters as shown in the example below:

```powershell
.\Add-MachineCatalog.ps1 `
    -ProvisioningSchemeName "MyCatalog" `
    -HostingUnitName "Myresource" `
    -NetworkName "MyNetwork" `
    -Domain "MyDomain.local" `
    -UserName "MyUserName" `
    -ZoneUid "aaaaaaaa-bbbb-cccc-dddd-eeeeeeeeeeee" `
    -AdminAddress "MyDDC.MyDomain.local" `
    -NamingScheme "MyVM###" `
    -NamingSchemeType "Numeric" `
    -ProvisioningType "MCS" `
    -SessionSupport "Single"  `
    -AllocationType "Random"  `
    -PersistUserChanges "Discard" `
    -CleanOnBoot:$true `
    -MasterImage "XDHyp:\HostingUnits\Myresource\MyVM.vm\MySnapshot.snapshot"  `
    -CustomProperties "" `
    -Scope @() `
    -Count 2
```

Administrators should tailor these parameters to fit their specific environment.



## 2. Overview of the Base Script

The base script is segmented into six key steps, providing a structured approach to catalog creation:

    1. Create a New Identity Pool.
    2. Create New ADAccount(s).
    3. Create a New Provisioning Scheme.
    4. Create New ProvVM(s).
    5. Create a New Broker Catalog.
    6. Create New Broker Machine(s).



## 3. Detail of the Base Script

In this section, we dive into the specifics of each step in the base script for creating a Machine Catalog. For each step, key parameters and their roles are outlined to give you a comprehensive understanding of the process.

**Step 1: Create a New Identity Pool.**

Creating an identity pool for managing user identities and access by using New-AcctIdentityPool. The parameters for New-AcctIdentityPool are described below.

    1. IdentityPoolName.
    The name of the identity pool. This must not contain any of the following characters \/;:#.*?=<>|[]()””’. 
    The scripts here uses the provisioning scheme name as the identity pool name.
    
    2. NamingScheme.
    Defines the template name for AD accounts created in the identity pool. The scheme can consist of fixed characters and a variable part defined by ‘#’ characters. There can be only one variable region defined. The number of ‘#’ characters defines the minimum length of the variable region. 
    
    3. NamingSchemeType. 
    Specifies the type of naming scheme for the catalog. This defines the format of the variable part of the AD account names that will be created.	Values can be Numeric, Alphabetic, or None.

    For example, a naming scheme of DemoVm### could create accounts called:
    - DemoVm001, DemoVm002 (for a numeric scheme type) or 
    - DemoVmAAA, DemoVmAAB (for an alphabetic type).	
    
    4. AllowUnicode.
    Allow the naming scheme to have characters other than alphanumeric characters.	
    
    5. Domain.
    The AD domain name for the pool. Specify this in FQDN format; for example, MyDomain.com.	

    6. Scope.
    The administration scopes to be applied to the new identity pool.	

    7. ZoneUid.
    The UID that corresponds to the Zone in which these AD accounts will be created. This is only intended to be used for Citrix Cloud Delivery Controllers.	

**Step 2: Create New ADAccount(s).**

Creating Active Directory (AD) computer accounts in the specified identity pool by using New-AcctADAccount. The parameters for New-AcctADAccount are described below.

    1. IdentityPoolUid.
    The unique identifier for the identity pool in which accounts will be created.
    The scripts here extract the IdentityPoolUid from the result of New-AcctIdentityPool.

    2. Count.
    The number of accounts to create.

**Step 3: Create a Provisioning Scheme.**

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

    7.  MachineProfile
    Machine Profile provides a way to specify a template that will be used for provisioning machines in a provisioning scheme.
    All hardware properties (e.g., CPU Count, Memory, etc) are captured from the machine profile template. 

    8. UseWriteBackCache.
    Indicates whether write-back cache is enabled for the VMs created from this provisioning scheme. Use additional parameters to configure the write-back cache. 
    
    9. WriteBackCacheDiskSize.
    The size in GB of any temporary storage disk used by the write-back cache. Should be used in conjunction with WriteBackCacheMemorySize. 

    10. WriteBackCacheMemorySize.
    The size in MB of any write-back cache if required. Should be used in conjunction with WriteBackCacheDiskSize. Setting RAM Cache to 0 but specifying Disk Cache effectively disables the RAM Cache. However, there will be some memory still used to allow the I/O Optimization to operate.

    11.  WriteBackCacheDriveLetter. 
    The customized drive letter of write-back cache disk which can be any character between ‘E’ and ‘Z’. If not specified, the drive letter is auto assigned by operating system, i.e. generally ‘D’, but ‘E’ when ‘D’ is assigned to other disk like Azure temp disk. It only works with VDA 2305 or higher.

    12.  CustomProperties.
    The properties of the provisioning scheme that are specific to the target hosting infrastructure. See about_ProvCustomProperties for more information.	

    13.  VMCpuCount.
    The number of processors that will be used to create VMs from the provisioning scheme.	

    14.  VMMemoryMB.
    The maximum amount of memory that will be used to created VMs from the provisioning scheme in MB.	

    15.  NetworkMapping.
    Specifies how the attached NICs are mapped to networks. If this parameter is omitted, VMs are created with a single NIC, which is mapped to the default network in the hosting unit. If this parameter is supplied, machines are created with the number of NICs specified in the map, and each NIC is attached to the specified network.	

    16.  InitialBatchSizeHint.
    Provides a predictive hint for the number of initial VMs that will be added to the MCS catalog when the scheme is successfully created. Callers should supply this parameter in situations where the completion of New-ProvScheme will be closely followed by a New-ProvVM call to create an initial batch of VMs in the catalog.	

    17.  DataDiskPersistence.
    Supported Values: 'Persistent' and 'NonPersistent'.
    Indicates whether the changes to the disk contents of the Prov-VMs will persist accross reboot.
    When the value to this parameter is set to 'Persistent' or 'NonPersistent', the data disk created will have 'Dependent' or 'Independent - Nonpersistent' Disk Mode in VMware respectively.

    18.  Scope
    The administration scopes to be applied to the new provisioning scheme.

**Step 4: Create New ProvVM(s).**

Creating virtual machines with the configuration specified by a provisioning scheme by using New-ProvVM. The parameters for New-ProvVM are described below.

    1. ADAccountName.
    A list of the Active Directory account names that are used for the VMs. The accounts must be provided in a domain-qualified format. This parameter accepts Identity objects as returned by the New-AcctADAccount cmdlet, or any PSObject with string properties “Domain” and “ADAccountName”.	

    2. ProvisioningSchemeUid.
    The unique identifier of the provisioning scheme in which the VMs are created.	

    
**Step 5: Create a Broker Catalog.**

Creating a broker catalog for managing a group of machines in a site by using New-BrokerCatalog. The parameters for New-BrokerCatalog are described below.

    1. Name.
    Specifies a name for the catalog. Each catalog within a site must have a unique name.

    2. ProvisioningType.
    Specifies the Provisioning Type for the catalog. Values can be: 
    - PVS: Machine provisioned by PVS (machine may be physical, blade, VM, etc). 
    - MCS: Machine provisioned by MCS (machine must be VM).
    - Manual: No provisioning. 

    3. SessionSupport.
    Specifies whether machines in the catalog are single or multi-session capable. Values can be: 
    - SingleSession: Single-session only machine. 
    - MultiSession: Multi-session capable machine. 

    4. AllocationType.
    Specifies how machines in the catalog are assigned to users. Values can be:
    - Permanent - Machines in a catalog of this type are permanently assigned to a user. 
    - Random - Machines in a catalog of this type are picked at random and temporarily assigned to a user.
    - Static - equivalent to Permanent. 
    
    5. PersistUserChanges.
    Specifies how user changes are persisted on machines in the catalog. Possible values are: 
    - OnLocal: User changes are stored on the machine’s local storage. 
    - Discard: User changes are discarded

    6. Scope.
    Specifies the name of the delegated administration scope to which the catalog belongs.

    7. ZoneUid.
    Zone Uid associated with this catalog.

**Step 6: Create Broker Machine(s).**

Adding broker machines to the broker catalog to manage the macines in the site by using New-BrokerMachine. The parameters for New-BrokerMachine are described below.

    1. CatalogUid.
    The catalog to which this machine will belong.	

    2. MachineName
    Specify the name of the machine to create (in the form ‘domain\machine’). A SID can also be specified.	



## 4. Specialized Scenario - Using Full Clone:

Utilizing the Full Clone feature, necessitates the following additional parameters for its operation:

    1. CleanOnBoot: A flag to set non-persistent catalog, ensuring VMs are reset to their baseline state at each startup. This should be set to false to enable the Full Clone feature.
    2. UseFullDiskCloneProvisioning: Indicates whether VMs should be created using the dedicated full disk clone feature. By default, the Fast Clone approach is used unless this parameter is explicitly set to enable Full Clone.

The script can be executed with parameters as shown in the example below:

```powershell
.\Add-MachineCatalog.ps1 `
    -ProvisioningSchemeName "MyCatalog" `
    -HostingUnitName "Myresource" `
    -NetworkName "MyNetwork" `
    -AdminAddress "MyDDC.MyDomain.local" `
    -Domain "MyDomain.local" `
    -UserName "MyUserName" `
    -Password "MyPassword" `
    -ZoneUid "aaaaaaaa-bbbb-cccc-dddd-eeeeeeeeeeee" `
    -NamingScheme "MyVM###" `
    -NamingSchemeType "Numeric" `
    -ProvisioningType "MCS" `
    -SessionSupport "Single"  `
    -AllocationType "Random"  `
    -PersistUserChanges "Discard" `
    -CleanOnBoot:$false `
    -MasterImage "XDHyp:\HostingUnits\Myresource\MyVM.vm\MySnapshot.snapshot"  `
    -CustomProperties "" `
    -Scope @() `
    -Count 2 `
    -UseFullDiskCloneProvisioning:$true
```

The following page provides the details the VMware feature - Full Clone: 

* [The Full Clone of VMware](../../ProvScheme/Full%20Clone/)


## 5. Specialized Scenario - Using Write-Back Cache:

Utilizing the Write-Back Cache feature, necessitates the following additional parameters for its operation:

    1. CleanOnBoot: A flag to set non-persistent catalog, ensuring VMs are reset to their baseline state at each startup. This should be set to True to enable the Write-Back Cache.
    
    2. UseWriteBackCache: A flag to enable the Write-Back Cache feature. This should be set to True to enable the Write-Back Cache.
    
    3. WriteBackCacheDiskSize: Specifies the disk size of the Write-Back Cache.
    
    4. WriteBackCacheMemorySize: Defines the memory size of the Write-Back Cache.
    
    5. WriteBackCacheDriveLetter: Assigns the drive letter for the Write-Back Cache disk.

The script can be executed with parameters as shown in the example below:

```powershell
.\Add-MachineCatalog-WriteBackCache.ps1 `
    -ProvisioningSchemeName "MyCatalog" `
    -HostingUnitName "Myresource" `
    -NetworkName "MyNetwork" `
    -AdminAddress "MyDDC.MyDomain.local" `
    -Domain "MyDomain.local" `
    -UserName "MyUserName" `
    -Password "MyPassword" `
    -ZoneUid "aaaaaaaa-bbbb-cccc-dddd-eeeeeeeeeeee" `
    -NamingScheme "MyVM###" `
    -NamingSchemeType "Numeric" `
    -ProvisioningType "MCS" `
    -SessionSupport "Single"  `
    -AllocationType "Random"  `
    -PersistUserChanges "Discard" `
    -CleanOnBoot:$true `
    -MasterImage "XDHyp:\HostingUnits\Myresource\MyVM.vm\MySnapshot.snapshot"  `
    -CustomProperties "" `
    -Scope @() `
    -Count 2 `
    -UseWriteBackCache:$true `
    -WriteBackCacheDiskSize 128 `
    -WriteBackCacheMemorySize 256 `
    -WriteBackCacheDriveLetter "W"
```

The following page provides the details the VMware feature - Write-Back Cache: 

* [The Write-Back Cache of VMware](../../ProvScheme/Write-Back%20Cache/)

## 6. Specialized Scenario - Using Data Disk:

Utilizing the Data Disk feature, necessitates the following additional parameters for its operation:

    1. DataDiskPersistence: Supported Values: `'Persistent'` and `'NonPersistent'`. Indicates whether the changes to the disk contents of the Prov-VMs will persist accross reboot.
    2. CleanOnBoot: Required to be enabled, if using NonPersistent data disk. 

The script can be executed with parameters as shown in the example below:

```powershell
.\Add-MachineCatalog.ps1 `
    -ProvisioningSchemeName "MyCatalog" `
    -HostingUnitName "Myresource" `
    -NetworkName "MyNetwork" `
    -AdminAddress "MyDDC.MyDomain.local" `
    -Domain "MyDomain.local" `
    -UserName "MyUserName" `
    -Password "MyPassword" `
    -ZoneUid "aaaaaaaa-bbbb-cccc-dddd-eeeeeeeeeeee" `
    -NamingScheme "MyVM###" `
    -NamingSchemeType "Numeric" `
    -ProvisioningType "MCS" `
    -SessionSupport "Single"  `
    -AllocationType "Random"  `
    -PersistUserChanges "Discard" `
    -MasterImage "XDHyp:\HostingUnits\Myresource\MyVM.vm\MySnapshot.snapshot"  `
    -CustomProperties "" `
    -Scope @() `
    -Count 2 `
    -DataDiskPersistence "Persistent"
```

The following page provides the details of the VMware feature - Data Disk: 

* [The Data Disk Feature of VMware](../../ProvScheme/Data%20Disk/)
* **IMPORTANT** [VMware Data Disk Supported Scenarios](../../ProvScheme/Data%20Disk/README.md#3-vmware-data-disk-supported-scenarios)

## 7. Specialized Scenario - Using Machine Profile:

Utilizing the Machine Profile feature, necessitates the following additional parameters for its operation:

    1. MachineProfile: The path for the VM Template.
    
The script can be executed with parameters as shown in the example below:

```powershell
.\Add-MachineCatalog-WriteBackCache.ps1 `
    -ProvisioningSchemeName "MyCatalog" `
    -HostingUnitName "Myresource" `
    -NetworkName "MyNetwork" `
    -AdminAddress "MyDDC.MyDomain.local" `
    -Domain "MyDomain.local" `
    -UserName "MyUserName" `
    -Password "MyPassword" `
    -ZoneUid "aaaaaaaa-bbbb-cccc-dddd-eeeeeeeeeeee" `
    -NamingScheme "MyVM###" `
    -NamingSchemeType "Numeric" `
    -ProvisioningType "MCS" `
    -SessionSupport "Single"  `
    -AllocationType "Random"  `
    -PersistUserChanges "Discard" `
    -CleanOnBoot:$true `
    -MasterImage "XDHyp:\HostingUnits\Myresource\MyVM.vm\MySnapshot.snapshot"  `
    -MachineProfile "XDHyp:\HostingUnits\Myresource\MyVM-Template.template" `
    -CustomProperties "" `
    -Scope @() `
    -Count 2 `
```

The following page provides the details the VMware feature - Machine Profile: 

* [The Machine Profile of VMware](../../ProvScheme/Machine%20Profile/README.md)

## 8. Common Errors During Operation

1. If the domain is invalid, the error message is "New-AcctIdentityPool : An invalid URL was given for the service. The value given was 'YourInput.MyDomain.local'."

2. If the master image path is invalid, the error message is "Get-HypConfigurationObjectForItem : 'Citrix.Hypervisor' resolved to more than one provider name. Possible matches include: Citrix.Host.PowerShellSnapIn\Citrix.Hypervisor 
Citrix.Host.Admin.V2\Citrix.Hypervisor."

## 9. Reference Documents

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
13. [CVAD SDK - About Machine Profile](https://developer-docs.citrix.com/en-us/citrix-daas-sdk/MachineCreation/about_Prov_MachineProfile.html)
