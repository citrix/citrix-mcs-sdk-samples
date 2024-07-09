# Getting the Detail of a Provisioning Virtual Machines

This page provides the base script for obtaining details of a provisioning Virtual Machines (VMs) in Citrix Virtual Apps and Desktops (CAVD).



## 1. Base Script: Get-ProvVM-Detail.ps1

The `Get-ProvVM-Detail.ps1` script retrieves detailed information about provisioning VMs. It requires the following parameter:

    1. ProvisioningSchemeName: The name of the provisioning scheme.

The script can be executed with parameters as shown in the example below:

```powershell
.\Get-ProvVM-Detail.ps1 `
    -ProvisioningSchemeName "MyCatalog"
```

Administrators should tailor these parameters to fit their specific environment.



## 2. Overview of the Base Script

The retrieval process consists of one primary step:

    1: Get the detail of the Provisioning VMs.



## 3. Detail of the Base Script

This section explores each step in the base script, outlining the key parameters involved.

**Step 1: Get the detail of the Provisioning VMs.**

Retrieve the detail of a provisoning VMs by using ``Get-ProvVM``. The parameters for ``Get-ProvVM`` are described below.
 
    1. ProvisioningSchemeName
    The name of the provisioning scheme. 


## 4. Common Errors During Operation

1. If the name of the ProvScheme is invalid, the error message is not available. Nothing will be retuned.



## 5. Reference Documents

For comprehensive information and further reading, the following resources are recommended. These include CVAD SDK documentation and other relevant references (as applicable):

1. [CVAD SDK - Get-ProvVM](https://developer-docs.citrix.com/en-us/citrix-virtual-apps-desktops-sdk/current-release/MachineCreation/Get-ProvVM.html)



