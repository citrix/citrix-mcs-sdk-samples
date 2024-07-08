# Edit Hosting Unit
## Overview
The **Set-Item** updates the network path of a hosting unit, while **Rename-Item** changes the name of the specified hosting unit.
Follow this link to know more about [Set-Item](https://developer-docs.citrix.com/en-us/citrix-virtual-apps-desktops-sdk/current-release/HostService/about_HypHostSnapIn.html).

## Errors users may encounter during this operation
* If the provided Region/GcpProjectName are invalid: "The NetworkPath supplied for the HostingUnit is invalid". 
* If the provided HostingUnitName is invalid: "Cannot find path 'XDHyp:\HostingUnits\Name' because it does not exist."

## Next steps
1. To get the details of a hosting unit, please refer to the sample scripts in "GCP\Hosting Unit\Get HostingUnit".
2. To remove a hosting unit, please refer to the sample scripts in "GCP\Hosting Unit\Remove HostingUnit".
3. To create a hosting unit inside a hosting connection, please refer to the sample scripts in "GCP\Hosting Unit\Add HostingUnit".