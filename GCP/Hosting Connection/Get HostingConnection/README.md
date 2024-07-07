# Get Hosting Connection
## Overview
The Get-BrokerHypervisorConnection cmdlet retrieves hypervisor connections that match the provided criteria. If no parameters are specified, this cmdlet enumerates all hypervisor connections.
The Get-Item cmdlet retrieves the host details of a hosting connection.
Follow these links to know more about commands [Get-BrokerHypervisorConnection](https://developer-docs.citrix.com/en-us/citrix-virtual-apps-desktops-sdk/current-release/Broker/Get-BrokerHypervisorConnection.html) and [Get-Item](https://developer-docs.citrix.com/en-us/citrix-virtual-apps-desktops-sdk/current-release/HostService/about_HypHostSnapIn.html).  

## Errors users may encounter during this operation:
Failed to retrieve the hosting connection if the provided ConnectionName is invalid. Example error message - "Cannot find path 'XDHyp:\Connections\Name' because it does not exist."

## Next steps
1. To edit a hosting connection, please refer to the sample scripts in "GCP\Hosting Connections\Update HostingConnection". 
2. To remove a hosting connection, please refer to the sample scripts in "GCP\Hosting Connections\Remove HostingConnection".
3. To create a new hosting connection, please refer to the sample scripts in "GCP\Hosting Connections\Add HostingConnection".