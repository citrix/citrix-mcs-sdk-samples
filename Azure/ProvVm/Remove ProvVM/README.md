# Remove Provisioned VM
## Overview
There's a set of 3 cmdlets used together to delete a virtual machine:
1. Remove-ProvVM removes the virtual machine from Machine Creation Services and the hypervisor.
2. Remove-BrokerMachine removes the machine from its associated Broker catalog.
3. Remove-AcctADAccount removes the associated AD account the machine was using from Machine Creation Services and can delete or disable the account in Active Directory.
Documentation to learn more about [Remove-ProvVM](https://developer-docs.citrix.com/en-us/citrix-virtual-apps-desktops-sdk/current-release/MachineCreation/Remove-ProvVM.html).
Documentation to learn more about [Remove-BrokerMachine](https://developer-docs.citrix.com/en-us/citrix-virtual-apps-desktops-sdk/current-release/Broker/Remove-BrokerMachine.html).
Documentation to learn more about [Remove-AcctADAccount](https://developer-docs.citrix.com/en-us/citrix-virtual-apps-desktops-sdk/current-release/ADIdentity/Remove-AcctADAccount.html).

## How to remove a ProvVM
you can simply run Remove-ProvVM to remove the ProvVM. For example: 
```powershell
Remove-ProvVM -ProvisioningSchemeName "MyCatalog" -VMName "MyVM"
```

## How to remove a ProvVM while retaining persistent machine in Azure
The `ForgetVM` parameter proves beneficial when removing ProvVM data from the Citrix site database while preserving the machine in Azure. The Azure VM and its associated resources (disks, network interfaces, etc.) will persist in Azure. However, resource tags, particularly those starting with `Citrix` (e.g., CitrixProvisioningSchemeId), generated during the MCS provisioning process, will be deleted.
For example:
```powershell
Remove-ProvVM -ProvisioningSchemeName "MyCatalog" -VMName "MyVM" -ForgetVM
```

**Note**: 
1. `ForgetVM` is not applied to a non-persistent VM. 
2. `ForgetVM` and `PurgeDBOnly` parameters cannot be specified at the same time.

## How to remove a provisioning scheme when the hypervisor connection is lost 
The `PurgeDBOnly` parameter proves valuable in scenarios where communication with the hypervisor is no longer possible, and there is a need to exclusively remove a ProvVM from the Citrix site database. In this case, the Azure resources associated with the VM, such as disks and NICs, will persist in Azure. Additionally, tags generated during the MCS provisioning process will remain unaffected.
```powershell
Remove-ProvVM -ProvisioningSchemeName "MyCatalog" -VMName "MyVM" -PurgeDBOnly
```

**Note**: 
1.`ForgetVM` and `PurgeDBOnly` parameters cannot be specified at the same time.
 
## Common error cases
Machine removal failed due to invalid ProvisioningSchemeName/VMName/MachineName provided. Error message example "The specified ProvisioningScheme could not be located."

## Next steps
1. To provision a new virtual machine take the reference of sample scripts in Add ProvVM.
2. To update the details of a Provisioning virtual machine take the reference of sample scripts in Update ProvVM.
3. To retrieve information about a Provisioning virtual machine take the reference of sample scripts in Get ProvVM.