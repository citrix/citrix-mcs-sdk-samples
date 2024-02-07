# Add Hosting Unit
## Overview
The New-Item command is employed to generate a azure hosting unit beneath a hosting connection. It is possible to create multiple hosting units for a given hosting connection.
Follow this link to know more about [New-Item](https://developer-docs.citrix.com/en-us/citrix-virtual-apps-desktops-sdk/current-release/HostService/about_HypHostSnapIn.html).

## Errors that can be encountered during this operation
1. Failed to add the hosting unit if the provided ConnectionName/HostingUnitName/AzureNetwork/AzureResourceGroup/AzureRegion/AzureSubnet are invalid. We use these values to construct the NetworkPath in the script so you would an error message for example "The NetworkPath supplied for the HostingUnit is invalid". 
2. Failed to add the hosting unit if the provided HostingUnitName already exists and the error message you would see is "The HostingUnit object could not be created as an object with the same name already exists."

## Next steps
1. To edit an existing hosting unit take the reference of sample scripts in Update HostingUnit.
2. To get the details of a hosting unit take the reference of sample scripts in Get HostingUnit.
3. To remove a hosting unit take the reference of sample scripts in Remove HostingUnit.