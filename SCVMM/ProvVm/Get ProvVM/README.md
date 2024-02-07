# Get Provisioned VM
## Overview
The Get-ProvVm enables you to obtain a list of virtual machines created through Citrix Machine Creation Services.
To know more details about Get-ProvVM refer - https://developer-docs.citrix.com/en-us/citrix-virtual-apps-desktops-sdk/current-release/MachineCreation/Get-ProvVM.html.

**Note**
1. By setting the -Locked parameter to true, you can retrieve all locked virtual machines, irrespective of the Provisioning Scheme used to create the VM.
2. Retrieves all virtual machines provisioned in a specified Provisioning Scheme when the -ProvisioningSchemeName parameter is provided.
3. Retrieves a specific virtual machine provisioned in a designated Provisioning Scheme when both -ProvisioningSchemeName and -VMName are specified.

## Here are some common errors encountered during Get-ProvVM
1. Failed to retrieve details of ProvVM if the provided ProvisioningSchemeName/VMName are invalid.
2. Failed to retrieve details of ProvVM if the provided ProvisioningSchemeName/VMName are already deleted.

## Next steps
1. To remove a Provisioning virtual machine, use the scripts in Remove ProvVM.
2. To provision a new virtual machine, use the scripts in Add ProvVM.