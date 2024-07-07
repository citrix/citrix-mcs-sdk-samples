# Updating the Master Image of the Machine Catalog

This page outlines the base script for updating the Master Image of the Machine Catalog on Citrix Virtual Apps and Desktops (CVAD).



## 1. Base Script: Update-MasterImage.ps1

`Update-MasterImage.ps1` is designed to update the master image of a provisioning scheme. The script requires:

    1. ProvisioningSchemeName: Name of the provisioning scheme to be updated.
    
    2. MasterImage: The path to the new master image.
    
    3. RebootDuration: The approximate maximum duration (in minutes) of the reboot cycle.
    
    4. WarningDuration: The lead time (in minutes) before a reboot when a warning message is shown to users.
    
    5. WarningRepeatInterval: The interval (in minutes) at which the warning message is repeated.
    
    6. WarningMessage: The message displayed to users prior to a machine reboot.
    
    7. AdminAddress: The primary DDC address.
    
The script can be executed with parameters as shown in the example below:

```powershell
.\Update-MasterImage.ps1 `
    -ProvisioningSchemeName "MyCatalog" `
    -MasterImage "XDHyp:\HostingUnits\MyNetwork\MyVM.vm\MySnapshot.snapshot" `
    -RebootDuration 240 `
    -WarningDuration 15 `
    -WarningRepeatInterval 0 `
    -WarningMessage "Save Your Work" `
    -AdminAddress "MyDDC.MyDomain.local"
```

Administrators should tailor these parameters to fit their specific environment.



## 2. Overview of the Base Script

The base script is segmented into four key steps, providing a structured approach to catalog update:

    1. Update the Master Image of the Provisioning Scheme.
    2. Verify New Image Addition.
    3. Reboot machines to apply the updated image.



## 3. Detail of the Base Script

In this section, we dive into the specifics of each step in the base script for updating the Master Image of a Machine Catalog. For each step, key parameters and their roles are outlined to give you a comprehensive understanding of the process.


**Step 1: Update the image of the Provisioning Scheme.**

Updating the master image associated with the provisioning scheme by using Set-ProvSchemeMetadata and Publish-ProvMasterVMImage.

In this base script, we assume the Image Preparation is requied. If you need to turn off the Image Preparation, please set the value for Set-ProvSchemeMetadata as False. For more details on Image Preparation, refer to the [Machine Creation Service Image Preparation Overview](https://www.citrix.com/blogs/2016/04/04/machine-creation-service-image-preparation-overview-and-fault-finding/).

The parameters for Publish-ProvMasterVMImage are described below.

    1. ProvisioningSchemeName.
    The name of the provisioning scheme to which the hard disk image should be updated.
        
    2. MasterImageVM.
    The path in the hosting unit provider to the VM snapshot or template that will be used. This identifies the hard disk to be used and the default values for the memory and processors. This must be a path to a Snapshot or Template item in the same hosting unit used by the provisioning scheme specified by ProvisioningSchemeName or ProvisioningSchemeUid. 

    Valid paths are of the format: 
        XDHyp:\HostingUnits\<HostingUnitName>\<path>\<VMName>.vm\<SnapshotName>.snapshot XDHyp:\HostingUnits\<HostingUnitName>\<path>\<TemplateName>.template	
    
**Step 2: Verify New Image Addition.**

Verifying the updated master image history is matched with the updated master image of ProvScheme by using Get-ProvSchemeMasterVMImageHistory and Get-ProvScheme.

The parameters for Get-ProvSchemeMasterVMImageHistory are described below.

    1. ProvisioningSchemeName.
    Specifies the name of the provisioning scheme.	

    2. ImageStatus.
    Specifies the status of the provisioning scheme image.	

The parameters for Get-ProvScheme are described below.

    1. ProvisioningSchemeName.
    Specifies a name for the catalog. Each catalog within a site must have a unique name.
        
**Step 3: Reboot machines to apply the updated image.**

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

1. [CVAD SDK - Set-ProvSchemeMetadata](https://developer-docs.citrix.com/en-us/citrix-virtual-apps-desktops-sdk/current-release/MachineCreation/Set-ProvSchemeMetadata.html)
2. [CVAD SDK - Publish-ProvMasterVMImage](https://developer-docs.citrix.com/en-us/citrix-virtual-apps-desktops-sdk/current-release/MachineCreation/Publish-ProvMasterVMImage.html)
3. [CVAD SDK - Get-ProvSchemeMasterVMImageHistory](https://developer-docs.citrix.com/en-us/citrix-virtual-apps-desktops-sdk/current-release/MachineCreation/Get-ProvSchemeMasterVMImageHistory.html)
4. [CVAD SDK - Get-ProvScheme](https://developer-docs.citrix.com/en-us/citrix-virtual-apps-desktops-sdk/current-release/MachineCreation/Get-ProvScheme.html)
5. [CVAD SDK - Get-BrokerCatalog](https://developer-docs.citrix.com/en-us/citrix-virtual-apps-desktops-sdk/current-release/Broker/Get-BrokerCatalog.html)
6. [CVAD SDK - Start-BrokerRebootCycle](https://developer-docs.citrix.com/en-us/citrix-virtual-apps-desktops-sdk/current-release/Broker/Start-BrokerRebootCycle.html)
7. [CVAD SDK - Remove-ProvTask](https://developer-docs.citrix.com/en-us/citrix-virtual-apps-desktops-sdk/current-release/MachineCreation/Remove-ProvTask.html)
