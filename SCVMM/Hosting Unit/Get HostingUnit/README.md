# Get Hosting Unit
## Overview
The Get-Item command is used to list the details of a hosting unit.
Follow this link to know more about [Get-Item](https://developer-docs.citrix.com/en-us/citrix-virtual-apps-desktops-sdk/current-release/HostService/about_HypHostSnapIn.html).

## Errors that can be encountered during this operation
1. Failed to retrieve the hosting unit if the provided HostingUnitName is invalid.
2. Failed to retrieve the hosting unit if the provided HostingUnitName is already deleted.
3. Failed to retrieve the hosting unit if the hypervisor for the specified connection is currently in maintenance mode.

## Next steps
1. To edit an existing hosting unit, use scripts in Update HostingUnit.
2. To remove a hosting unit, use scripts in Remove HostingUnit.
3. To create a hosting unit inside a hosting connection, use scripts in Add HostingUnit.