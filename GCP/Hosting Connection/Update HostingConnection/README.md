# Edit Hosting Connection
## Overview
This script allows you to modify various attributes of a hosting connection, including the name, custom properties, maintenance mode, private key, metadata, and more. 
To know more about the commands used to edit hosting connection refer [Set-HypHypervisorConnectionMetadata](https://developer-docs.citrix.com/en-us/citrix-virtual-apps-desktops-sdk/2206/Host/Set-HypHypervisorConnectionMetadata.html) and [Set-Item and Rename-Item](https://developer-docs.citrix.com/en-us/citrix-virtual-apps-desktops-sdk/current-release/HostService/about_HypHostSnapIn.html).

**Note**
You can adjust following custom properties using this script -
1. ProxyHypervisorTrafficThroughConnector - The possible values for ProxyHypervisorTrafficThroughConnector are either True or False. The default value while creating a hosting connection is false.
2. UsePrivateWorkerPool - The possible values for UsePrivateWorkerPool are either True or False. You can configure a [secure environment for GCP managed traffic](https://docs.citrix.com/en-us/citrix-daas/install-configure/connections/connection-gcp#create-a-secure-environment-for-gcp-managed-traffic) using both these properties. The default value while creating a hosting connection is false.
3. AllGcpDiskTypesProperty - The possible values for AllGcpDiskTypesProperty are either True or False. This value controls the Disk Types displayed in Studio while creating a catalog. If set to false, it filters out local disk types other than in white list: pd-ssd, pd-standard, pd-balanced. When set to true, it displays all disk types for a given region. The default value while creating a hosting connection is false.

```powershell
$CustomProperties = '<CustomProperties xmlns="http://schemas.citrix.com/2014/xd/machinecreation" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">' `
+ '<Property xsi:type="StringProperty" Name="ProxyHypervisorTrafficThroughConnector" Value="' + $ProxyHypervisorTrafficThroughConnector + '" />'`
+ '<Property xsi:type="StringProperty" Name="UsePrivateWorkerPool" Value="' + $UsePrivateWorkerPool + '" />'`
+ '<Property xsi:type="StringProperty" Name="AllGcpDiskTypesProperty" Value="' + $AllGcpDiskTypesProperty + '" />'`
+ '</CustomProperties>'

Set-Item -LiteralPath $connectionPath -CustomProperties $CustomProperties -UserName $UserName -SecurePassword $SecureApplicationPassword

```

In rare circumstances, you may want to update Metadata properties of the connection using this script. These properties and their default values are below. Refer to this link to [know more about metadata properties](https://developer-docs.citrix.com/en-us/citrix-virtual-apps-desktops-sdk/1912/Broker/Get-BrokerHypervisorConnection.html#brokerhypervisorconnection-object)-
```powershell
$Metadata = @{
    "Citrix_Broker_MaxAbsoluteNewActionsPerMinute"="2000";
    "Citrix_Broker_MaxPowerActionsPercentageOfDesktops"="100";
    "Citrix_Broker_MaxAbsolutePvDPowerActions"="50";
    "Citrix_Broker_MaxAbsoluteActiveActions"="500";
    "Citrix_Broker_MaxPvdPowerActionsPercentageOfDesktops"="25";
    "Citrix_Broker_ExtraSpinUpTime"="240"
    }
```

## Errors users may encounter during this operation
1. Failed to edit the hosting connection if the provided ConnectionName is invalid. Error message you would see is "Provided ConnectionName is not valid. Please provide the correct ConnectionName".
2. In the case of invalid credentials, attempting to edit custom properties on the hosting connection will fail with error "The supplied credentials for the connection are not valid".

## Next steps
1. To retrieve information about a hosting connection, please refer to the scripts in "GCP\Hosting Connections\Get HostingConnection".
2. To remove a hosting connection, please refer to the sample scripts in "GCP\Hosting Connections\Remove HostingConnection".
3. To create a new hosting connection, please refer to the sample scripts in "GCP\Hosting Connections\Add HostingConnection".