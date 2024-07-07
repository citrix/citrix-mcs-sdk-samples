# Adding Virtual Machines to a Machine Catalog

This page outlines the base script for adding Virtual Machines (VMs) to a Machine Catalog on Citrix Virtual Apps and Desktops.



## 1. Base Script: Add-ProvVM.ps1

The `Add-ProvVM.ps1` script adds VMs to a machine catalog. The script requires:

    1. ProvisioningSchemeName: The name of the provisioning scheme where VMs will be added.
    2. Count: Specifies the number of VMs to be added.
    3. AdminAddress: The primary DDC address.
    
The script can be executed with parameters as shown in the example below:

```powershell
.\Add-ProvVM.ps1 `
    -ProvisioningSchemeName "MyCatalog" `
    -Count 2 `
    -AdminAddress "MyDDC.MyDomain.local"
```

Administrators should tailor these parameters to fit their specific environment.



## 2. Overview of the Base Script

The base script is segmented into three key steps, providing a structured approach to catalog creation:

    1. Create new AcctADAccount(s).
    2. Create new ProvVM(s).
    3. Create new Broker Machine(s).
    


## 3. Detail of the Base Script

In this section, we dive into the specifics of each step in the base script for creating Provisioning VMs. For each step, key parameters and their roles are outlined to give you a comprehensive understanding of the process.

**Step 1: Create new AcctADAccount(s).**

Creating Active Directory (AD) computer accounts in the specified identity pool by using New-AcctADAccount. The parameters for New-AcctADAccount are described below.

    1. IdentityPoolUid.
    The unique identifier for the identity pool in which accounts will be created.
    The scripts here extract the IdentityPoolUid from the result of New-AcctIdentityPool.

    2. Count.
    The number of accounts to create.

**Step 2: Create new ProvVM(s).**

Creating virtual machines with the configuration specified by a provisioning scheme by using New-ProvVM. The parameters for New-ProvVM are described below.

    1. ADAccountName.
    A list of the Active Directory account names that are used for the VMs. The accounts must be provided in a domain-qualified format. This parameter accepts Identity objects as returned by the New-AcctADAccount cmdlet, or any PSObject with string properties “Domain” and “ADAccountName”.	

    2. ProvisioningSchemeUid.
    The unique identifier of the provisioning scheme in which the VMs are created.	

**Step 3: Create new Broker Machine(s).**

Adding broker machines to the broker catalog to manage the macines in the site by using New-BrokerMachine. The parameters for New-BrokerMachine are described below.

    1. CatalogUid.
    The catalog to which this machine will belong.	

    2. MachineName
    Specify the name of the machine to create (in the form ‘domain\machine’). A SID can also be specified.	


## 4. Common Errors During Operation

1. If the name of the ProvScheme is invalid, the error message is "New-AcctADAccount : Cannot bind argument to parameter 'IdentityPoolUid' because it is null."

2. If the name of the ProvScheme is invalid, the error message is "New-ProvVM : Cannot validate argument on parameter 'ADAccountName'. The number of provided arguments (0) is fewer than the minimum number of allowed arguments (1). Provide more than 1 arguments, and      
then try the command again."

## 5. Reference Documents

For comprehensive information and further reading, the following resources are recommended. These include CVAD SDK documentation and other relevant references (as applicable):

1. [CVAD SDK - Get-AcctIdentityPool](https://developer-docs.citrix.com/en-us/citrix-virtual-apps-desktops-sdk/current-release/ADIdentity/Get-AcctIdentityPool.html)
2. [CVAD SDK - New-AcctADAccount](https://developer-docs.citrix.com/en-us/citrix-virtual-apps-desktops-sdk/current-release/ADIdentity/New-AcctADAccount.html)
3. [CVAD SDK - New-ProvVM](https://developer-docs.citrix.com/en-us/citrix-virtual-apps-desktops-sdk/current-release/MachineCreation/New-ProvVM.html)
4. [CVAD SDK - Lock-ProvVM](https://developer-docs.citrix.com/en-us/citrix-virtual-apps-desktops-sdk/current-release/MachineCreation/Lock-ProvVM.html)
5. [CVAD SDK - Get-BrokerCatalog](https://developer-docs.citrix.com/en-us/citrix-virtual-apps-desktops-sdk/current-release/Broker/Get-BrokerCatalog.html)
6. [CVAD SDK - New-BrokerMachine](https://developer-docs.citrix.com/en-us/citrix-virtual-apps-desktops-sdk/current-release/Broker/New-BrokerMachine.html)
7. [CVAD SDK - Remove-ProvTask](https://developer-docs.citrix.com/en-us/citrix-virtual-apps-desktops-sdk/current-release/MachineCreation/Remove-ProvTask.html)


