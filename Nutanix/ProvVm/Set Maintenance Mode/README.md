# Set Maintenance Mode

`Set-MaintenanceMode.ps1` script sets the Maintenance mode for VMs in a Provisioning Scheme

## Using the script

### Parameters

- Required Parameters:
    - `ProvisioningSchemeName`: The name of the provisioning scheme
    - `VMName`: Names of the VMs
    - `MaintenanceMode`: Value of maintenance mode to set
- Optional Parameters
    - `AdminAddress`: Address of the DDC


### Examples

- Get all VMs from a Provisioning Scheme
```powershell
.\Set-MaintenanceMode.ps1 -ProvisioningSchemeName "myProvScheme" -VmName "vm-1" -MaintenanceMode $true
```