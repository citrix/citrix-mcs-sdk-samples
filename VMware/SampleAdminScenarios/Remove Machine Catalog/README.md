# Machine Catalog Deletion

This page outlines the base script for deleting a Machine Catalog on Citrix Virtual Apps and Desktops (CVAD).



## 1. Base Script: Remove-MachineCatalog.ps1

The `Remove-MachineCatalog.ps1` script deletes a machine catalog and requires the following parameters:

    1. ProvisioningSchemeName: Name of the Machine Catalog to be deleted.
    2. Domain: The AD Domain name. 
    3. UserName: The User Name for Authentication
    4. AdminAddress: The primary DDC address.
    
Additionally, the script supports these optional parameters:

    5. PurgeDBOnly: A flag to remove VM records from the Machine Creation Services database without deleting the actual VMs and hard disk copies from the hypervisor.
    6. ForgetVM: A flag to disassociate VMs from Citrix management, removing Citrix-specific tags/identifiers, while retaining the VMs and hard disk copies in the hypervisor.
    
The script can be executed with parameters as shown in the example below:

```powershell
# Delete a ProvScheme with AD Domain Credentials.
.\Remove-MachineCatalog.ps1 `
    -ProvisioningSchemeName "MyIdentityPool" `
    -Domain "MyDomain.local" `
    -UserName "MyUserName" `
    -AdminAddress "MyDDC.MyDomain.local"

# Delete a ProvScheme with PurgeDBOnly
.\Remove-MachineCatalog.ps1 `
    -ProvisioningSchemeName "MyIdentityPool" `
    -Domain "MyDomain.local" `
    -UserName "MyUserName" `
    -AdminAddress "MyDDC.MyDomain.local" `
    -PurgeDBOnly $True

# Delete a ProvScheme with ForgetVM
.\Remove-MachineCatalog.ps1 `
    -ProvisioningSchemeName "MyIdentityPool" `
    -Domain "MyDomain.local" `
    -UserName "MyUserName" `
    -AdminAddress "MyDDC.MyDomain.local" `
    -ForgetVM $True
```

Administrators should tailor these parameters to fit their specific environment.



## 2. Overview of the Base Script

The base script is segmented into six key steps, providing a structured approach to deleting a machine catalog:

    1. Remove Broker Machine(s)
    2. Remove ProvVM(s)
    3. Remove AcctADAccount(s)
    4. Remove an AcctIdentityPool
    5. Remove a Broker Catalog
    6. Remove a Provisioning Scheme



## 3 Detail of the Base Script

In this section, we dive into the specifics of each step in the base script for deleting a Machine Catalog. For each step, key parameters and their roles are outlined to give you a comprehensive understanding of the process.


**Step 1: Remove Broker Machine(s).**

Remove one or more machines from its desktop group or catalog by using Remove-BrokerMachine. The parameters for Remove-BrokerMachine are described below.

    1. MachineName
    Specify the name of the machine to trmobr (in the form ‘domain\machine’).

**Step 2: Remove ProvVM(s).**

Remove virtual machines created by Machine Creation Services by using Remove-ProvVM. The parameters for Remove-ProvVM are described below.

    1. ProvisioningSchemeName
    The name of the provisioning scheme from which VMs will be removed.		

    2. VMName.
    List of VM names that will be removed from the provisioning scheme.	

    3. PurgeDBOnly
    If this option is specified, this command will only remove VM objects from the Machine Creation Services database; however, the VMs and hard disk copies still remain in the hypervisor. The hypervisor administrator can remove the VMs and hard disk images using the tools provided by the hypervisor itself. If not specified, the VMs and hard disk copies are also removed from hypervisor storage. This parameter is exclusive with “ForgetVM”.	

    4. ForgetVM
    If this option is specified, this command will only remove VM objects from the Machine Creation Services database; however, the VMs and hard disk copies still remain in the hypervisor after removing VMs’ citrix tags/identifiers. The hypervisor administrator can remove the VMs and hard disk images using the tools provided by the hypervisor itself. If not specified, the VMs and hard disk copies are also removed from hypervisor storage. This parameter is only applied to persistent VMs and exclusive with “PurgeDBOnly”.	

**Step 3: Remove ADAccount(s).**

Remove Active Directory (AD) computer accounts from an identity pool by using Remove-AcctADAccount. The parameters for Remove-AcctADAccount are described below.

    1. ADAccountSid
    The SID for the AD account to be removed.	

    2. IdentityPoolUid
    The unique identifier for the identity pool from which accounts are to be removed.	

    3. ADUserName
    The username for an AD user account with Write Permissions. This parameter must be used if the current user does not have the necessary privileges.	

    4. ADPassword
    The matching password for an AD user account with Write Permissions. This parameter must be used if the current user does not have the necessary privileges.	

    5. RemovalOption
    Defines the behavior relating to the AD account. Values can be: 
    - None   : Leave them in Active Directory
    - Disable: Disable them in Active Directory
    - Delete : Delete them from Active Directory

**Step 4: Remove an Identity Pool.**

Remove an identity pool by using Remove-AcctIdentityPool. The parameters for Remove-AcctIdentityPool are described below.

    1. IdentityPoolName
    The name of the identity pool to be removed.

**Step 5: Remove a Broker Catalog.**

Remove catalogs from the site by using Remove-BrokerCatalog. The parameters for Remove-BrokerCatalog are described below.

    1. Name
    Specifies the name of the catalog to delete.	

**Step 6: Remove a Provisioning Scheme.**

Remove a provisioning scheme by using Remove-ProvScheme. The parameters for Remove-ProvScheme are described below.

    1. ProvisioningSchemeName.
    The name of the provisioning scheme to be removed.	
    
    2. PurgeDBOnly
    If this option is specified, this command will only remove VM objects from the Machine Creation Services database; however, the VMs and hard disk copies still remain in the hypervisor. The hypervisor administrator can remove the VMs and hard disk images using the tools provided by the hypervisor itself. If not specified, the VMs and hard disk copies are also removed from hypervisor storage. This parameter is exclusive with “ForgetVM”.	

    3. ForgetVM
    If this option is specified, this command will only remove VM objects from the Machine Creation Services database; however, the VMs and hard disk copies still remain in the hypervisor after removing VMs’ citrix tags/identifiers. The hypervisor administrator can remove the VMs and hard disk images using the tools provided by the hypervisor itself. If not specified, the VMs and hard disk copies are also removed from hypervisor storage. This parameter is only applied to persistent VMs and exclusive with “PurgeDBOnly”.	


## 4. Common Errors During Operation

1. If the name of the ProvScheme is invalid, the error message is "Unlock-ProvVM : Cannot bind argument to parameter 'VMID' because it is null."

2. If the name of the ProvScheme is invalid, the error message is "Remove-ProvVM : Cannot bind argument to parameter 'VMName' because it is an empty array."



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


