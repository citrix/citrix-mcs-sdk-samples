# Remove Hosting Connection
## Overview
Remove-BrokerHypervisorConnection and Remove-Item are used together to remove an existing hosting connection. 
To know more details about these commands refer - [Remove-BrokerHypervisorConnection](https://developer-docs.citrix.com/en-us/citrix-virtual-apps-desktops-sdk/current-release/Broker/Remove-BrokerHypervisorConnection.html) and [Remove-Item](https://developer-docs.citrix.com/en-us/citrix-virtual-apps-desktops-sdk/current-release/HostService/about_HypHostSnapIn.html).  

**Note**
1. Install Azure modules before using Remove-ServicePrincipal.ps1. Refer this link to [install Azure modules on Windows](https://learn.microsoft.com/en-us/powershell/azure/install-azps-windows?view=azps-11.2.0&tabs=powershell&pivots=windows-psgallery). 
2. Removing a hypervisor connection is not possible if it is currently in use by a catalog. You can manually delete the associated catalogs, or utilize this script to delete all the linked catalogs and hosting units associated with the specified hosting connection, excluding the service principal. You may choose to either reuse the existing service principal for creating a hosting connection or manually delete it.
3. When establishing a hosting connection in the studio using the "Create new service principal" option, it's important to note that the service principal generated during this process is not automatically removed when deleting the hosting connection. Manual deletion of the service principal is required in such cases. You can remove the service principal created referring the script Remove-ServicePrincipal.ps1.

## Errors that can be encountered during this operation
Failed to remove the hosting connection if the provided ConnectionName is invalid. Error message example "Cannot find path 'XDHyp:\Connections\Name' because it does not exist."

## Next steps
1. To create a new hosting connection take the reference of sample scripts in Add HostingConnection.