### Create ProvScheme and Catalog
## Overview
Sample admin scenario scripts provide Administrator some of the frequently used cmdlets. Part of these scripts are covered in different sections. Example script Create-Catalog.ps1 in this folder helps to create a provisioning scheme and Prov VMs with new identity pool and a Broker catalog. 
Creating a ProvScheme alone does not make it visible in the Studio. You need to create a Broker Catalog to view and manage it from the Studio.
Example script Create-Catalog-In-Diff-Region.ps1 creates an MCS ProvisioningScheme from an Image in a different region. In GCP an Image is a replica of a disk that contains the applications and operating system needed to start a VM.

For more detailed information on creating a new ProvScheme, Broker Catalog and Virtual Machines, refer to the following documentation:
1. [New-AcctIdentityPool](https://developer-docs.citrix.com/en-us/citrix-virtual-apps-desktops-sdk/current-release/adidentity/new-acctidentitypool)
2. [New-AcctADAccount](https://developer-docs.citrix.com/en-us/citrix-virtual-apps-desktops-sdk/current-release/ADIdentity/New-AcctADAccount.html)
3. [New-ProvScheme](https://developer-docs.citrix.com/en-us/citrix-virtual-apps-desktops-sdk/2311/MachineCreation/New-ProvScheme.html).
4. [New-ProvVM](https://developer-docs.citrix.com/en-us/citrix-virtual-apps-desktops-sdk/current-release/MachineCreation/New-ProvVM.html)
5. [New-BrokerMachine](https://developer-docs.citrix.com/en-us/citrix-virtual-apps-desktops-sdk/current-release/Broker/New-BrokerMachine.html)
6. [New-BrokerCatalog](https://developer-docs.citrix.com/en-us/citrix-virtual-apps-desktops-sdk/2311/Broker/New-BrokerCatalog.html)

**Note**: 
Please be aware that New-ProvScheme is a long running operation and it may take awhile to complete.

### Common error cases
1. Namingscheme does not have enough characters or has too many characters.
2. Namingscheme starts with a period (.)
3. Namingscheme does not have '#' character.
4. An Identity Pool with the same name already exists.
5. Failed to create AD accounts if ADUserName/ADPassword/IdentityPoolName provided are not valid. Example error message is "Identity Pool not found."
6. Failed to create virtual machines if ProvisioningSchemeName provided is not valid. Example error message is "The specified ProvisioningScheme could not be located."