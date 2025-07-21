# Get Hosting Connection

This page explains the use of the Get-HostingConnection.ps1 script.

This script retrieves the details of an existing Hosting Connection. Returns both the Connection item, and the BrokerHypervisorConnection item.

## Using the script

### Parameters

- Required parameters:
    - `ConnectionName`: Name of hosting connection to retrieve

### Example
The script can be executed like the example below.

```powershell
.\Get-HostingConnection.ps1 -ConnectionName "myDemoConnection"
```