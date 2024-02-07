# Add Hosting Connection
## Overview
The creation of a hosting connection is accomplished using cmdlets New-Item and New-BrokerHypervisorConnection.
Follow links to know more about [New-Item](https://developer-docs.citrix.com/en-us/citrix-virtual-apps-desktops-sdk/current-release/HostService/about_HypHostSnapIn.html) and [New-BrokerHypervisorConnection](https://developer-docs.citrix.com/en-us/citrix-virtual-apps-desktops-sdk/current-release/Broker/New-BrokerHypervisorConnection).

**Note**
1. Ensure that the UserName is domain user with administrator privileges
2. HypervisorAddress represents the server where the SCVMM hosts can be managed

## Errors that may encounter during this operation:
1. Failed to create hosting connection the specified zone name could not be found.
2. Failed to create hosting connection becuase the name specified for the connection already exists.
3. Failed to create hosting connection because the user lacks administrative rights to perform this operation.

## Next steps
1. To retrieve information about a created hosting connection, use scripts in Get HostingConnection.
2. To edit a hosting connection, use scripts in Update HostingConnection. 
3. To create a hosting unit inside a hosting connection, use scripts in Add HostingUnit.
4. To remove a hosting connection, use scripts in Remove HostingConnection.
5. To create a new hosting connection, use scripts in Add HostingConnection.