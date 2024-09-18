# Add Hosting Connection
## Overview
The creation of a hosting connection is accomplished using cmdlets New-Item and New-BrokerHypervisorConnection.
Follow links to know more about [New-Item](https://developer-docs.citrix.com/en-us/citrix-virtual-apps-desktops-sdk/current-release/HostService/about_HypHostSnapIn.html) and [New-BrokerHypervisorConnection](https://developer-docs.citrix.com/en-us/citrix-virtual-apps-desktops-sdk/current-release/Broker/New-BrokerHypervisorConnection).

**Note**
Install Azure modules before using any of the scripts. Refer this link to [install Azure modules on Windows](https://learn.microsoft.com/en-us/powershell/azure/install-azps-windows?view=azps-11.2.0&tabs=powershell&pivots=windows-psgallery)

- To create Hosting Connections using Service Principal:
    1. Ensure that a service principal is already created, and store both the application ID and secret value. To create a service principal using PowerShell, refer ./Create-ServicePrincipal.ps1 script in this folder.
    2. Use this link to create a new client scret and retrieve the client secret value from Azure [Get Application Secret](https://docs.citrix.com/en-us/citrix-daas/install-configure/connections/connection-azure-resource-manager.html#get-the-application-secret-in-azure). Client secret values cannot be viewed, except for immediately after creation. Be sure to save the secret when created before leaving the page. Remember we use this client secret value not secretId during the creation of hosting connection.
    3. Before you begin the process of creating a hosting connection, make sure you have the necessary permissions. You can acquire these permissions by selecting predefined roles through the [Privileged administrator roles](https://learn.microsoft.com/en-us/azure/role-based-access-control/role-assignments-portal?tabs=delegate-condition) link or by adding custom roles using the [Create Custom Roles](https://learn.microsoft.com/en-us/azure/role-based-access-control/custom-roles-portal) link.

- To create Hosting Connections using Managed Identities:
    1. You don't need to create service principal if you are using Create-ManagedIdentityHostingConnection.ps1 script
    2. You need to install Citrix Cloud Connector application in an Azure VM and enable Azure Managed Identity on it
    3. Provide required permissions to Azure Managed Identity
```
"Microsoft.Network/virtualNetworks/read",
"Microsoft.Compute/virtualMachines/read",
"Microsoft.Compute/disks/read"
```
For detailed information on the Azure permissions needed for various operations, please refer the following link. [Required Azure Permissions](https://docs.citrix.com/en-us/citrix-daas/install-configure/connections/connection-azure-resource-manager.html#minimum-permissions)

## Errors that may encounter during this operation:
1. In case of an invalid zoneName provided, an error message will be displayed stating, "Could not find the zone (zoneName). Verify the zoneName exists or try the default Primary."
2. If a hosting connection already exists, an error will occur with the message, "The HypervisorConnection object could not be created as an object with the same name already exists."

## Next steps
1. To retrieve information about a created hosting connection take the reference of sample scripts in Get HostingConnection.
2. To edit a hosting connection take the reference of sample scripts in Update HostingConnection. 
3. To create a hosting unit inside a hosting connection take the reference of sample scripts in Add HostingUnit.
4. To remove a hosting connection take the reference of sample scripts in Remove HostingConnection.
5. To create a new hosting connection take the reference of sample scripts in Add HostingConnection.