# Creating a Power Action for a Machine**

This page outlines the base script for creating a power action for a machine on Citrix Virtual Apps and Desktops (CVAD).



## 1. Base Script: PowerAction.ps1

The `PowerAction.ps1` script is designed to create a power action for a machine. It requires the following parameters:

    1. Action: Specifies the power state change action that is to be performed on the specified machine. Valid values are: 
        - TurnOn: Power on a machine.
        - TurnOff: Force shutdown a machine.
        - ShutDown: Shutdown a machine.
        - Reset: Force to reboot a machine.
        - Restart: Reboot a machine.
        - Suspend: Suspend a machine.
        - Resume: Resume a machine
    
    2. MachineName: Specifies the machine that the action is to be performed on.

    3. AdminAddress: The primary DDC address.
    
The script can be executed with parameters as shown in the examples below:

```powershell
# Power on the machine named "MyMachine"
.\PowerAction.ps1 -Action "TurnOn"  -MachineName "MyMachine" -AdminAddress "MyDDC.MyDomain.local"

# Force shutdown the machine named "MyMachine"
.\PowerAction.ps1 -Action "TurnOff"  -MachineName "MyMachine" -AdminAddress "MyDDC.MyDomain.local"

# Shutdown the machine named "MyMachine"
.\PowerAction.ps1 -Action "ShutDown"  -MachineName "MyMachine" -AdminAddress "MyDDC.MyDomain.local"

# Force to reboot the machine named "MyMachine"
.\PowerAction.ps1 -Action "Reset"  -MachineName "MyMachine" -AdminAddress "MyDDC.MyDomain.local"

# Rboot the machine named "MyMachine"
.\PowerAction.ps1 -Action "Restart"  -MachineName "MyMachine" -AdminAddress "MyDDC.MyDomain.local"

# Suspend the machine named "MyMachine"
.\PowerAction.ps1 -Action "Suspend"  -MachineName "MyMachine" -AdminAddress "MyDDC.MyDomain.local"

# Resume the machine named "MyMachine"
.\PowerAction.ps1 -Action "Resume"  -MachineName "MyMachine" -AdminAddress "MyDDC.MyDomain.local"
```



## 2. Overview of the Base Script

The process of creating a power action for a machine is simplified into one key step:

    1. Create a New Action in the Power Action Queue.



## 3. Detail of the Base Script

This section explores each step in the base script, outlining the key parameters involved.

**Step 1: Create a New Action in the Power Action Queue.**

Creates a new power on action in the power action queue by using ``New-BrokerHostingPowerAction``. The parameters for this cmdlet are described below.

    1. Action.
    Specifies the power state change action that is to be performed on the specified machine.
        
    2. MachineName.
    Specifies the machine that the action is to be performed on.


## 4. Common Errors During Operation

1. If the machine name is invalid, the error message is "New-BrokerHostingPowerAction : Machine not found."



## 5. Reference Documents

For comprehensive information and further reading, the following resources are recommended. These include CVAD SDK documentation and other relevant references (as applicable):

1. [CVAD SDK - New-BrokerHostingPowerAction](https://developer-docs.citrix.com/en-us/citrix-virtual-apps-desktops-sdk/current-release/Broker/New-BrokerHostingPowerAction.html)


