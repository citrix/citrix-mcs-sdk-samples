# Edit Hosting Connection
## Overview
This script allows you to modify various attributes of a hosting connection, including the name, custom properties, maintenance mode, application password, metadata, and more. 
To know more about the commands used to edit hosting connection refer [Set-HypHypervisorConnectionMetadata](https://developer-docs.citrix.com/en-us/citrix-virtual-apps-desktops-sdk/2206/Host/Set-HypHypervisorConnectionMetadata.html) and [Set-Item and Rename-Item](https://developer-docs.citrix.com/en-us/citrix-virtual-apps-desktops-sdk/current-release/HostService/about_HypHostSnapIn.html).

## Errors that can be encountered during this operation
1. Failed to edit the hosting connection if the provided ConnectionName is invalid.
2. Failed to edit the custom properties on hosting connection if the provided credentials are not valid.
3. Failed to edit the application password on hosting connection if the provided UserName/ConnectionName are not valid.

## Next steps
1. To retrieve information about a created hosting connection, use scripts in Get HostingConnection.
2. To remove a hosting connection, use scripts in Remove HostingConnection.
3. To create a new hosting connection, use scripts in Add HostingConnection.