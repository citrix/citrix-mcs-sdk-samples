# Remove Provisioned VM
## Overview
There's a set of 3 cmdlets used together to delete a virtual machine:
1. Remove-ProvVM removes the virtual machine from Machine Creation Services and the hypervisor.
2. Remove-BrokerMachine removes the machine from its associated Broker catalog.
3. Remove-AcctADAccount removes the associated AD account the machine was using from Machine Creation Services and can delete or disable the account in Active Directory.

**Note**
This procedure consistently deletes data from the Citrix Machine Creation Services and it's Database.
1. In the absence of specifying 'ForgetVM'/'PurgeDBOnly', all resources of catalog VMs (such as disks, network interfaces, etc.) created in SCVMM will also be eliminated.
2. If 'ForgetVM' is indicated, resources of catalog VMs (disks, network interfaces, etc.) created in SCVMM will be preserved. However, only provisioning-related tags/identifiers on those resources will be removed.
3. When 'PurgeDBOnly' is specified, VM resources and their associated tags created in SCVMM will remain unaffected.
Documentation to learn more about [Remove-ProvVM](https://developer-docs.citrix.com/en-us/citrix-virtual-apps-desktops-sdk/current-release/MachineCreation/Remove-ProvVM.html).
Documentation to learn more about [Remove-BrokerMachine](https://developer-docs.citrix.com/en-us/citrix-virtual-apps-desktops-sdk/current-release/Broker/Remove-BrokerMachine.html).
Documentation to learn more about [Remove-AcctADAccount](https://developer-docs.citrix.com/en-us/citrix-virtual-apps-desktops-sdk/current-release/ADIdentity/Remove-AcctADAccount.html).
 
## Common error cases
1. ForgetVM is applicable to persistent virtual machines only and cannot be used on non-persistent virtual machines.
2. ForgetVM and PurgeDBOnly cannot be used simultaneously with Remove-ProvScheme.
3. Machine removal failed due to invalid ProvisioningSchemeName/VMName/MachineName provided.

## Next steps
1. To provision a new virtual machine, use the scripts in Add ProvVM.
2. To retrieve information about a Provisioning virtual machine, use scripts in Get ProvVM.