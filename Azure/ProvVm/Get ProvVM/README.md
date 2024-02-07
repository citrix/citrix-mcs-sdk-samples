# Get Provisioned VM
## Overview
The Get-ProvVm enables you to obtain a list of virtual machines created through Citrix Machine Creation Services.
To know more details about Get-ProvVM refer - https://developer-docs.citrix.com/en-us/citrix-virtual-apps-desktops-sdk/current-release/MachineCreation/Get-ProvVM.html.

**Note**
1. By setting the -Locked parameter to true, you can retrieve all locked virtual machines, irrespective of the Provisioning Scheme used to create the VM. The virtual machines undergo a lock state when adding or removing machines from the Broker Catalog.
2. Retrieves all virtual machines provisioned in a specified Provisioning Scheme when the -ProvisioningSchemeName parameter is provided.
3. Retrieves a specific virtual machine provisioned in a designated Provisioning Scheme when both -ProvisioningSchemeName and -VMName are specified.

## Here are some common errors encountered during Get-ProvVM
Failed to retrieve details of ProvVM if the provided ProvisioningSchemeName/VMName are invalid.

## Next steps
1. To update the details of a Provisioning virtual machine take the reference of sample scripts in Update ProvVM.
2. To remove a Provisioning virtual machine take the reference of sample scripts in Remove ProvVM.
3. To provision a new virtual machine take the reference of sample scripts in Add ProvVM.