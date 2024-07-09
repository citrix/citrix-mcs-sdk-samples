# Hosting Unit Deletion

This page outlines the base script for deleting a Hosting Unit on Citrix Virtual Apps and Desktops. 



## 1. Base Script: Remove-HostingUnit.ps1

The `Remove-HostingUnit.ps1` script facilitates the deletion of a hosting unit and associated resources. It requires the following parameters:

    1. HostingUnitNames: The names of the hosting unit to be deleted.
    
    2. AdminAddress: The primary DDC address.

The script can be executed with parameters as shown in the example below:

```powershell
.\Remove-HostingUnit.ps1 `
    -HostingUnitNames "MyHostingUnit1", "MyHostingUnit2" `
    -AdminAddress "MyDDC.MyDomain.local"
```

Administrators should tailor these parameters to fit their specific environment.



## 2. Overview of the Base Script

The deletion process is structured into two main steps:

    1. Remove the Resources of the Hosting Unit.



## 3. Detail of the Base Script

This section explores each step in the base script, outlining the key parameters involved.

**Step 1: Remove the Resources of the Hosting Unit.**

Removes a hosting resource item by using ``Remove-Item``. The parameters for ``Remove-Item`` are described below.

    1. LiteralPath.
    Specifies the path of the hosting resource item, e.g., "XDHyp:\HostingUnits\MyResource"


## 4. Common Errors During Operation

1. If the connection name is invalid, the error message is "New-EnvTestDiscoveryTargetDefinition : The target object definition is incomplete:  -TargetId = , -TargetType = HostingUnit, both are required."



## 5. Reference Documents

For comprehensive information and further reading, the following resources are recommended. These include CVAD SDK documentation and other relevant references (as applicable):

1. [Microsoft PowerShell SDK - Remove-Item](https://learn.microsoft.com/en-us/powershell/module/microsoft.powershell.management/remove-item?view=powershell-7.4)


