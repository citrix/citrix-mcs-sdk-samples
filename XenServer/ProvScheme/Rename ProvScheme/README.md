# Renaming a Machine Catalog

This page outlines the base script for renaming a Machine Catalog on Citrix Virtual Apps and Desktops (CVAD). 



## 1. Base Script: Rename-MachineCatalog.ps1

The `Rename-MachineCatalog.ps1` script is designed to rename tests on a specified machine catalog. It requires the following parameters:

    1. CatalogName: The name of the catalog.
    
    2. NewCatalogName The new name of the catalog.
    
    3. AdminAddress: The primary DDC address.

The script can be executed with parameters as shown in the example below:

```powershell
.\Rename-MachineCatalog.ps1 `
    -CatalogName "MyCatalog" `
    -NewCatalogName "MyRenamedCatalog" `
    -AdminAddress "MyDDC.MyDomain.local"
```

Administrators should tailor these parameters to fit their specific environment.



## 2. Overview of the Base Script

The process of testing a hosting unit is simplified into one key step:

    1. Check if the Proposed New Name is Unused.
    2. Rename the Broker Catalog.
    3. Rename the Provisioning Scheme.
    4. Rename the IdentityPool.



## 3. Detail of the Base Script

This section explores each step in the base script, outlining the key parameters involved.

**Step 1: Check if the Proposed New Name is Unused.**
Check if the proposed new name is unused by using ``Test-ProvSchemeNameAvailable`` and ``Test-AcctIdentityPoolNameAvailable``. 

 ``Test-ProvSchemeNameAvailable`` checks whether the proposed new name is already in use by another ProvScheme. The parameter for this cmdlet is described below.

    1. ProvisioningSchemeName.
    Specifies the new name of the provisioning scheme.

``Test-AcctIdentityPoolNameAvailable`` checks whether the proposed new name is already in use by another IdentityPool. The parameter for this cmdlet is described below.

    1. IdentityPoolName.
    Specifies the new name of the identity pool.

**Step 2: Rename the Broker Catalog.**

Rename the broker catalog by using ``Rename-BrokerCatalog`. The parameters for this cmdlet are described below.

    1. Name.
    Specifies the name of the catalog to rename.

    2. NewName
    Specifies the new name of the catalog.

**Step 3: Rename the Provisioning Scheme.**

Rename the provisioning scheme by using ``Rename-ProvScheme`. The parameters for this cmdlet are described below.

    1. ProvisioningSchemeName
    Specifies the name of provisioning scheme to rename

    2. NewProvisioningSchemeName.
    Specifies the new name of the provisioning scheme.

**Step 4: Rename the IdentityPool.**

Rename the provisioning scheme by using ``Rename-ProvScheme`. The parameters for this cmdlet are described below.

    1. IdentityPoolName
    Specifies the name of Identity Pool to rename.

    2. NewIdentityPoolName.
    Specifies the new name of the Identity Pool.


## 4. Common Errors During Operation

1. If the name of the ProvScheme is invalid, the error message is "Rename-BrokerCatalog : No items match the supplied pattern."

2. If the name of the ProvScheme is invalid, the error message is "Rename-ProvScheme : The specified ProvisioningScheme could not be located."


## 5. Reference Documents

For comprehensive information and further reading, the following resources are recommended. These include CVAD SDK documentation and other relevant references (as applicable):

1. [CVAD SDK - Test-ProvSchemeNameAvailable](https://developer-docs.citrix.com/en-us/citrix-virtual-apps-desktops-sdk/current-release/machinecreation/test-provschemenameavailable)
2. [CVAD SDK - Test-AcctIdentityPoolNameAvailable](https://developer-docs.citrix.com/en-us/citrix-virtual-apps-desktops-sdk/current-release/ADIdentity/Test-AcctIdentityPoolNameAvailable.html)
3. [CVAD SDK - Rename-BrokerCatalog](https://developer-docs.citrix.com/en-us/citrix-virtual-apps-desktops-sdk/current-release/Broker/Rename-BrokerCatalog.html)
4. [CVAD SDK - Rename-ProvScheme](https://developer-docs.citrix.com/en-us/citrix-virtual-apps-desktops-sdk/current-release/MachineCreation/Rename-ProvScheme/)
5. [CVAD SDK - Rename-AcctIdentityPool](https://developer-docs.citrix.com/en-us/citrix-virtual-apps-desktops-sdk/current-release/ADIdentity/Rename-AcctIdentityPool.html)

