# Setting the Maintenance Mode of a Machine

This page outlines the base script for setting the maintenance mode of a machine on Citrix Virtual Apps and Desktops (CVAD).



## 1. Base Script: Set-MaintenanceMode.ps1

The `Set-MaintenanceMode.ps1` script is designed to set the maintenance of a machine. It requires the following parameters:

    1. MachineName: The name of the machine to set the maintenance mode.
    
    2. MaintenanceMode: Sets whether the machine is in maintenance mode or not. A machine in maintenance mode is not available for new sessions, and for managed machines all automatic power management is disabled.
    
    3. AdminAddress: The primary DDC address.
    
The script can be executed with parameters as shown in the examples below:

```powershell
# Turn on the maintenance mode for the machine named "MyMachine" in the "MyDomain" domain 
.\Set-MaintenanceMode.ps1 -MachineName "MyDomain\MyMachine" -MaintenanceMode $True -AdminAddress "MyDDC.MyDomain.local"

# Turn off the maintenance mode for the machine named "MyMachine" in the "MyDomain" domain
.\Set-MaintenanceMode.ps1 -MachineName "MyDomain\MyMachine" -MaintenanceMode $False -AdminAddress "MyDDC.MyDomain.local"
```



## 2. Overview of the Base Script

The process of setting the maintenance mode of a machine is simplified into two key steps:

    1. Set the Maintenance Mode.
    


## 3. Detail of the Base Script

This section explores each step in the base script, outlining the key parameters involved.

**Step 1: Set the Maintenance Mode.**

Set the maintenance mode of the machine by using ``Set-BrokerMachineMaintenanceMode``. The parameters for this cmdlet are described below.

    1. InputObject.
    Specifies Uid of the broker machine to set the maintenance mode.
        
    2. MaintenanceMode.
    Sets whether the machine is in maintenance mode or not, e.g., $True or $False.


## 4. Common Errors During Operation

1. If the name of the ProvScheme is invalid, the error message is "Get-BrokerMachine : Object does not exist."

2. If the name of the ProvScheme is invalid, the error message is "Set-BrokerMachineMaintenanceMode : Cannot bind argument to parameter 'InputObject' because it is null."



## 5. Reference Documents

For comprehensive information and further reading, the following resources are recommended. These include CVAD SDK documentation and other relevant references (as applicable):

1. [CVAD SDK - Get-BrokerMachine](https://developer-docs.citrix.com/en-us/citrix-virtual-apps-desktops-sdk/current-release/Broker/Get-BrokerMachine.html)
2. [CVAD SDK - Set-BrokerMachineMaintenanceMode](https://developer-docs.citrix.com/en-us/citrix-virtual-apps-desktops-sdk/current-release/Broker/Set-BrokerMachineMaintenanceMode.html)

