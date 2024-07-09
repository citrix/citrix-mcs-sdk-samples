# Updating the Network Mapping of the Provisioning Scheme

This page outlines the base script for updating the Network Mapping of the Provisioning Scheme on Citrix Virtual Apps and Desktops (CVAD).



## 1. Base Script: Update-NetworkMapping.ps1

`Update-NetworkMapping.ps1` is designed to update the network mapping of a provisioning scheme. The script requires:

    1. ProvisioningSchemeName: Name of the provisioning scheme to be updated.
    
    2. NetworkMapping: Specifies how the attached NICs are mapped to networks, represented as @{"DeviceID" = "NetworkPath"}
    
    3. AdminAddress: The primary DDC address.
    
The script can be executed with parameters as shown in the example below:

```powershell
.\Update-NetworkMapping.ps1 `
    -ProvisioningSchemeName "MyCatalog" `
    -NetworkMapping @{"0" = "XDHyp:\HostingUnits\MyHostingUnit\My Network.network"} `
    -AdminAddress "MyDDC.MyDomain.local"
```

Administrators should tailor these parameters to fit their specific environment.



## 2. Overview of the Base Script

The base script is segmented into four key steps, providing a structured approach to catalog update:

    1. Update the NetworkMapping of the Provisioning Scheme.



## 3. Detail of the Base Script

In this section, we dive into the specifics of each step in the base script for updating the NetworkMapping of the Provisioning Scheme. For each step, key parameters and their roles are outlined to give you a comprehensive understanding of the process.


**Step 1: Update the NetworkMapping of the Provisioning Scheme.**

Updating the network mpaaing associated with the provisioning scheme by using ```Set-ProvScheme``` and Publish-ProvMasterVMImage.

The parameters for ```Set-ProvScheme``` are described below.

    1. ProvisioningSchemeName.
    The name of the provisioning scheme to which the hard disk image should be updated.
        
    2. NetworkMapping.
    Specifies how the attached NICs are mapped to networks. If this parameter is omitted, VMs are created with a single NIC, which is mapped to the default network in the hosting unit. If this parameter is supplied, machines are created with the number of NICs specified in the map, and each NIC is attached to the specified network.	
    
    This can be represented as @{"DeviceID" = "NetworkPath"}. For example, @{"0" = "XDHyp:\HostingUnits\MyHostingUnit\My Network.network"} `
    
   

## 4. Common Errors During Operation

1. If the name of the ProvScheme is invalid, the error message is "Set-ProvScheme : The object named YourInput was not found."



## 5. Reference Documents

For comprehensive information and further reading, the following resources are recommended. These include CVAD SDK documentation and other relevant references (as applicable):

4. [CVAD SDK - Set-ProvScheme](https://developer-docs.citrix.com/en-us/citrix-virtual-apps-desktops-sdk/current-release/MachineCreation/Set-ProvScheme.html)
