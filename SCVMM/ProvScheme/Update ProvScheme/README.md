# Update Provisioning Scheme
## Overview
After creating an MCS catalog, you can modify the cpu count, memory, machine profile, network mapping, and other parameters of an existing provisioning scheme by running `Set-ProvScheme`.

To use Set-ProvScheme, you need to specify the provisioning scheme you want to modify by its provisioning scheme name (`-ProvisioningSchemeName`) or identifier (`-ProvisioningSchemeUid`). 

## How to update the master image
Master image of a provisioning scheme can be set directly through `-MasterImageVM` parameter when running powershell command `Publish-ProvMasterVMImage` to propagate hard disk changes to the catalog machines associated with the provisioning scheme. Here is an example to change the master image directly:
```powershell
Publish-ProvMasterVMImage -ProvisioningSchemeName demo-catalog -MasterImageVM XDHyp:\HostingUnits\demo-hostingunit\demo-master-vm.vm\demo-master-snapshot.snapshot
```

If the provisioning scheme is a `CleanOnBoot` type (non-persistent), then the next time that virtual machines are started, their hard disks are updated to this new image. Regardless of the `CleanOnBoot` type, all new virtual machines created after this command will use this new hard disk image. The previous hard disk image path is stored into the history. You can view the image update history with the Powershell cmdlet `Get-ProvSchemeMasterVMImageHistory`. The data stored in the history allows you to do a rollback to revert to the previous hard disk image if required. 

**Note**: After image update is completed, you need to restart the existing catalog machines so their hard disks will be updated. You can use Start-BrokerRebootCycle to create and start a reboot cycle which ensure that all machines in the catalog are running the most recent image for the catalog.


[Publish-ProvMasterVMImage Documentation]
(https://developer-docs.citrix.com/en-us/citrix-virtual-apps-desktops-sdk/current-release/MachineCreation/Publish-ProvMasterVMImage)

## How to rename a provscheme name
To change the ProvScheme name, use `Rename-ProvScheme`
```powershell
$provisioningSchemeName = "demo-provScheme"
$newprovisioningSchemeName = "new-demo-provScheme"
Rename-ProvScheme -ProvisioningSchemeName $provisioningSchemeName -NewProvisioningSchemeName $newprovisioningSchemeName
```
[Rename-ProvScheme Documentation](https://developer-docs.citrix.com/en-us/citrix-virtual-apps-desktops-sdk/current-release/machinecreation/rename-provscheme)

## How to update few properties like cpu counts network mapping
Here is an example to change CPU count directly:
```powershell
Set-ProvScheme -ProvisioningSchemeName "MyCatalog" -VMCpuCount 2 -
```
**Note**: CPU Count is for onprem hypervisors,not for cloud hypervisors.

Here is an example to change network mapping directly:
```powershell
$deviceID=((Get-SCVirtualMachine -Name "demo-vm1"|Get-SCVirtualNetworkAdapter).DeviceID).Split("\")[1]
$network = "demo-network1.network"
$networkMapping =  @{$deviceID = "XDHyp:\HostingUnits\"+$hostingUnitName+"\"+$network}

Set-ProvScheme -ProvisioningSchemeName "MyCatalog" -NetworkMapping $networkMapping
```

Here is an example to change Memory directly:
``` powershell
$memoryInMb=2
Set-ProvScheme -ProvisioningSchemeName "MyCatalog" -VMMemoryMB $memoryInMb

```

**Note**: After applying `Set-ProvScheme`, the existing machines in the provscheme are not updated. Only the new machines which are added after `Set-ProvScheme` operation are modified.

[Set-ProvScheme Documentation](https://developer-docs.citrix.com/en-us/citrix-virtual-apps-desktops-sdk/current-release/machinecreation/set-provscheme)

## How to rename a Broker Catalog
To change the name of the catalog, use `Rename-BrokerCatalog`
```powershell
$newCatalogName = "new-demo-provScheme"
Rename-BrokerCatalog -Name $provisioningSchemeName -NewName $newCatalogeName
```

[Rename-BrokerCatalog Documentation](https://developer-docs.citrix.com/en-us/citrix-virtual-apps-desktops-sdk/current-release/broker/rename-brokercatalog)<br>

## How to update a Broker Catalog's properties
To change the description, use `Set-BrokerCatalog`
```powershell
$description = "This is a new description"
Set-BrokerCatalog -Name "MyBrokerCatalog" -Description $description
```
[Set-BrokerCatalog Documentation](https://developer-docs.citrix.com/en-us/citrix-virtual-apps-desktops-sdk/current-release/broker/set-brokercatalog)

## Common error cases

1. If a provisioning scheme is not found, we get ProvisioningSchemeNotFound error.
2. If a hosting unit is not found, we get HostingUnitNotFound error.
