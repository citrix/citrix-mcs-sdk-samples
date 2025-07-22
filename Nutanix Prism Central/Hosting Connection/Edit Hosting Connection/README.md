# Edit Hosting Connection

This page explains the use of the Edit-HostingConnection.ps1 script.

This script edits an existing Hosting Connection. See the [Hosting Unit](../../Hosting%20Unit/) scripts to create or edit resources once a connection is created.

Provide any of the optional parameters that need to be changed.

## Using the script

### Parameters

- Required parameters:
    - `ConnectionName`: Name of hosting connection to make changes to
- Optional Parameters:
    - `NewUserName`:       New username for account on the hypervisor
    - `NewName`:           New name to be assigned to the hosting connection
    - `NewPassword`:       Parameter that indiocates password chnage for account on the hypervisor
    - `NewSslThumbprint`:  SecureString containing new password for account on the hypervisor

### Example
The script can be executed like the example below. The example includes all the parameters. Remove any parameters that do not need to be changed.
```powershell
.\Edit-HostingConnection.ps1 `
    -ConnectionName "myDemoConnection" `
    -NewUserName "newDemoUser" `
    -NewName "myDemoConnectionV2" `
    -NewSslThumbprint "<ssl-thumbprint>" `
    -NewPassword
```

The script will prompt for Credentials for the connection, and update the SSL certificate thumbprint assoicated with the hosting connetion.
```powershell
.\Edit-HostingConnection.ps1 `
    -ConnectionName "myDemoConnection" `
    -NewSslThumbprint "<ssl-thumbprint>"
```

The script will prompt for Credentials and update the credentials assoicated with the hosting connetion.
```powershell
.\Edit-HostingConnection.ps1 `
    -ConnectionName "myDemoConnection" `
    -NewPassword
```
