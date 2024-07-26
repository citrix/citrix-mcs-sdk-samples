# Remove ProvVM

`Remove-ProvVM.ps1` removes existing VMs from an existing Provisioning Scheme.

## Using the script

### Parameters

- Required Parameters:
    - `ProvisioningSchemeName`: The name of the provisioning scheme
    - `VMName`: Names of the VMs to get
    - `Domain`: Domain of AD accounts
    - `UserName`: Username of AD accounts
- Optional Parameters
    - `PurgeDBOnly`: Remove VMs from database without deleting from hypervisor
    - `ForgetVM`: Disassicate VMs from Citrix without deleting from hypervisor
    - `AdminAddress`: DDC Address

### Examples

- Create 1 new VM
```powershell
.\Remove-ProvVM.ps1 `
    -ProvisioningSchemeName "myProvScheme" `
    -VMName @("myVM1","myVM2")
    -Domain "myDomain"
    -UserName "myUser"
```