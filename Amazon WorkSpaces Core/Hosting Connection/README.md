# Amazon WorkSpaces Core Hosting Connection

## Overview
Hosting connection is the connection between Citrix and the Amazon WorkSpaces Core environment in a specific region where to get, create, modify, or remove resources (Instances, AMI, etc). Using MCS Provisioning, you can provision machines into a specific Region in Amazon Workspaces Core (WSC) environments. 

Each Region is a separate geographic area and is designed to be isolated from the other Regions. This achieves the greatest possible fault tolerance and stability. <br>
To learn more about AWS Region, refer to the [AWS Documentation](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/using-regions-availability-zones.html). 

## How to use Hosting Connection

### Creating Hosting Connection
To create a hosting connection, you first need to create a connection to a Citrix Hypervisor host. This is a persistent connection and is available only to this PowerShell runspace. To get a ZoneUid, the UserName (API Key) and SecurePassword (Secret Key), refer to the WSC Hypervisor [Readme](../README.md)
```powershell
$connectionName = "demo-hostingconnection"
$cloudRegion = "us-east-1"
$apiKey = "aaaaaaaaaaaaaaaaaaaa"
$zoneUid = "00000000-0000-0000-0000-000000000000"

$securePassword = Read-Host 'Please enter your secret key' -AsSecureString
$connectionPath = "XDHyp:\Connections\" + $connectionName
$customProperties = ''

# Create Connection
$connection = New-Item -Path $connectionPath `
-ConnectionType "Custom" -PluginId "AmazonWorkSpacesCoreMachineManagerFactory" `
-HypervisorAddress "https://workspaces-instances.$($cloudRegion).api.aws" `
-Persist -Scope @()`
-UserName $apiKey -SecurePassword $securePassword `
-ZoneUid $zoneUid `
-CustomProperties $customProperties
  
```
You could also create a Hosting Connection with role based authentication. To do this, pass in `"role_based_auth"` as the value.
```powershell
$connectionName = "demo-hostingconnection"
$cloudRegion = "us-east-1"
$apiKey = "role_based_auth"
$zoneUid = "00000000-0000-0000-0000-000000000000"

$securePassword = ConvertTo-SecureString -String $apiKey -AsPlainText -Force
$connectionPath = "XDHyp:\Connections\" + $connectionName
$customProperties = ''

# Create Connection
$connection = New-Item -Path $connectionPath `
-ConnectionType "Custom" -PluginId "AmazonWorkSpacesCoreMachineManagerFactory" `
-HypervisorAddress "https://workspaces-instances.$($cloudRegion).api.aws" `
-Persist -Scope @()`
-UserName $apiKey -SecurePassword $securePassword `
-ZoneUid $zoneUid `
-CustomProperties $customProperties
  
```
Then add the host connection to the Broker Service. This will now be viewable in Studio
```powershell
New-BrokerHypervisorConnection -HypHypervisorConnectionUid $connection.HypervisorConnectionUid
```

[More info about New-BrokerHypervisorConnection](https://developer-docs.citrix.com/en-us/citrix-virtual-apps-desktops-sdk/current-release/broker/new-brokerhypervisorconnection)<br>
[More info about role based authentication](https://docs.citrix.com/en-us/citrix-daas/install-configure/connections/connection-aws#minimal-iam-permissions-policy)

### Getting Hosting Connection Properties
To get information about a specific hosting connection, you have two options, `Get-Item` and `Get-BrokerHypervisorConnection`. <br>
There are minor differences: 
- `Get-Item` returns 
    - `CustomProperties`
    - `UserName` (This is the Public API Key)
    - `MaintenanceMode`
- `Get-BrokerHypervisorConnection` returns 
    - `ZoneHealthy`
    - `Capabilities` (This is different from `Capabilities` from `Get-Item`) 

**Note**: There are different Properties that have different names, for each command, but are actually the same. Ex: `Get-Item`'s `Capabilities` and `Get-BrokerHypervisorConnection`'s `HypervisorCapabilities`. `Get-Item`'s `HypervisorConnectionUid` and `Get-BrokerHypervisorConnection`'s `HypHypervisorConnectionUid`. 

To use `Get-BrokerHypervisorConnection`, you just need the connection name
```powershell
Get-BrokerHypervisorConnection -Name "demo-hostingconnection"
```
You could use the Connection's UID and other properties. [More info about Get-BrokerHypervisorConnection](https://developer-docs.citrix.com/en-us/citrix-virtual-apps-desktops-sdk/current-release/broker/get-brokerhypervisorconnection)
```powershell
Get-BrokerHypervisorConnection -Uid "00000000-0000-0000-0000-000000000000"
```
To use `Get-Item`, you need to give the full path
```powershell
$connectionPath = "XDHyp:\Connections\demo-hostingconnection"
Get-Item -Path "XDHyp:\Connections\demo-hostingconnection"
```

### Updating Hosting Connection Properties
You can change the following properties for Hosting Connection: name, maintenance mode, and API and Secret Key

To turn on/off the maintenance mode for a hosting connection
```powershell
# To turn on: set it to $true. To turn off: set it to $false
$maintenanceMode = $true
$connectionPath = "XDHyp:\Connections\demo-hostingconnection"

Set-Item -LiteralPath $connectionPath -MaintenanceMode $maintenanceMode
```
To change the API Key and Secret Key
```powershell
# Note you can also use "role_based_auth"
$apiKey = "aaaaaaaaaaaaaaaaaaaa"

$securePassword = Read-Host 'Please enter your secret key' -AsSecureString
$connectionPath = "XDHyp:\Connections\" + $connectionName

Set-Item -LiteralPath $connectionPath -UserName $apiKey -SecurePassword $securePassword
```
To rename a hosting connection you need the full path of the hosting connection
```powershell
$connectionName = "demo-hostingconnection"
$connectionPath = "XDHyp:\Connections\" + $connectionName
$renameConnection = "demo-renameconnection"

Rename-Item -NewName $renameConnection -Path $connectionPath
```
**Note**: after renaming the hosting connection, the hosting connection path will change. In this case, "XDHyp:\Connections\demo-renameconnection"

### Deleting Hosting Connection
Deleting a connection can result in the deletion of large numbers of machines and loss of data. Ensure that user data on affected machines is backed up or no longer required.

Before deleting a connection, ensure that:
* All users are logged off from the machines stored on the connection.
* No disconnected user sessions are running.
* Maintenance mode is turned on for pooled and dedicated machines.
* All machines in Machine Catalogs used by the connection are powered off.

Before deleting a hosting connection, first delete the hosting unit in that connection
```powershell
$connectionName = "demo-hostingconnection"

# Get the hosting units of the Hosting Connection
$hostingUnits = Get-ChildItem "XDHyp:\HostingUnits\" | Where-Object { $_.HypervisorConnection.HypervisorConnectionName -eq $connectionName }

# Remove the hosting units of the Hosting Connection
$hostingUnits | ForEach-Object { Remove-Item -LiteralPath ("XDHyp:\HostingUnits\"+ $_.HostingUnitName) -Force }
```
Then remove the broker hypervisor connection. [More info about Remove-BrokerHypervisorConnection](https://developer-docs.citrix.com/en-us/citrix-virtual-apps-desktops-sdk/current-release/broker/remove-brokerhypervisorconnection)
```powershell
Remove-BrokerHypervisorConnection -Name $connectionName
```
Finally, remove the hosting connection
```powershell
Remove-Item -LiteralPath ("XDHyp:\Connections\" + $connectionName)
```

## Misc
[How to create and manage hosting connection on Studio](https://docs.citrix.com/en-us/citrix-daas/install-configure/connections)