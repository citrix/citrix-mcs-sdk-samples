# Provisioning Scheme
## Overview
Provisioning Scheme can be seen as a "template" for creating the VMs. It includes details like the service offering, encryption keys, storage types, network mappings, master image, identity pool etc. which are required to create VMs.

## How to use Provisioning Scheme and Catalog
### Create ProvScheme and Catalog
To create a Provisioning Scheme, we use `New-ProvScheme` cmdlet. To know more about this cmdlet, follow [New-ProvScheme Documentation Link](https://developer-docs.citrix.com/en-us/citrix-virtual-apps-desktops-sdk/current-release/machinecreation/new-provscheme)

Following parameters are mandatory:
- `ProvisioningSchemeName`
- `HostingUnitName`
- `IdentityPoolName` 
- `MasterImageVm`
    - A Citrix inventory path to the VM/snapshot to be used as a master image. 
    - Example VM inventory path - `XDHyp:\HostingUnits\<hostingUnit>\my-vm.vm`
    - Example inventory path for a snapshot of the instance 'my-vm' `XDHyp:\HostingUnits\<hostingUnit>\my-vm.vm\my-snapshot.snapshot`
    - Example inventory path for a multi-region snapshot `XDHyp:\HostingUnits\<hostingUnit>\snapshots.folder\my-multi-region-snapshot.snapshot`

Following parameters are optional:
- `CleanOnBoot`
    - Set to 'true' for non-persistent catalog, 'false' for persistent catalog.   
- `InitialBatchSizeHint`
    - Default value is 0.
- `NetworkMapping`    
    - List of network mappings to be applied to VMs. For example `$networkMapping = {"0"="XDHyp:\HostingUnits\$hostingUnitName\$vpcName.virtualprivatecloud\$subnetName.network"}`
    - The default value is the network assigned to the hosting unit.
- `CustomProperties`
    - To understand custom properties applicable to the GCP, please refer to the [Citrix Documentation](https://developer-docs.citrix.com/en-us/citrix-virtual-apps-desktops-sdk/2402/machinecreation/about_prov_customproperties#custom-properties-for-gcp).
- `MachineProfile`
    - A Citrix inventory path to the VM or instance template to be used as a machine profile. Sample scripts can be found in the 'GCP\ProvScheme\Machine Profile' folder.
- `ServiceOffering`
    - A Citrix inventory path to the machine type. Sample scripts can be found in the 'GCP\ProvScheme\Service Offering' folder.

Once you have the values, create the provisioning scheme with `New-ProvScheme`.
```powershell
New-ProvScheme -CleanOnBoot:$isCleanOnBoot `
	-ProvisioningSchemeName $provisioningSchemeName `
	-HostingUnitName $hostingUnitName `
	-IdentityPoolName $identityPoolName `
	-InitialBatchSizeHint $numberOfVms `
	-MasterImageVM "XDHyp:\HostingUnits\$hostingUnitName\$masterImageVmName.vm\$masterImageSnapshotName.snapshot" `
	-NetworkMapping $networkMapping `
```

Creating a provisioning scheme alone does not make it visible in the Studio. You need to create a broker catalog to view and manage it from the Studio. You can learn more about New-BrokerCatalog cmdlet [here](https://developer-docs.citrix.com/en-us/citrix-virtual-apps-desktops-sdk/2311/Broker/New-BrokerCatalog.html).
### Example
```powershell
New-BrokerCatalog -Name $ProvisioningSchemeName `
    -ProvisioningSchemeId $createdProvScheme.ProvisioningSchemeUid `
    -AllocationType $allocationType  `
    -Description $description `
    -IsRemotePC $False `
    -PersistUserChanges $persistUserChanges `
    -ProvisioningType "MCS" `
    -Scope @() `
    -SessionSupport $sessionSupport
```

### Getting ProvScheme Properties
To get a specific ProvScheme, use the `ProvisioningSchemeName` parameter in `Get-ProvScheme`
```powershell
$provSchemeName = "demo-provScheme"
Get-ProvScheme -ProvisioningSchemeName $provSchemeName
```

You can limit the number of ProvSchemes returned using an optional parameter `MaxRecordCount`.
```powershell
Get-ProvScheme -MaxRecordCount 5
```
For more information, please refer to the [Get-ProvScheme Documentation](https://developer-docs.citrix.com/en-us/citrix-virtual-apps-desktops-sdk/current-release/machinecreation/get-provscheme).

### Getting Broker catalog properties
To get a specific broker catalog, use the `Name` parameter in `Get-BrokerCatalog`.
```powershell
$catalogName = "demo-provScheme"
Get-BrokerCatalog -Name $catalogName
```

You can get a filtered list of Catalogs using `Filter`. The list can be sorted using `SortBy` and capped at using `MaxRecordCount` parameters. [More info about Filter and SortBy](https://developer-docs.citrix.com/en-us/citrix-virtual-apps-desktops-sdk/current-release/machinecreation/about_prov_filtering)
```powershell
$filter = "{AllocationType -eq 'Random' -and PersistUserChanges -eq 'OnLocal' }"
$sortBy = "-AvailableCount"
$maxRecord = 5

Get-BrokerCatalog -Filter $filter -SortBy $sortBy -MaxRecordCount $maxRecord
```

[Get-BrokerCatalog Documentation](https://developer-docs.citrix.com/en-us/citrix-virtual-apps-desktops-sdk/current-release/Broker/get-brokercatalog)

### Updating Catalog properties
You can change the following properties of a ProvScheme:
- `MasterImageVM`
- `ProvisioningSchemeName`
- `CustomProperties`
- `IdentityPoolName`
- `NetworkMapping`
- `ServiceOffering`
- `MachineProfile`

To change the Master Image, use `Publish-ProvMasterVMImage` cmdlet.
```powershell
$masterImageSnapshot = "XDHyp:\HostingUnits\$hostingUnitName\$masterImageVmName.vm\$masterImageSnapshotName.snapshot"
Publish-ProvMasterVMImage -MasterImageVM $masterImageSnapshot -ProvisioningSchemeName $provisioningSchemeName
```
[Publish-ProvMasterVMImage Documentation](https://developer-docs.citrix.com/en-us/citrix-virtual-apps-desktops-sdk/current-release/MachineCreation/Publish-ProvMasterVMImage.html)

To change the ProvScheme name, use `Rename-ProvScheme` cmdlet.
```powershell
$newprovisioningSchemeName = "new-demo-provScheme"
Rename-ProvScheme -ProvisioningSchemeName $provisioningSchemeName -NewProvisioningSchemeName $newprovisioningSchemeName
```
[Rename-ProvScheme Documentation](https://developer-docs.citrix.com/en-us/citrix-virtual-apps-desktops-sdk/current-release/machinecreation/rename-provscheme)

To change the other ProvScheme properties, use `Set-ProvScheme`.
[Set-ProvScheme Documentation](https://developer-docs.citrix.com/en-us/citrix-virtual-apps-desktops-sdk/current-release/machinecreation/set-provscheme)

For broker catalog, you can change the description and rename the catalog.
To change the description, use `Set-BrokerCatalog`
```powershell
$description = "This is a new description"
Set-BrokerCatalog -Name $provisioningSchemeName -Description $description
```
[Set-BrokerCatalog Documentation](https://developer-docs.citrix.com/en-us/citrix-virtual-apps-desktops-sdk/current-release/broker/set-brokercatalog)

To change the name of the catalog, use `Rename-BrokerCatalog` cmdlet.
```powershell
$newCatalogName = "new-demo-provScheme"
Rename-BrokerCatalog -Name $provisioningSchemeName -NewName $newCatalogeName
```
[Rename-BrokerCatalog Documentation](https://developer-docs.citrix.com/en-us/citrix-virtual-apps-desktops-sdk/current-release/broker/rename-brokercatalog)<br>

### Delete ProvScheme and Catalog
To remove the catalog, use `Remove-BrokerCatalog` and pass in the catalog name.
```powershell
$provisioningSchemeName = "demo-provScheme"
Remove-BrokerCatalog -Name $provisioningSchemeName
```
[Remove-BrokerCatalog Documentation](https://developer-docs.citrix.com/en-us/citrix-virtual-apps-desktops-sdk/current-release/broker/remove-brokercatalog)

To remove the provscheme, use `Remove-ProvScheme` cmdlet.
```powershell
$provisioningSchemeName = "demo-provScheme"
Remove-ProvScheme -ProvisioningSchemeName $provisioningSchemeName
```
You can also pass in the optional parameter `ForgetVM`. If this parameter is present, MCS will remove the provisioning scheme data from the Citrix site database and also delete Citrix-assigned identifiers (like tags or custom-attributes) on provisioning scheme, VMs and their related resources from hypervisor. The VMs and related resources will still remain in the hypervisor.
```powershell
Remove-ProvScheme -ProvisioningSchemeName $provisioningSchemeName -ForgetVM
```

There is also another optional parameter `PurgeDBOnly`. If this option is specified, this command will only remove the provisioning scheme data from the Citrix site database. However, the VMs and related resources will still remain in the hypervisor. This cannot be used with `ForgetVM`.
```powershell
Remove-ProvScheme -ProvisioningSchemeName $provisioningSchemeName -PurgeDBOnly
```
**Note**: This will not remove the Citrix-assigned identifiers(like tags or custom-attributes).
[Remove-ProvScheme Documentation](https://developer-docs.citrix.com/en-us/citrix-virtual-apps-desktops-sdk/current-release/machinecreation/remove-provscheme)