# Rollback the Master Image of the Machine Catalog

This page outlines the base script to roll back the image of a Machine Catalog on Citrix Virtual Apps and Desktops (CVAD).



## 1. Base Script: RollBack-MasterImage.ps1

`RollBack-MasterImage.ps1` is designed to roll back the master image of a provisioning scheme. The script requires:

    1. ProvisioningSchemeName: Name of the provisioning scheme to be updated.
    
    2. RebootDuration: The approximate maximum duration (in minutes) of the reboot cycle.
    
    3. WarningDuration: The lead time (in minutes) before a reboot when a warning message is shown to users.
    
    4. WarningRepeatInterval: The interval (in minutes) at which the warning message is repeated.
    
    5. WarningMessage: The message displayed to users prior to a machine reboot.
    
    6. AdminAddress: The primary DDC address.
    
The script can be executed with parameters as shown in the example below:

```powershell
.\RollBack-MasterImage.ps1 `
    -ProvisioningSchemeName "MyCatalog" `
    -RebootDuration 240 `
    -WarningDuration 15 `
    -WarningRepeatInterval 0 `
    -WarningMessage "Save Your Work" `
    -AdminAddress "MyDDC.MyDomain.local"
```

Administrators should tailor these parameters to fit their specific environment.



## 2. Overview of the Base Script

The base script is segmented into five key steps, providing a structured approach to the Master Image rollback:

    1. Get the last Master Image for Rollback.
    2. Remove the last Master Image for Rollback from the Master Image History.
    3. Update the Master Image of the Provisioning Scheme.
    4. Verify the Image Updated.
    5. Reboot machines to apply the updated image.



## 3. Detail of the Base Script

In this section, we dive into the specifics of each step in the base script for updating the Master Image of a Machine Catalog. For each step, key parameters and their roles are outlined to give you a comprehensive understanding of the process.


**Step 1: Get the previous Master Image for Rollback.**

Gets the list of master VM snapshots that have been used to provide hard disks to provisioning schemes by using Get-ProvSchemeMasterVMImageHistory. Get-ProvSchemeMasterVMImageHistory returns "Deleted" master images by default. The base script sort the "Deleted" master images by "Date" and retrieve the last one. To include "Current" master image, the -ShowAll parameter should be specified, but the base script does not use it. The parameters for Get-ProvSchemeMasterVMImageHistory are described below.

    1. ProvisioningSchemeName.
    The name of the provisioning scheme to retrieve the master image history.
        
    2. SortBy.
    In this script, the master image history is sorted by Date to get the last one.
    
**Step 2: Remove the previous Master Image for Rollback from the Master Image History.**

Removes the history of provisioning scheme master image VMs by using Remove-ProvSchemeMasterVMImageHistory. The parameters for Remove-ProvSchemeMasterVMImageHistory are described below.

    1. ProvisioningSchemeName.
    Specifies the name of the provisioning scheme.	

    2. VMImageHistoryUid.
    Specifies the unique identifier of the image history item.	

**Step 3: Update the Master Image of the Provisioning Scheme.**

Updating the master image associated with the provisioning scheme by using Set-ProvSchemeMetadata and Publish-ProvMasterVMImage.
In this base script, we assume the Image Preparation is requied. If you need to turn off the Image Preparation, please set the value for Set-ProvSchemeMetadata as False. 

For more details on Image Preparation, refer to the [Machine Creation Service Image Preparation Overview](https://www.citrix.com/blogs/2016/04/04/machine-creation-service-image-preparation-overview-and-fault-finding/).

The parameters for Publish-ProvMasterVMImage are described below.

    1. ProvisioningSchemeName.
    The name of the provisioning scheme to which the hard disk image should be updated.
        
    2. MasterImageVM.
    The path in the hosting unit provider to the VM snapshot or template that will be used. This identifies the hard disk to be used and the default values for the memory and processors. This must be a path to a Snapshot or Template item in the same hosting unit used by the provisioning scheme specified by ProvisioningSchemeName or ProvisioningSchemeUid. 

    Valid paths are of the format: 
        XDHyp:\HostingUnits\<HostingUnitName>\<path>\<VMName>.vm\<SnapshotName>.snapshot XDHyp:\HostingUnits\<HostingUnitName>\<path>\<TemplateName>.template	

**Step 4: Verify the Image Updated.**

Verifying the updated master image history is matched with the updated master image of ProvScheme by using Get-ProvSchemeMasterVMImageHistory and Get-ProvScheme.

The parameters for Get-ProvSchemeMasterVMImageHistory are described below.

    1. ProvisioningSchemeName.
    Specifies the name of the provisioning scheme.	

    2. ImageStatus.
    Specifies the status of the provisioning scheme image.	

The parameters for Get-ProvScheme are described below.

    1. ProvisioningSchemeName.
    Specifies a name for the catalog. Each catalog within a site must have a unique name.

**Step 5: Reboot Machines to apply the updated Master Image.**

Creating and starting a reboot cycle for machines in a broker catalog to apply the updated image by using Get-BrokerCatalog and Start-BrokerRebootCycle.

The parameters for Get-BrokerCatalog are described below.

    1. Name.
    Specifies a name for the catalog. Each catalog within a site must have a unique name.

The parameters for Start-BrokerRebootCycle are described below.

    1. RebootDuration.
    Approximate maximum duration in minutes over which the reboot cycle runs.

    2. WarningMessage.
    Warning message displayed in user sessions on a machine scheduled for reboot. If the message is blank then no message is displayed. The optional pattern ‘%m%’ is replaced by the number of minutes until the reboot.

    3. WarningDuration.
    Time in minutes prior to a machine reboot at which a warning message is displayed in all user sessions on that machine. If the warning duration value is zero then no message is displayed. In some cases the time required to process a reboot cycle may exceed the RebootDuration time by up to the WarningDuration value; Citrix recommends that the WarningDuration is kept small relative to the RebootDuration value.

    4. WarningRepeatInterval.
    Number of minutes to wait before showing the reboot warning message again.	    


## 4. Common Errors During Operation

1. If the name of the ProvScheme is invalid, the error message is "Set-ProvSchemeMetadata : The object named YourInput was not found."


## 5. Reference Documents

For comprehensive information and further reading, the following resources are recommended. These include CVAD SDK documentation and other relevant references (as applicable):

1. [CVAD SDK - Get-ProvSchemeMasterVMImageHistory](https://developer-docs.citrix.com/en-us/citrix-virtual-apps-desktops-sdk/current-release/MachineCreation/Get-ProvSchemeMasterVMImageHistory.html)
2. [CVAD SDK - Remove-ProvSchemeMasterVMImageHistory](https://developer-docs.citrix.com/en-us/citrix-virtual-apps-desktops-sdk/current-release/MachineCreation/Remove-ProvSchemeMasterVMImageHistory.html)
3. [CVAD SDK - Set-ProvSchemeMetadata](https://developer-docs.citrix.com/en-us/citrix-virtual-apps-desktops-sdk/current-release/MachineCreation/Set-ProvSchemeMetadata.html)
4. [CVAD SDK - Publish-ProvMasterVMImage](https://developer-docs.citrix.com/en-us/citrix-virtual-apps-desktops-sdk/current-release/MachineCreation/Publish-ProvMasterVMImage.html)
5. [CVAD SDK - Get-ProvSchemeMasterVMImageHistory](https://developer-docs.citrix.com/en-us/citrix-virtual-apps-desktops-sdk/current-release/MachineCreation/Get-ProvSchemeMasterVMImageHistory.html)
6. [CVAD SDK - Get-ProvScheme](https://developer-docs.citrix.com/en-us/citrix-virtual-apps-desktops-sdk/current-release/MachineCreation/Get-ProvScheme.html)
7. [CVAD SDK - Get-BrokerCatalog](https://developer-docs.citrix.com/en-us/citrix-virtual-apps-desktops-sdk/current-release/Broker/Get-BrokerCatalog.html)
8. [CVAD SDK - Start-BrokerRebootCycle](https://developer-docs.citrix.com/en-us/citrix-virtual-apps-desktops-sdk/current-release/Broker/Start-BrokerRebootCycle.html)
9. [CVAD SDK - Remove-ProvTask](https://developer-docs.citrix.com/en-us/citrix-virtual-apps-desktops-sdk/current-release/MachineCreation/Remove-ProvTask.html)


