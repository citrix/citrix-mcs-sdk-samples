# Remove Hosting Connection
## Overview
Remove-BrokerHypervisorConnection and Remove-Item are used together to remove an existing hosting connection and associated HostingUnits. 
To know more details about these commands refer - [Remove-BrokerHypervisorConnection](https://developer-docs.citrix.com/en-us/citrix-virtual-apps-desktops-sdk/current-release/Broker/Remove-BrokerHypervisorConnection.html) and [Remove-Item](https://developer-docs.citrix.com/en-us/citrix-virtual-apps-desktops-sdk/current-release/HostService/about_HypHostSnapIn.html).  

**Note**
1. Removing a hypervisor connection is not possible if it is currently in use by a catalog. You may want to manually delete the associated catalogs before running this script.

## Errors users may encounter during this operation
1.	Failed to remove the hosting connection if the provided ConnectionName is invalid. Example error message- "Cannot find path 'XDHyp:\Connections\Name' because it does not exist."
2.  Failed to remove the hosting connection if it is currently in use by a catalog. Example error message- "Hypervisor connection is in use."

## Next steps
1. To create a new hosting connection, please refer to the sample scripts in "GCP\Hosting Connections\Add HostingConnection".