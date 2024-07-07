# Remove Hosting Unit
## Overview
The Remove-Item command deletes the specified hosting unit. Ensure all catalogs linked to the given hosting unit are deleted before attempting the operation.
Follow this link to know more about [Remove-Item](https://developer-docs.citrix.com/en-us/citrix-virtual-apps-desktops-sdk/current-release/HostService/about_HypHostSnapIn.html).

## Errors users may encounter during this operation
* If one or more provided HostingUnitNames are invalid, error message would look like "Cannot find path 'XDHyp:\HostingUnits\Name' because it does not exist."

## Next steps
1. To create a hosting unit inside a hosting connection, please refer to the sample scripts in "GCP\Hosting Unit\Add HostingUnit".