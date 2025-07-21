# Add Hosting Unit

This page explains the use of the Create-HostingUnit.ps1 script.

This script creates a Hosting Unit.

The Hosting Unit has an associated RootPath. The value of the RootPath will be: `XDHyp:\Connections\<connection name>\`

## Using the script

### Parameters

- Required parameters:
    - `Name`: Name of Hosting Unit to create
    - `ConnectionName`: Name of the hypervisor connection
- Optional Parameters:
    - `NetworkPath`: Path(s) to networks to use
    - `StoragePath`: Path(s) to storages to use
    - `PersonalvDiskStoragePath`: Path(s) to PersonalvDiskStorage to use

### Example
The script can be executed like the example below:
```powershell
.\Create-HostingUnit.ps1 `
    -Name myHostingUnit `
    -ConnectionName "nutanix" `
    -NetworkPath @("XDHyp:\Connections\nutanix\mynetwork.network") `
    -PersonalvDiskStoragePath @()

.\Create-HostingUnit.ps1 `
    -Name myHostingUnit `
    -ConnectionName "nutanix" `
    -NetworkPath @("XDHyp:\Connections\nutanix\mynetwork.network","XDHyp:\Connections\nutanix\mynetwork2.network") `
    -PersonalvDiskStoragePath @()
```