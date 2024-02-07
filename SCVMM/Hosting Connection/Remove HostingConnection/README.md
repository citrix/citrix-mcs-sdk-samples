# Remove Hosting Connection
## Overview
Remove-BrokerHypervisorConnection and Remove-Item removes a hypervisor connection from the system. 
To know more details about these commands refer - [Remove-BrokerHypervisorConnection](https://developer-docs.citrix.com/en-us/citrix-virtual-apps-desktops-sdk/current-release/Broker/Remove-BrokerHypervisorConnection.html) and [Get-Item](https://developer-docs.citrix.com/en-us/citrix-virtual-apps-desktops-sdk/current-release/HostService/about_HypHostSnapIn.html).  

**Note**
 1. Removing a hypervisor connection is not possible if it is currently in use by a catalog. You can manually delete the associated catalogs, or utilize this script to delete all the linked catalogs and hosting units associated with the specified hosting connection, excluding the service principal. You may choose to either reuse the existing service principal for creating a hosting connection or manually delete it.
 2. You can also remove the service principal created using the script Remove-ServicePrincipal.ps1.

## Errors that can be encountered during this operation
1. Failed to remove the hosting connection if the provided ConnectionName is invalid.
2. Failed to remove the hosting connection if the provided ConnectionName is already deleted.
 
## Next steps
1. To create a new hosting connection, use scripts in Add HostingConnection.