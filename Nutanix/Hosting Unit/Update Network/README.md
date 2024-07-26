# Remove Network

This page explains the use of the Update-Network.ps1 script.

This script replaces the list of networks for an existing Hosting Unit with an updated list.

## Using the script

### Parameters

- Required parameters:
    - `Name`: Name of Hosting Unit to rename
    - `NetworkPath`: List of updated NetworkPath(s) to assign to the Hosting Unit

### Example
The script can be executed like the example below:
```powershell
.\Update-Network.ps1 -Name myHostingUnit -NetworkPath @("XDHyp:\Connections\nutanix\mynetwork.network") 
```