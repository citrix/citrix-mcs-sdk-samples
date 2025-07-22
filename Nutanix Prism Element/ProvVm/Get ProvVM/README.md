# Get ProvVM

`Get-ProvVM.ps1` script gets a specific VM, or all the VMs from a Provisioning Scheme

## Using the script

### Parameters

- Required Parameters:
    - `ProvisioningSchemeName`: Name of Provisioning Scheme to add VMs to
- Optional Parameters
    - `VMName`: Name of VM to get


### Examples

- Get all VMs from a Provisioning Scheme
```powershell
.\Get-ProvVM.ps1 -ProvisioningSchemeName "myProvScheme"
```

- Get a specific VM from a Provisioning Scheme
```powershell
.\Get-ProvVM.ps1 -ProvisioningSchemeName "myProvScheme" -VMName "myVM-1"
```