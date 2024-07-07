# Removing Scopes from a Hosting Connections

This page outlines the base script for removing scopes from a Hosting Connection on Citrix Virtual Apps and Desktops (CVAD). 



## 1. Base Script: Remove-Scope.ps1

The `Remove-Scope.ps1` script is designed to remove scopes from a existing hosting connection. It requires the following parameters:

    1. ConnectionName: The name of the hosting connection to update.
    
    2. ScopeName: The names of the scopes to be removed.
    
    3. AdminAddress: The primary DDC address.

The script can be executed with parameters as shown in the example below:

```powershell
.\Remove-Scope.ps1 `
    -ConnectionName "MyConnection" `
    -ScopeName "MyScope" `
    -AdminAddress "MyDDC.MyDomain.local" 
```

Administrators should tailor these parameters to fit their specific environment.



## 2. Overview of the Base Script

The process of removing scopes is simplified into one key step:

    1. Remove the Scopes from the Hosting Connections.



## 3. Detail of the Base Script

This section explores each step in the base script, outlining the key parameters involved.

**Step 1: Remove the Scopes from the Hosting Connections.**

Remove scopes to hosting connections by using ``Remove-HypHypervisorConnectionScope``. The parameters for ``Remove-HypHypervisorConnectionScope`` are described below.

    1. HypervisorConnectionName.
    Specifies the names of the hosting connections.

    2. Scope.
    Specifies the names of the scopes to be removed.


## 4. Common Errors During Operation

1. If the scope name is invalid, the error message is "Remove-HypHypervisorConnectionScope : Cannot find the following scope or scopes: "YourInput"."


## 5. Reference Documents

For comprehensive information and further reading, the following resources are recommended. These include CVAD SDK documentation and other relevant references (as applicable):

1. [CVAD SDK - Remove-HypHypervisorConnectionScope](https://developer-docs.citrix.com/en-us/citrix-virtual-apps-desktops-sdk/current-release/HostService/Remove-HypHypervisorConnectionScope.html)


