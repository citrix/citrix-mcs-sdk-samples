# Remove Hosting Connection

This page explains the use of the Remove-HostingConnection.ps1 script.

This script removes a Hosting Connection *AND ALL* Hosting Units associated with the connection. See the [Hosting Unit](../../Hosting%20Unit/) scripts to delete a specific Hosting Unit.

## Using the script

### Parameters

- Required parameters:
    - `ConnectionName`: Name of hosting connection to remove

### Example
The script can be executed like the example below.

```powershell
.\Remove-HostingConnection.ps1 -ConnectionName "myDemoConnection"
```