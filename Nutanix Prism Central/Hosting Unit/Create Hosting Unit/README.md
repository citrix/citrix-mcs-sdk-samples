# Add Hosting Unit

This page explains the use of the Create-HostingUnit.ps1 script.

This script creates a Hosting Unit.

The Hosting Unit has an associated RootPath. The value of the RootPath will be: `XDHyp:\Connections\<connection name>\`

Nutanix Prism Central hypervisor does not require any resource speocifcations in the Hosting Unit.  Culster and network resopurces are specified as part of a MCS based Catalog.

## Using the script

### Parameters

- Required parameters:
    - `Name`: Name of Hosting Unit to create
    - `ConnectionName`: Name of the hypervisor connection

### Example
The script can be executed like the example below:
```powershell
.\Create-HostingUnit.ps1 `
    -Name myHostingUnit `
    -ConnectionName "nutanix"
```