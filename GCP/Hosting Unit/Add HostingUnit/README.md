# Add Hosting Unit
## Overview
The New-Item command is used to generate a GCP hosting unit under a given hosting connection. It is possible to create multiple hosting units for a given hosting connection.
Follow this link to know more about [New-Item](https://developer-docs.citrix.com/en-us/citrix-virtual-apps-desktops-sdk/current-release/HostService/about_HypHostSnapIn.html).

## Errors users may encounter during this operation
* If the provided HostingUnitName already exists: "The HostingUnit object could not be created as an object with the same name already exists."
* If the GCP Project name provided is invalid: "The RootPath supplied for the HostingUnit is invalid, check that the path exists and is a valid symLink."
* If the Region provided is invalid: "The NetworkPath supplied for the HostingUnit is invalid."
* There is no error thrown if the VPC name or subnet name or both are invalid. The hosting unit will be created with the provided VPC and subnet names, but the hosting unit will not be functional.

## Next steps
1. To update an existing hosting unit, please refer to the sample scripts in "GCP\Hosting Unit\Update HostingUnit".
2. To get the details of a hosting unit, please refer to the sample scripts in "GCP\Hosting Unit\Get HostingUnit".
3. To remove a hosting unit, please refer to the sample scripts in "GCP\Hosting Unit\Remove HostingUnit".