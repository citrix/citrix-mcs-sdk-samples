# Reset Prov VM Disk
## Overview
Using MCS Provisioning, you can reset the either the identity or the OS disk of persistent VMs.

## How to use Reset Prov VM Disk
You can reset the identity or the OS disk of a persistent VM by using the `Reset-ProvVMDisk`. First, you need the `ProvisioningSchemeName` and `VMName`
```powershell
$provisioningSchemeName = "demo-provScheme"
$VMName = "demo-provVM1"
```
Before you Reset the Disk, make sure that the Broker Machine is in Maintenance mode. You can do this by using the command
[Set-BrokerMachineMaintenanceMode](https://developer-docs.citrix.com/en-us/citrix-virtual-apps-desktops-sdk/current-release/Broker/Set-BrokerMachineMaintenanceMode.html)


Once the machine is in Maintenance mode, call the command `Reset-ProvVMDisk` and specify either `Identity` to reset the Identity Disk or `OS` to reset the OS Disk. You could also specify both `Identity` and `OS` parameter if you want to reset both disks.
```powershell
# Include Repair-AcctIdentity only if you need to reset the Identity Disk
$adUsername = "demo-username"
$secureUserInput = Read-Host 'Please enter your AD password' -AsSecureString
$encryptedInput = ConvertFrom-SecureString -SecureString $secureUserInput
$adPassword = ConvertTo-SecureString -String $encryptedInput

Repair-AcctIdentity -IdentityAccountId $provVM.ADAccountSid -PrivilegedUserName $adUsername -PrivilegedUserPassword $adPassword -Target IdentityInfo

Reset-ProvVMDisk -ProvisioningSchemeName $provisioningSchemeName -VMName $VMName -Identity -OS
```
**Note**: This will fail if you do not use specifiy either `IdentityDisk` or `OSDisk`

[Reset-ProvVMDisk](https://developer-docs.citrix.com/en-us/citrix-virtual-apps-desktops-sdk/current-release/machinecreation/reset-provvmdisk)