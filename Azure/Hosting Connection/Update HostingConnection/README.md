# Edit Hosting Connection
## Overview
This script allows you to modify various attributes of a hosting connection, including the name, custom properties, maintenance mode, application password, metadata, and more. 
To know more about the commands used to edit hosting connection refer [Set-HypHypervisorConnectionMetadata](https://developer-docs.citrix.com/en-us/citrix-virtual-apps-desktops-sdk/2206/Host/Set-HypHypervisorConnectionMetadata.html) and [Set-Item and Rename-Item](https://developer-docs.citrix.com/en-us/citrix-virtual-apps-desktops-sdk/current-release/HostService/about_HypHostSnapIn.html).

**Note**
You have the ability to configure the maximum number of concurrent Azure provisioning operations by adjusting the property named MaximumConcurrentProvisioningOperations. The default value for MaximumConcurrentProvisioningOperations is set to 500.
To know more about Azure throttling settings refer this [link](https://docs.citrix.com/en-us/citrix-daas/install-configure/connections/connection-azure-resource-manager.html#configure-azure-throttling-settings).

```powershell
$CustomProperties = '<CustomProperties xmlns="http://schemas.citrix.com/2014/xd/machinecreation" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">' `
+ '<Property xsi:type="StringProperty" Name="SubscriptionId" Value="' + $SubscriptionId + '" />'`
+ '<Property xsi:type="StringProperty" Name="ManagementEndpoint" Value="https://management.azure.com/" />'`
+ '<Property xsi:type="StringProperty" Name="AuthenticationAuthority" Value="https://login.microsoftonline.com/" />'`
+ '<Property xsi:type="StringProperty" Name="StorageSuffix" Value="core.windows.net" />'`
+ '<Property xsi:type="StringProperty" Name="TenantId" Value="' + $TenantId + '" />'`
+ '<Property xsi:type="StringProperty" Name="MaximumConcurrentProvisioningOperations" Value="600" />'`
+ '</CustomProperties>'

$cred = Get-Credential
Set-Item -LiteralPath $connectionPath -CustomProperties $CustomProperties -UserName $cred.username -Password $cred.password
```
Additionally, you can adjust the ProxyHypervisorTrafficThroughConnector property via custom properties, similar to MaximumConcurrentProvisioningOperations. The possible values for ProxyHypervisorTrafficThroughConnector are either True or False(This script configures the property via custom properties, setting it to True. You have the flexibility to modify it according to your preferences.). 
For further details about ProxyHypervisorTrafficThroughConnector refer this [link](https://docs.citrix.com/en-us/citrix-daas/install-configure/connections/connection-azure-resource-manager.html#create-a-secure-environment-for-azure-managed-traffic).

## Errors that can be encountered during this operation
1. Failed to edit the hosting connection if the provided ConnectionName is invalid. Error message you would see is "Provided ConnectionName is not valid. Please give the right ConnectionName".
2. In the case of invalid credentials, attempting to edit custom properties on the hosting connection will fail, even if no error message is displayed after executing the script. Consequently, there will be no observed updates to the custom properties on the hosting connection. 

## Next steps
1. To retrieve information about a created hosting connection take the reference of sample scripts in Get HostingConnection.
2. To remove a hosting connection take the reference of sample scripts in Remove HostingConnection.
3. To create a new hosting connection take the reference of sample scripts in Add HostingConnection.