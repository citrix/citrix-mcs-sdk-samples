# Add Hosting Unit
## Overview
The New-Item command is employed to generate a scvmm hosting unit beneath a hosting connection. It is possible to create multiple hosting units for a given hosting connection.
Follow this link to know more about [New-Item](https://developer-docs.citrix.com/en-us/citrix-virtual-apps-desktops-sdk/current-release/HostService/about_HypHostSnapIn.html).

## Errors that can be encountered during this operation
1. Failed to add the hosting unit if the provided ConnectionName/HostingUnitName/HostGroup/HostName/NetworkName/StorageName are invalid.
2. Failed to add the hosting unit if the provided HostingUnitName already exists.

## Next steps
1. To edit an existing hosting unit, use scripts in Update HostingUnit.
2. To get the details of a hosting unit, use scripts in Get HostingUnit.
3. To remove a hosting unit, use scripts in Remove HostingUnit.