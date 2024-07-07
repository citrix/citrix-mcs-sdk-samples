# Removing Virtual Machines to a Machine Catalog

This page outlines the base script for removing Virtual Machines (VMs) from a Machine Catalog on Citrix Virtual Apps and Desktops (CVAD).



## 1. Base Script: Remove-ProvVM.ps1

The `Remove-ProvVM.ps1` script removes VMs from a machine catalog. The script requires:

    1. ProvisioningSchemeName: The name of the provisioning scheme where VMs will be removed.
    
    2. VmNamesToRemove: The names of VMs to be removed.
    
    3. Domain: The AD Domain name. 
    
    4. UserName: The User Name for Authentication
    
    5. AdminAddress: The primary DDC address.

    Additionally, the script supports these optional parameters:

    6. PurgeDBOnly: A flag to remove VM records from the Machine Creation Services database without deleting the actual VMs and hard disk copies from the hypervisor.
    
    7. ForgetVM: A flag to disassociate VMs from Citrix management, removing Citrix-specific tags/identifiers, while retaining the VMs and hard disk copies in the hypervisor.
    
The script can be executed with parameters as shown in the example below:

```powershell
# Remove VMs with AD Credentials
.\Remove-ProvVM.ps1 `
    -ProvisioningSchemeName "MyCatalog" `
    -VmNamesToRemove "MyVM001", "MyVM002" `
    -Domain "MyDomain.local" `
    -UserName "MyUserName" `
    -Password "MyPassword" `
    -AdminAddress "MyDDC.MyDomain.local"

# Remove VMs with PurgeDBOnly
.\Remove-ProvVM.ps1 `
    -ProvisioningSchemeName "MyCatalog" `
    -VmNamesToRemove "MyVM001", "MyVM002" `
    -Domain "MyDomain.local" `
    -UserName "MyUserName" `
    -Password "MyPassword" `
    -PurgeDBOnly $True `
    -AdminAddress "MyDDC.MyDomain.local"

# Remove VMs with ForgetVM
.\Remove-ProvVM.ps1 `
    -ProvisioningSchemeName "MyCatalog" `
    -VmNamesToRemove "MyVM001", "MyVM002" `
    -Domain "MyDomain.local" `
    -UserName "MyUserName" `
    -Password "MyPassword" `
    -ForgetVM $True `
    -AdminAddress "MyDDC.MyDomain.local"
```

Administrators should tailor these parameters to fit their specific environment.



## 2. Overview of the Base Script

The base script is segmented into three key steps, providing a structured approach to catalog creation:

    1. Remove ProvVM(s)
    2. Remove Broker Machine(s)
    3. Remove AcctADAccount(s)
    


## 3. Detail of the Base Script

In this section, we dive into the specifics of each step in the base script for removing Provisoning VMs. For each step, key parameters and their roles are outlined to give you a comprehensive understanding of the process.

**Step 1: Remove ProvVM(s)**

Removes virtual machines created by Machine Creation Services by using ```Remove-ProvVM```. The parameters for ```Remove-ProvVM``` are described below.

    1. ProvisioningSchemeName.
    The name of the provisioning scheme from which VMs will be removed.	

    2. VMName.
    List of VM names that will be removed from the provisioning scheme.	

    3. PurgeDBOnly.
    If this option is specified, this command will only remove VM objects from the Machine Creation Services database; however, the VMs and hard disk copies still remain in the hypervisor. The hypervisor administrator can remove the VMs and hard disk images using the tools provided by the hypervisor itself. If not specified, the VMs and hard disk copies are also removed from hypervisor storage. This parameter is exclusive with “ForgetVM”.

    4. ForgetVM
    If this option is specified, this command will only remove VM objects from the Machine Creation Services database; however, the VMs and hard disk copies still remain in the hypervisor after removing VMs’ citrix tags/identifiers. The hypervisor administrator can remove the VMs and hard disk images using the tools provided by the hypervisor itself. If not specified, the VMs and hard disk copies are also removed from hypervisor storage. This parameter is only applied to persistent VMs and exclusive with “PurgeDBOnly”.	

**Step 2: Remove Broker Machine(s)**

Removes one or more machines from its desktop group or catalog by using ```Remove-BrokerMachine```. The parameters for ```Remove-BrokerMachine``` are described below.

    1. MachineName.
    The name of the single machine to remove (must match the MachineName property of the machine).	

    2. Force.
    Forces removal of machine from a desktop group even if it is still in use (that is, there are user sessions running on the machine). Forcing removal of a machine does not disconnect or logoff the user sessions.	

**Step 3: Remove AcctADAccount(s)**

Removes Active Directory (AD) computer accounts from an identity pool by using ```Remove-AcctADAccount```. The parameters for ```Remove-AcctADAccount``` are described below.

    1. IdentityPoolName.
    The name of the identity pool from which accounts are to be removed.	

    2. ADAccountSid
    The SID for the AD account to be removed.	

    3. RemovalOption
    Defines the behavior relating to the AD account.	

    4. Force
    Indicates if accounts that are marked as ‘in-use’ can be removed.	

    5. ADUserName
    The username for an AD user account with Write Permissions. This parameter must be used if the current user does not have the necessary privileges.	

    6. ADPassword
    The matching password for an AD user account with Write Permissions. This parameter must be used if the current user does not have the necessary privileges.	

## 4. Common Errors During Operation

1. If the name of the ProvScheme is invalid, the error message is "Remove-ProvVM : The specified ProvisioningScheme could not be located."



## 5. Reference Documents

For comprehensive information and further reading, the following resources are recommended. These include CVAD SDK documentation and other relevant references (as applicable):

1. [CVAD SDK - Get-ProvVM](https://developer-docs.citrix.com/en-us/citrix-virtual-apps-desktops-sdk/current-release/MachineCreation/Get-ProvVM.html)
2. [CVAD SDK - Unlock-ProvVM](https://developer-docs.citrix.com/en-us/citrix-virtual-apps-desktops-sdk/current-release/MachineCreation/Unlock-ProvVM.html)
3. [CVAD SDK - Remove-ProvVM](https://developer-docs.citrix.com/en-us/citrix-virtual-apps-desktops-sdk/current-release/MachineCreation/Remove-ProvVM.html)
4. [CVAD SDK - Get-BrokerMachine](https://developer-docs.citrix.com/en-us/citrix-virtual-apps-desktops-sdk/current-release/Broker/Get-BrokerMachine.html)
5. [CVAD SDK - Remove-BrokerMachine](https://developer-docs.citrix.com/en-us/citrix-daas-sdk/Broker/Remove-BrokerMachine.html)
6. [CVAD SDK - Get-AcctADAccount](https://developer-docs.citrix.com/en-us/citrix-virtual-apps-desktops-sdk/current-release/ADIdentity/Get-AcctADAccount.html)
7. [CVAD SDK - Remove-AcctADAccount](https://developer-docs.citrix.com/en-us/citrix-virtual-apps-desktops-sdk/current-release/ADIdentity/Remove-AcctADAccount.html)


