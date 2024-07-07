# Removing a Provisioning Scheme

This page outlines the base script for removing a Provisioning Scheme on Citrix Virtual Apps and Desktops (CVAD).



## 1. Base Script: Remove-ProvScheme.ps1

The `Remove-ProvScheme.ps1` script removes a Provisioning Scheme and requires the following parameters:

    1. ProvisioningSchemeName: Name of the Machine Catalog to be removed.
    
    2. AdminAddress: The primary DDC address.
    
    Additionally, the script supports these optional parameters:

    3. PurgeDBOnly: A flag to remove VM records from the Machine Creation Services database without deleting the actual VMs and hard disk copies from the hypervisor.
    
    4. ForgetVM: A flag to disassociate VMs from Citrix management, removing Citrix-specific tags/identifiers, while retaining the VMs and hard disk copies in the hypervisor.
    
The script can be executed with parameters as shown in the example below:

```powershell
# Remove a ProvScheme
.\Remove-ProvScheme.ps1 `
    -ProvisioningSchemeName "MyProvScheme" `
    -AdminAddress "MyDDC.MyDomain.local"

# Remove a ProvScheme with PurgeDBOnly
.\Remove-ProvScheme.ps1 `
    -ProvisioningSchemeName "MyProvScheme" `
    -AdminAddress "MyDDC.MyDomain.local" `
    -PurgeDBOnly $True

# Remove a ProvScheme with ForgetVM
.\Remove-ProvScheme.ps1 `
    -ProvisioningSchemeName "MyProvScheme" `
    -AdminAddress "MyDDC.MyDomain.local" `
    -ForgetVM $True
```

Administrators should tailor these parameters to fit their specific environment.



## 2. Overview of the Base Script

The base script is segmented into six key steps, providing a structured approach to removing a Provisioning Scheme:

    1. Remove a Provisioning Scheme



## 3 Detail of the Base Script

In this section, we dive into the specifics of each step in the base script for removing a Provisioning Scheme. For each step, key parameters and their roles are outlined to give you a comprehensive understanding of the process.

**Step 1: Remove a Provisioning Scheme.**

Remove a provisioning scheme by using Remove-ProvScheme. The parameters for Remove-ProvScheme are described below.

    1. ProvisioningSchemeName.
    The name of the provisioning scheme to be removed.	
    
    2. PurgeDBOnly
    If this option is specified, this command will only remove VM objects from the Machine Creation Services database; however, the VMs and hard disk copies still remain in the hypervisor. The hypervisor administrator can remove the VMs and hard disk images using the tools provided by the hypervisor itself. If not specified, the VMs and hard disk copies are also removed from hypervisor storage. This parameter is exclusive with “ForgetVM”.	

    3. ForgetVM
    If this option is specified, this command will only remove VM objects from the Machine Creation Services database; however, the VMs and hard disk copies still remain in the hypervisor after removing VMs’ citrix tags/identifiers. The hypervisor administrator can remove the VMs and hard disk images using the tools provided by the hypervisor itself. If not specified, the VMs and hard disk copies are also removed from hypervisor storage. This parameter is only applied to persistent VMs and exclusive with “PurgeDBOnly”.	


## 4. Common Errors During Operation

1. If the name of the ProvScheme is invalid, the error message is "Remove-ProvScheme : The specified ProvisioningScheme could not be located."



## 5. Reference Documents

For comprehensive information and further reading, the following resources are recommended. These include CVAD SDK documentation and other relevant references (as applicable):

1. [CVAD SDK - Remove-BrokerMachine](https://developer-docs.citrix.com/en-us/citrix-daas-sdk/Broker/Remove-BrokerMachine.html)
2. [CVAD SDK - Remove-BrokerCatalog](https://developer-docs.citrix.com/en-us/citrix-virtual-apps-desktops-sdk/current-release/Broker/Remove-BrokerCatalog.html)
3. [CVAD SDK - Get-AcctIdentityPool](https://developer-docs.citrix.com/en-us/citrix-daas-sdk/adidentity/get-acctidentitypool)
4. [CVAD SDK - Get-AcctADAccount](https://developer-docs.citrix.com/en-us/citrix-virtual-apps-desktops-sdk/current-release/ADIdentity/Get-AcctADAccount.html)
5. [CVAD SDK - Remove-AcctADAccount](https://developer-docs.citrix.com/en-us/citrix-virtual-apps-desktops-sdk/current-release/ADIdentity/Remove-AcctADAccount.html)
6. [CVAD SDK - Remove-AcctIdentityPool](https://developer-docs.citrix.com/en-us/citrix-daas-sdk/ADIdentity/Remove-AcctIdentityPool.html)
7. [CVAD SDK - Remove-ProvScheme](https://developer-docs.citrix.com/en-us/citrix-virtual-apps-desktops-sdk/current-release/MachineCreation/Remove-ProvScheme.html)
8. [CVAD SDK - Unlock-ProvVM](https://developer-docs.citrix.com/en-us/citrix-virtual-apps-desktops-sdk/current-release/MachineCreation/Unlock-ProvVM.html)
9. [CVAD SDK - Remove-ProvVM](https://developer-docs.citrix.com/en-us/citrix-virtual-apps-desktops-sdk/current-release/MachineCreation/Remove-ProvVM.html)


