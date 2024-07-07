# Hosting Connection Deletion

This page outlines the base script for deleting a Hosting Connection and Hosting Resources on Citrix Virtual Apps and Desktops (CVAD). 

## 1. Base Script: Remove-HostingConnection.ps1

The `Remove-HostingConnection.ps1` script facilitates the deletion of a hosting connection and associated resources. It requires the following parameters:

    1. ConnectionName: The name of the hosting connection to be deleted.
    
    2. AdminAddress: The primary DDC address.

The script can be executed with parameters as shown in the example below:

```powershell
.\Remove-HostngConnection.ps1 `
    -ConnectionName "MyConnection" `
    -AdminAddress "MyDDC.MyDomain.local"
```

Administrators should tailor these parameters to fit their specific environment.



## 2. Overview of the Base Script

The deletion process is structured into two main steps:

    1. Remove the Resources of the Hosting Connection.
    2. Remove the Hosting Connection.



## 3. Detail of the Base Script

This section explores each step in the base script, outlining the key parameters involved.

**Step 1: Remove the Resources of the Hosting Connection.**

Removes a hosting resource item by using ``Remove-Item``. The parameters for ``Remove-Item`` are described below.

    1. LiteralPath.
    Specifies the path of the hosting resource item, e.g., "XDHyp:\HostingUnits\MyResource"

**Step 2: Remove the Hosting Connection.**

Removes a hosting connection by using ``Remove-BrokerHypervisorConnection`` and ``Remove-Item``. 

The parameters for ``Remove-BrokerHypervisorConnection`` are described below.

    1. Name
    Specifies the name of the hosting connection to remove. 

The parameters for ``Remove-Item`` are described below.

    1. LiteralPath.
    Specifies the path of the hosting connection, e.g., "XDHyp:\Connections\MyConnection"


## 4. Common Errors During Operation

1. If the connection name is invalid, the error message is "Remove-BrokerHypervisorConnection : No items match the supplied pattern."

2. If the connection name is invalid, the error message is "Remove-Item : Cannot find path 'XDHyp:\Connections\YourInput' because it does not exist."


## 5. Reference Documents

For comprehensive information and further reading, the following resources are recommended. These include CVAD SDK documentation and other relevant references (as applicable):

1. [CVAD SDK - Remove-BrokerHypervisorConnection](https://developer-docs.citrix.com/en-us/citrix-virtual-apps-desktops-sdk/current-release/Broker/Remove-BrokerHypervisorConnection.html)
2. [Microsoft PowerShell SDK - Remove-Item](https://learn.microsoft.com/en-us/powershell/module/microsoft.powershell.management/remove-item?view=powershell-7.4)
