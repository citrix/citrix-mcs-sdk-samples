# MachineProfile
## Overview
Using MCS Provisioning, provisioned VMs can inherit a configuration from a SCVMM/HyperV VM. When using New-ProvScheme or Set-ProvScheme, you will specify a new parameter: `MachineProfile`

## Leading Practices
We suggest using MachineProfile for your MCS catalogs. This will allow you to take advantage of more MCS features, as many new features require MachineProfile. 

## How to use MachineProfile
To configure Machine through PowerShell, use the `MachineProfile` parameter available with the New-ProvScheme operation. The MachineProfile parameter is a string containing a Citrix inventory item path. Currently, only one inventory type is supported for the MachineProfile source:    
1. **VM**: The MachineProfile points to a VM that exists in SCVMM/HyperV. For example:
```powershell
$machineProfile = "XDHyp:\HostingUnits\demo-hostingunit\demo-machineprofile-vm.vm"
```
### Create Provisioning scheme
When using New-ProvScheme, specify the `MachineProfile` parameter:
```powershell
New-ProvScheme -ProvisioningSchemeName $provisioningSchemeName `
    -CleanOnBoot:$isCleanOnBoot `
    -HostingUnitName $hostingUnitName `
    -IdentityPoolName $identityPoolName `
    -InitialBatchSizeHint $numberOfVms `
    -MasterImageVm $masterImage `
    -MachineProfile $machineProfile `
    -NetworkMapping $networkMapping `
```

### Update Provisioning scheme with machine profile
You can also change the MachineProfile configuration on an existing catalog using the Set-ProvScheme command. 
```powershell
Set-ProvScheme -ProvisioningSchemeName $provisioningSchemeName -MachineProfile $machineProfile
```
**Note**: The updated machine profile will be applicable to new machines post operation , not to the existing machines. 

### Important notes:
- If you add machine hardware property parameters in the New-ProvScheme and Set-ProvScheme commands, then the values provided in the parameters will overwrite the values in the machine profile. These parameter include:
    - Network Mapping
    - VMCpuCount
    - VMMemoryMb

## Common error cases

