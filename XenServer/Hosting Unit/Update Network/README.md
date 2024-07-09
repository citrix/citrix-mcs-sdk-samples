# Update the Networks of a Hosting Unit

This page outlines the base script for update the networks of a Hosting Unit on Citrix Virtual Apps and Desktops (CVAD). 



## 1. Base Script: Update-Network.ps1

The `Update-Network.ps1` script is designed to update the networks of an existing hosting unit. It requires the following parameters:

    1. ConnectionName: The name of the hosting connection associated with the networks.
    
    2. HostingUnitName: The name of the hosting unit from which the networks will be updated.
    
    3. NetworkPaths: The paths of the networks of the hosting unit to be updated.
    
    4. AdminAddress: The primary DDC address.

The script can be executed with parameters as shown in the example below:

```powershell
.\Update-Network.ps1 `
    -ConnectionName "MyConnection" `
    -HostingUnitName "MyHostingUnit" `
    -NetworkPaths "MyNetwork1.network", "MyNetwork2.network" `
    -AdminAddress "MyDDC.MyDomain.local"
```

Administrators should tailor these parameters to fit their specific environment.



## 2. Overview of the Base Script

The process of updating networks of a hosting unit is simplified into one key step:

    1. Update the Networks of the Hosting Unit.



## 3. Detail of the Base Script

This section explores each step in the base script, outlining the key parameters involved.

**Step 1: Update the Networks of the Hosting Unit.**

Update the networks of a hosting unit by using ``Set-Item``. The parameters for ``Set-Item`` are described below.

    1. Path.
    Specifies the path of the hosting unit, e.g., "XDHyp:\HostingUnits\MyHostingUnit"

    2. NetworkPath.
    Specifies the path of networks available on the hypervisor, @(XDHyp:\Connections\MyConnection\MyNetwork1.network", XDHyp:\Connections\MyConnection\MyNetwork2.network")
    

## 4. Common Errors During Operation

1. If the network name is invalid, the error message is "Set-Item : The NetworkPath supplied for the HostingUnit is invalid."



## 5. Reference Documents

For comprehensive information and further reading, the following resources are recommended. These include CVAD SDK documentation and other relevant references (as applicable):

1. [Microsoft PowerShell SDK - Set-Item](https://learn.microsoft.com/en-us/powershell/module/microsoft.powershell.management/set-item?view=powershell-7.4)



