# Remove Provisioned Virtual Machine
## Overview
Remove Provisioned VM used to delete a VM from the hypervisor and citrix database. Remove-ProvVM stops and deletes the vm, does not depend on the maintenance window to run. There's a set of 3 cmdlets used together to delete a virtual machine:
1. Remove-ProvVM removes the virtual machine from Machine Creation Services (MCS) and the hypervisor.
2. Remove-BrokerMachine removes the machine from its associated Broker catalog.
3. Remove-AcctADAccount removes the associated AD account the machine was using from Machine Creation Services and can delete or disable the account in Active Directory.

For more detailed information on removing virtual machines, refer to the following documentation:
1. [Remove-ProvVM](https://developer-docs.citrix.com/en-us/citrix-virtual-apps-desktops-sdk/current-release/MachineCreation/Remove-ProvVM.html).
2. [Remove-BrokerMachine](https://developer-docs.citrix.com/en-us/citrix-virtual-apps-desktops-sdk/current-release/Broker/Remove-BrokerMachine.html).
3. [Remove-AcctADAccount](https://developer-docs.citrix.com/en-us/citrix-virtual-apps-desktops-sdk/current-release/ADIdentity/Remove-AcctADAccount.html).

## How to remove a ProvVM
To remove a provisioned virtual machine from MCS and the hypervisor, run Remove-ProvVM:
```powershell
Remove-ProvVM -ProvisioningSchemeName "MyCatalog" -VMName "MyVM"
```

## How to remove a ProvVM while retaining persistent machine in GCP
If the `ForgetVM` parameter is specified during Remove-ProvVM, The VM(Virtual Machine) and its resources will not be removed from the hypervisor. This command only removes the provisioned VM from the Citrix site database and deletes Citrix-assigned identifiers(like tags or custom-attributes) on the hypervisor VM. The parameter is useful if you want to remove VM data from the Citrix but want to leave it at the GCP hypervisor. The  VM and its associated resources (disks, network interfaces, etc.) will persist in GCP after the machine is removed from the Citrix database. 
ProvVM remove example:
```powershell
Remove-ProvVM -ProvisioningSchemeName "MyCatalog" -VMName "MyVM" -ForgetVM
```
## Removing AD accounts for deleted VMs
**Note**: 
`Remove-AcctADAccount` command only removes the AD account from the identity pool within the Citrix AD Identity Service. if you want to remove AD account from AD server use -ADUserName and -ADPassword option with this command

## How to remove a provisioning scheme when the hypervisor connection is lost 
The `PurgeDBOnly` parameter is useful in scenarios where communication with the hypervisor is no longer possible, and there is a need to exclusively remove a ProvVM from the Citrix site database. In this case, the GCP resources associated with the VM, such as disks and NICs, will persist in GCP. Additionally, tags generated during the MCS provisioning process will also remain unaffected.
```powershell
Remove-ProvVM -ProvisioningSchemeName "MyCatalog" -VMName "MyVM" -PurgeDBOnly
```

**Note**: 
1. `ForgetVM` parameter is not applied to a non-persistent VM. 
2. `ForgetVM` and `PurgeDBOnly` parameters cannot be specified at the same time.

## Common error cases
Machine removal failed due to invalid ProvisioningSchemeName/VMName/MachineName provided. Error message example "The specified ProvisioningScheme could not be located."

## Next steps
1. To provision a new Virtual Machine, please refer to the sample scripts in "GCP\ProvVM\Add ProvVM" section.
2. To retrieve information about Virtual Machines, please refer to the sample scripts in "GCP\ProvVM\Get ProvVM" section.