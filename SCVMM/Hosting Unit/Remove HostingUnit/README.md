# Remove Hosting Unit
## Overview
The Remove-Item command is utilized to delete the specified hosting unit. Ensure that all associated catalogs linked to the given hosting unit are deleted before attempting to remove the hosting unit.
Follow this link to know more about [Remove-Item](https://developer-docs.citrix.com/en-us/citrix-virtual-apps-desktops-sdk/current-release/HostService/about_HypHostSnapIn.html).

## Errors that can be encountered during this operation
1. Failed to delete the hosting unit if the provided HostingUnitNames are invalid.
2. Failed to delete the hosting unit if the provided HostingUnitNames already deleted.
3. Failed to delete the hosting unit if there are any associated catalogs linked to it.

## Next steps
1. To create a hosting unit inside a hosting connection, use scripts in Add HostingUnit.