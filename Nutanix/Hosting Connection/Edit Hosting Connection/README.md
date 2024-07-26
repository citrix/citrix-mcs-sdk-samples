# Edit Hosting Connection

This page explains the use of the Edit-HostingConnection.ps1 script.

This script edits an existing Hosting Connection. See the [Hosting Unit](../../Hosting%20Unit/) scripts to create or edit resources once a connection is created.

Provide any of the optional parameters that need to be changed.

## Using the script

### Parameters

- Required parameters:
    - `ConnectionName`: Name of hosting connection to make changes to
- Optional Parameters:
    - `NewUserName`: New username for account on the hypervisor
    - `NewSecurePassword`: SecureString containing new password for account on the hypervisor
    - `NewName`: New name that is to be assigned to the hosting connection

### Example
The script can be executed like the example below. The example includes all the parameters. Remove any parameters that do not need to be changed.
```powershell
.\Edit-HostingConnection.ps1 `
    -Name "myDemoConnection"
    -NewUserName "newDemoUser" `
    -NewName "myDemoConnectionV2" `
    -NewSecurePassword ConvertTo-SecureString "myNewUpdatedPassword" -AsPlainText -Force
```