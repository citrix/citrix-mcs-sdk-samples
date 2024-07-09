# Getting the Detail of a Machine Catalog**

This page provides the base script for obtaining details of a machine catalog in Citrix Virtual Apps and Desktops (CAVD).



## 1. Base Script: Get-ProvScheme-Details.ps1

The `Get-ProvScheme-Details.ps1` script retrieves detailed information about a machine catalog. It requires the following parameter:

    1. ProvisioningSchemeName: The name of the provisioning scheme.

The script can be executed with parameters as shown in the example below:

```powershell
.\Get-ProvScheme-Details.ps1 `
    -ProvisioningSchemeName "MyCatalog"
```

Administrators should tailor these parameters to fit their specific environment.



## 2. Overview of the Base Script

The retrieval process consists of one primary step:

    1: Get the detail of the Provisioning Scheme.



## 3. Detail of the Base Script

This section explores each step in the base script, outlining the key parameters involved.

**Step 1: Get the detail of the Provisioning Scheme.**

Retrieve the detail of a provisoning scheme by using ``Get-ProvScheme``. The parameters for ``Get-ProvScheme`` are described below.
 
    1. ProvisioningSchemeName
    The name of the provisioning scheme. 


## 4. Common Errors During Operation

1. If the name of the ProvScheme is invalid, the error message is "Get-ProvScheme : Object does not exist."



## 5. Reference Documents

For comprehensive information and further reading, the following resources are recommended. These include CVAD SDK documentation and other relevant references (as applicable):

1. [CVAD SDK - Get-ProvScheme](https://developer-docs.citrix.com/en-us/citrix-virtual-apps-desktops-sdk/current-release/MachineCreation/Get-ProvScheme.html)



