# Get Provisioned Virtual Machine
## Overview
The Get-ProvVm enables you to obtain a list of virtual machines created through Citrix Machine Creation Services.

For more detailed information on retrieving virtual machines, refer to the following documentation:
1. [Get-ProvVM] https://developer-docs.citrix.com/en-us/citrix-virtual-apps-desktops-sdk/current-release/MachineCreation/Get-ProvVM.html.

**Note**
1. By setting the -Locked parameter to true, you can retrieve all locked virtual machines, irrespective of the Provisioning Scheme used to create the VM. The virtual machines undergo a lock state when adding or removing machines from the Broker Catalog.
2. Get-ProvVM cmdlet retrieves all virtual machines provisioned in a specified Provisioning Scheme when the -ProvisioningSchemeName parameter is provided.
3. Retrieves a specific virtual machine provisioned in a designated Provisioning Scheme when both -ProvisioningSchemeName and -VMName are specified.

## Common error cases
1. Failed to retrieve details of ProvVM if the provided ProvisioningSchemeName/VMName are invalid.

## Next steps
1. To provision a new Virtual Machine, please refer to the sample scripts in "GCP\ProvVM\Add ProvVM" section.
2. To remove a Provisioning Virtual Machines, please refer to the sample scripts in "GCP\ProvVM\Remove ProvVM" section.

