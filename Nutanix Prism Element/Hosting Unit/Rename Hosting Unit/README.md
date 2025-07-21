# Remove Network

This page explains the use of the Rename-HostingUnit.ps1 script.

This script renames a Hosting Unit.

## Using the script

### Parameters

- Required parameters:
    - `Name`: Name of Hosting Unit to rename
    - `NewName`: New name for the Hosting Unit

### Example
The script can be executed like the example below:
```powershell
.\Rename-HostingUnit.ps1 -Name myHostingUnit -NewName updatedName
```