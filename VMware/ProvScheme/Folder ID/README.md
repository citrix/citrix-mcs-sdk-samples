# Updating the Folder Id of the Provisioning Scheme

This page outlines the base script for updating the Folder Id of the Provisioning Scheme on Citrix Virtual Apps and Desktops (CVAD).



## 1. Base Script: Update-FolderId.ps1

`Update-FolderId.ps1` is designed to update the Folder Id of a provisioning scheme. The script requires:

    1. ProvisioningSchemeName: Name of the provisioning scheme to be updated.
    
    2. CustomProperties: The custom properties that include the VMware Folder Id.
    
    3. AdminAddress: The primary DDC address.
    
The script can be executed with parameters as shown in the example below:

```powershell
.\Update-FoldeId.ps1 `
    -ProvisioningSchemeName "MyCatalog" `
    -CustomProperties "<CustomProperties xmlns=""http://schemas.citrix.com/2014/xd/machinecreation"" xmlns:xsi=""http://www.w3.org/2001/XMLSchema-instance""><Property xsi:type=""StringProperty"" Name=""FolderId"" Value=""group-v000"" /></CustomProperties>" `
    -AdminAddress "MyDDC.MyDomain.local"
```

Administrators should tailor these parameters to fit their specific environment.



## 2. Overview of the Base Script

The base script is segmented into four key steps, providing a structured approach to catalog update:

    1. Update the CustomProperties of the Provisioning Scheme
    
## 3. Detail of the Base Script

In this section, we dive into the specifics of each step in the base script for updating the Folder Id of a Provisioning Scheme. For each step, key parameters and their roles are outlined to give you a comprehensive understanding of the process.


**Step 1: Update the CustomProperties of the Provisioning Scheme.**

Update the Folder Id of the provisioning scheme by using ```Set-ProvScheme```.

The parameters for ```Set-ProvScheme``` are described below.

    1. ProvisioningSchemeName.
    Specifies the name of the provisioning scheme.	

    2. CustomProperties.
    The custom properties that include the VMware Folder Id.


## 4. Common Errors During Operation

1. If the name of the ProvScheme is invalid, the error message is "Set-ProvScheme : The object named YourInput was not found."



## 5. Reference Documents

For comprehensive information and further reading, the following resources are recommended. These include CVAD SDK documentation and other relevant references (as applicable):

4. [CVAD SDK - Set-ProvScheme](https://developer-docs.citrix.com/en-us/citrix-virtual-apps-desktops-sdk/current-release/MachineCreation/Set-ProvScheme.html)
