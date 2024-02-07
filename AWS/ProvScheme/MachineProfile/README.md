# MachineProfile
## Overview
Using MCS Provisioning, provisioned VMs can inherit a configuration from an AWS EC2 Instance or an AWS Launch Template Version. When using New-ProvScheme or Set-ProvScheme, you will specify a new parameter: `MachineProfile`

To learn more about AWS Launch Template, refer to [AWS's documentation](https://docs.aws.amazon.com/autoscaling/ec2/userguide/launch-templates.html)

## Leading Practices
We suggest using MachineProfile for your MCS catalogs. This will allow you to take advantage of more MCS features, as many new features require MachineProfile. 

## How to use MachineProfile
To configure Machine through PowerShell, use the `MachineProfile` parameter available with the New-ProvScheme operation. The MachineProfile parameter is a string containing a Citrix inventory item path. Currently, only 2 inventory types are supported for the MachineProfile source:
1. **VM**: The MachineProfile points to a EC2 Instance that exists in AWS. For example:
```powershell
$machineProfile = "XDHyp:\HostingUnits\demo-hostingunit\us-east-1a.availabilityzone\demo-vm (i-00000000000000000).vm"
```

2. **Launch Template Version**: The MachineProfile points to a version of an AWS Launch Template Version. For example:
```powershell
$machineProfile = "XDHyp:\HostingUnits\demo-hostingunit\demo-lt (lt-00000000000000000).launchtemplate\lt-00000000000000000 (1).launchtemplateversion"
```

To get the following resources mentioned above using powershell:
```powershell
# To get a list of VMs' full path
Get-ChildItem -Path "XDHyp:\HostingUnits\[hosting unit name]\[availability zone name]" | Where-Object ObjectTypeName -eq "vm" | Select FullPath
# To get a list of launch templates' full path
Get-ChildItem -Path "XDHyp:\HostingUnits\[hosting unit name]" | Where-Object ObjectTypeName -eq "launchtemplate" | Select FullPath
# To get a list of launch template versions' full path
Get-ChildItem -Path "XDHyp:\HostingUnits\[hosting unit name]\[launch template name]" | Select FullPath
```

When using New-ProvScheme, specify the `MachineProfile` parameter:
```powershell
New-ProvScheme -CleanOnBoot:$isCleanOnBoot `
-ProvisioningSchemeName $provisioningSchemeName ` 
-HostingUnitName $hostingUnitName `
-IdentityPoolName $identityPoolName `
-InitialBatchSizeHint $numberOfVms `
-MasterImageVM $masterImageVm `
-NetworkMapping $networkMapping `
-CustomProperties $customProperties `
-MachineProfile $machineProfile
```

You can also change the MachineProfile configuration on an existing catalog using the Set-ProvScheme command. You can also update the input of a machine profile catalog from a VM to a launch template version and from a launch template version to a VM.
```powershell
Set-ProvScheme -ProvisioningSchemeName $provisioningSchemeName -MachineProfile $machineProfile
```
**Note**: The updated ProvScheme's Machine Profile will be applicable to new machines post Set-ProvScheme, not to the existing machines. It is not yet supported on existing machines.

### Important notes:
- If you add machine hardware property parameters in the New-ProvScheme and Set-ProvScheme commands, then the values provided in the parameters will overwrite the values in the machine profile. These parameter include:
    - Service Offering
    - Network
    - Security Groups
    - Tenancy Type
- You can use Set-ProvScheme to convert your non-MachineProfile based catalogs to MachineProfile based. However, you cannot convert a MachineProfile based catalog to a non-MachineProfile based catalog.
- You cannot set both the custom property `AwsCaptureInstanceProperties` as `True` and `MachineProfile` at the same time. 
    - **Note**: The `AwsCaptureInstanceProperties` is being deprecated so we highly recommend to not use it.

[More info about using Machine Profile in AWS](https://docs.citrix.com/en-us/citrix-daas/install-configure/machine-catalogs-create/create-machine-catalog-aws.html#create-a-machine-profile-based-machine-catalog-using-powershell)