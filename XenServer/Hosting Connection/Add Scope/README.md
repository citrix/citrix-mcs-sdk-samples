# Adding Scopes to Hosting Connections

This page outlines the base script for adding scopes to Hosting Connections on Citrix Virtual Apps and Desktops (CVAD). 



## 1. Base Script: Add-Scope.ps1

The `Add-Scope.ps1` script is designed to add scopes to existing hosting connections. It requires the following parameters:

    1. ConnectionName: The name of the hosting connection to update.
    
    2. ScopeName: The names of the scopes to be added.
    
    3. AdminAddress: The primary DDC address.

The script can be executed with parameters as shown in the example below:

```powershell
.\Add-Scope.ps1 `
    -ConnectionName "MyConnection" `
    -ScopeName "MyScope" `
    -AdminAddress "MyDDC.MyDomain.local"
```

Administrators should tailor these parameters to fit their specific environment.



## 2. Overview of the Base Script

The process of adding scopes is simplified into one key step:

    1. Add the scopes to the Hypervisor Connections.



## 3. Detail of the Base Script

This section explores each step in the base script, outlining the key parameters involved.

**Step 1: Add the scope to the Hypervisor Connection.**

Add scopes to hosting connections by using ``Add-HypHypervisorConnectionScope``. The parameters for ``Add-HypHypervisorConnectionScope`` are described below.

    1. HypervisorConnectionName.
    Specifies the names of the hosting connections.

    2. Scope.
    Specifies the names of the scopes to add.


## 4. Common Errors During Operation

1. If the scope name is invalid, the error message is "Add-HypHypervisorConnectionScope : Cannot find the following scope or scopes: "YourInput"."



## 5. Reference Documents

For comprehensive information and further reading, the following resources are recommended. These include Citrix Virtual Apps and Desktops SDK documentation and other relevant references (as applicable):

1. [CVAD SDK - Add-HypHypervisorConnectionScope](https://developer-docs.citrix.com/en-us/citrix-virtual-apps-desktops-sdk/current-release/hostservice/add-hyphypervisorconnectionscope)


