# Updating High-Availability Servers of a Hosting Connection

This page outlines the base script for updating high-availability servers of a Hosting Connection on Citrix Virtual Apps and Desktops (CVAD). 



## 1. Base Script: Update-HighAvailabilityServer

The `Update-HighAvailabilityServer` script is designed to update high-availability servers of an existing hosting connection. It requires the following parameters:

    1. ConnectionName: The name of the hosting connection to update.
    
    2. HypervisorAddress: The IP addresses of hypervisors.
    
    3. ZoneUid: The UID that corresponds to the Zone.

The script can be executed with parameters as shown in the example below:

```powershell
.\Update-HighAvailabilityServer `
    -ConnectionName "MyConnection" `
    -HypervisorAddress "http://88.88.88.88","http://88.88.88.89" `
    -ZoneUid "00000000-0000-0000-0000-000000000000"
```

Administrators should tailor these parameters to fit their specific environment.



## 2. Overview of the Base Script

The process of updating high-availability servers is simplified into one key step:

    1. Update High-Availability Servers.



## 3. Detail of the Base Script

This section explores each step in the base script, outlining the key parameters involved.

**Step 1: Update High-Availability Servers.**

Update high-availability servers of a hosting connection by using ``Set-Item``. The parameters for ``Set-Item`` are described below.

    1. LiteralPath.
    Specifies path of the the hosting connections, e.g., "XDHyp:\Connections\MyConnection"

    2. HypervisorAddress.
    Specifies the names of the scopes to add, e.g., @("http://88.88.88.88","http://88.88.88.89")



## 4. Common Errors During Operation

1. If the connection address is invalid, the error message is "et-Item : The hypervisor was not contactable at the supplied address. (Reason = Unexpected character encountered while parsing value: <. Path '', line 0, position 0.)."



## 5. Reference Documents

For comprehensive information and further reading, the following resources are recommended. These include CVAD SDK documentation and other relevant references (as applicable):

1. [Microsoft PowerShell SDK - Set-Item](https://learn.microsoft.com/en-us/powershell/module/microsoft.powershell.management/set-item?view=powershell-7.4)



