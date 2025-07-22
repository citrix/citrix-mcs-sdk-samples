# Remove Provisioning Scheme

This page explains the use of the Remove-ProvisioningScheme.ps1 script.

This script removes an existing Provisioning Scheme.

## Using the script

### Parameters

- Required parameters:
    - `ProvisioningSchemeName`: Name of the provisioning scheme to remove

### Example
The script can be executed like the example below:
```powershell
.\Remove-ProvisioningScheme.ps1 -ProvisioningSchemeName "myProvScheme"
```