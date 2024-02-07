# Edit Hosting Unit
## Overview
The Set-Item command is utilized for updating the network path of a hosting unit, while Rename-Item is employed to change the name of the specified hosting unit.
Follow this link to know more about [Set-Item](https://developer-docs.citrix.com/en-us/citrix-virtual-apps-desktops-sdk/current-release/HostService/about_HypHostSnapIn.html).

## Errors that can be encountered during this operation
1. Failed to edit the hosting unit if the provided AzureNetwork/AzureResourceGroup/AzureRegion/NetworkNames are invalid. We use these values to construct the NetworkPath in the script so you would an error message for example "The NetworkPath supplied for the HostingUnit is invalid". 
2. Failed to edit the hosting unit if the provided HostingUnitName is invalid. Error message example "Cannot find path 'XDHyp:\HostingUnits\Name' because it does not exist."

## Next steps
1. To get the details of a hosting unit take the reference of sample scripts in Get HostingUnit.
2. To remove a hosting unit take the reference of sample scripts in Remove HostingUnit.
3. To create a hosting unit inside a hosting connection take the reference of sample scripts in Add HostingUnit.