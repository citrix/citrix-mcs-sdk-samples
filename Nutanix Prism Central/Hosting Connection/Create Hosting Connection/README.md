# Add Hosting Connection

This page explains the use of the Create-HostingConnection.ps1 script.

This script creates a Hosting Connection to the hypervisor. See the [Hosting Unit](../../Hosting%20Unit/) scripts to create or edit resources once a connection is created.

## Using the script

### Parameters

- Required parameters:
    - `ConnectionName`: Name of the connection
    - `UserName`: Username of the account on hypervisor
    - `ZoneUid`: UID of the zone where the hosting connection will be created
    - `HypervisorAddress`: The IP address of the hypervisor
- Optional Parameters:
    - `ConnectionType`: Type of the hosting connection ("Custom" by default for Nutanix)
    - `Persist`: Boolean value that sets if the connection is persistent
    - `Scope`: Administration scopes for connection
    - `PluginId`: Name of the plugin factory (default value "AcropolisFactory")

### Example
The script can be executed like the example below. The example includes only the required parameters, add any extra parameters that may be relevant to your environment.
```powershell
.\Create-HostingConnection.ps1 `
        -ConnectionName "myDemoConnection" `
        -HypervisorAddress "1.2.3.4" `
        -UserName "myUserName" `
        -ZoneUid "11111111-2222-3333-4444-555555555555"

.\Create-HostingConnection.ps1 `
        -ConnectionName "myDemoConnection" `
        -HypervisorAddress "1.2.3.4" `
        -UserName "myUserName" `
        -ZoneUid "11111111-2222-3333-4444-555555555555" `
        -SllThumbprint 111122223333444455556667778889990000AAAA

PS C:\code\mcs-github-scripts\Nutanix Prism Central\Hosting Connection\Create Hosting Connection> .\Create-HostingConnection.ps1 -ConnectionName MyDemo -HypervisorAddress 1.2.3.4 -UserName myusername -ZoneUid 11111111-2222-3333-4444-555555555555  -SslThumbprint 111122223333444455556667778889990000AAAA
```

.\Create-HostingConnection.ps1 -ConnectionName MyDemo -HypervisorAddress 1.2.3.4 -UserName myusername -ZoneUid 11111111-2222-3333-4444-555555555555  -SslThumbprint 111122223333444455556667778889990000AAAA