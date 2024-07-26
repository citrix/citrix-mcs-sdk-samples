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

### Example
The script can be executed like the example below. The example includes only the required parameters, add any extra parameters that may be relevant to your environment.
```powershell
.\Create-HostingConnection.ps1 `
        -ConnectionName "myDemoConnection" `
        -HypervisorAddress "0.0.0.0" `
        -SecurePass Read-Host "Enter the password" -AsSecureString `
        -UserName "myUserName" `
        -ZoneUid "00000000-0000-0000-0000-000000000000"
```