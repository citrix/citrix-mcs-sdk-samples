# Provisioning Scheme
## Overview
Provisioning Scheme can be seen as a "template" used to store the parameters and create the VMs. It includes details like the CPU Count of the Master Image VM, the Memory Size of the Master Image VM as well as the location of the Master Image VM used in this provisioning scheme. Provisioning Scheme is used to create a catalog.

## How to use Provisioning Scheme and Catalog
### Create ProvScheme and Catalog
To create a Provisioning Scheme, the following parameters are required:
- `ProvisioningSchemeName`
- `HostingUnitName`
- `IdentityPoolName` 
- `MasterImageVm`
- `ServiceOffering`
    - This is only required if the `MachineProfile` parameter is not present
    - To see different types of Instance types, checkout the [AWS Documentation](https://aws.amazon.com/ec2/instance-types/)

The following parameters are optional
- `CleanOnBoot`
- `InitialBatchSizeHint`
    - Default value will be `0`
- `SecurityGroup`
    - The default value is the default VPC security group. 
- `NetworkMapping`
    - The default value is the network assigned to the hosting unit
- `CustomProperties`
    - To see what custom properties there are in AWS, checkout the [Citrix Documentation](https://developer-docs.citrix.com/en-us/citrix-virtual-apps-desktops-sdk/current-release/machinecreation/about_prov_customproperties#custom-properties-for-aws)

To get the following resources mentioned above using powershell:
```powershell
# To get a list of Hosting units' full path
Get-ChildItem -Path "XDHyp:\HostingUnits" | Select FullPath
# To get a list of Master Image VMs' full path
Get-ChildItem -Path "XDHyp:\HostingUnits\[hosting unit name]" | Where-Object ObjectTypeName -eq "template" | Select FullPath
# To get a list of service offerings' full path
Get-ChildItem -Path "XDHyp:\HostingUnits\[hosting unit name]" | Where-Object ObjectTypeName -eq "serviceoffering" | Select FullPath
# To get a list of security group' full path
Get-ChildItem -Path "XDHyp:\HostingUnits\[hosting unit name]" | Where-Object ObjectTypeName -eq "securitygroup" | Select FullPath
# To get a list of networks' full path
Get-ChildItem -Path "XDHyp:\HostingUnits\[hosting unit name]\[availability zone name]" | Where-Object ObjectTypeName -eq "network" | Select FullPath
```

There are also feature specific parameters. Check out the following links to learn more
- [MachineProfile](MachineProfile/README.md)
- [Backup VM Sizes](Backup%20VM%20Sizes/README.MD)

Once you have the values, create the provisioning scheme with `New-ProvScheme`
```powershell
$isCleanOnBoot = $false
$provisioningSchemeName = "demo-provScheme"
$availabilityZone = "us-east-1a.availabilityzone"
$subnet = "0.0.0.0``/0 (vpc-12345678910).network" #note this extra ` is needed
$identityPoolName = $provisioningSchemeName
$hostingUnitName = "demo-hostingunit"
$networkMapping = @{"0"="XDHyp:\HostingUnits\$hostingUnitName\$availabilityZone\$subnet"}
$numberOfVms = 1
$serviceOffering = "XDHyp:\HostingUnits\$hostingUnitName\T2 Medium Instance.serviceoffering"
$customProperties = "AwsCaptureInstanceProperties,true;AwsOperationalResourcesTagging,True"
$masterImageVm = "XDHyp:\HostingUnits\$hostingUnitName\demo-master-image (ami-12345678910).template"
$securityGroupPath = "XDHyp:\HostingUnits\$hostingUnitName\default.securitygroup"

# Create Provisioning Scheme
$createdProvScheme = New-ProvScheme -ProvisioningSchemeName $provisioningSchemeName `
    -CleanOnBoot:$isCleanOnBoot `
    -CustomProperties $customProperties `
    -HostingUnitName $hostingUnitName `
    -IdentityPoolName $identityPoolName `
    -InitialBatchSizeHint $numberOfVms `
    -MasterImageVm $masterImageVm `
    -NetworkMapping $networkMapping `
    -SecurityGroup $securityGroupPath `
    -ServiceOffering $serviceOffering
```
[New-ProvScheme Documentation Link](https://developer-docs.citrix.com/en-us/citrix-virtual-apps-desktops-sdk/current-release/machinecreation/new-provscheme)

After create a provisioning scheme, create the MCS Catalog. To create the catalog, you need the following parameters:
- `Name`
- `ProvisioningSchemeId`
- `AllocationType`
- `PersistUserChanges`
- `SessionSupport`

```powershell
$allocationType = "Random"
$persistUserChanges = "Discard"
$sessionSupport = "MultiSession"
$description = "This is not required"

# This should now be able to see the catalog in Studio
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

[New-BrokerCatalog Documentation](https://developer-docs.citrix.com/en-us/citrix-virtual-apps-desktops-sdk/current-release/Broker/new-brokercatalog)

### Getting ProvScheme Properties
To get a specific ProvScheme, use the `ProvisioningSchemeName` parameter in `Get-ProvScheme`
```powershell
$provSchemeName = "demo-provScheme"
Get-ProvScheme -ProvisioningSchemeName $provSchemeName
```

You can get a list of ProvScheme with at most a certain number using `MaxRecordCount`.
```powershell
Get-ProvScheme -MaxRecordCount 5
```

**Note**: if no parameter is provided, then the script will return all the ProvSchemes

[Get-ProvScheme Documentation](https://developer-docs.citrix.com/en-us/citrix-virtual-apps-desktops-sdk/current-release/machinecreation/get-provscheme)

### Getting Catalog Properties
To get a specific catalog, use the `Name` parameter in `Get-BrokerCatalog`
```powershell
$catalogName = "demo-provScheme"

Get-BrokerCatalog -Name $catalogName
```

You can get a filtered list of Catalogs using `Filter`. The list can be sorted and set a max limit of number Catalogs you want in a list using `SortBy` and `MaxRecordCount`. <br> [More info about Filter and SortBy](https://developer-docs.citrix.com/en-us/citrix-virtual-apps-desktops-sdk/current-release/machinecreation/about_prov_filtering)
```powershell
$filter = "{AllocationType -eq 'Random' -and PersistUserChanges -eq 'OnLocal' }"
$sortBy = "-AvailableCount"
$maxRecord = 5

Get-BrokerCatalog -Filter $filter -SortBy $sortBy -MaxRecordCount $maxRecord
```

**Note**: if no parameter is provided, then the script will return all the catalogs

[Get-BrokerCatalog Documentation](https://developer-docs.citrix.com/en-us/citrix-virtual-apps-desktops-sdk/current-release/Broker/get-brokercatalog)

# Updating Catalog properties
## Description
You can change the following properties of a ProvScheme:
- `MasterImageVM`
- `ProvisioningSchemeName` 
- `CustomProperties`
- `IdentityPoolName`
- `NetworkMapping`
- `SecurityGroup`
- `ServiceOffering`

To change the Master Image, use `Publish-ProvMasterVMImage`
```powershell
$masterImageVm = "XDHyp:\HostingUnits\$hostingUnitName\demo-master-image (ami-12345678910).template"
Publish-ProvMasterVMImage -MasterImageVM $masterImageVm -ProvisioningSchemeName $provisioningSchemeName
```
**Note**: The updated master image will be applicable to new machines post operation, not to the existing machines unless the catalog has `CleanOnBoot` set. If `CleanOnBoot` is set, previously created VMs will be updated to the new image after the next time they are started.

[Publish-ProvMasterVMImage Documentation](https://developer-docs.citrix.com/en-us/citrix-virtual-apps-desktops-sdk/current-release/MachineCreation/Publish-ProvMasterVMImage.html)

To change the ProvScheme name, use `Rename-ProvScheme`
```powershell
$newprovisioningSchemeName = "new-demo-provScheme"
Rename-ProvScheme -ProvisioningSchemeName $provisioningSchemeName -NewProvisioningSchemeName $newprovisioningSchemeName
```
[Rename-ProvScheme Documentation](https://developer-docs.citrix.com/en-us/citrix-virtual-apps-desktops-sdk/current-release/machinecreation/rename-provscheme)

To change the other ProvScheme properties, use `Set-ProvScheme`
```powershell
$provisioningSchemeName = "demo-provScheme"
$availabilityZone = "us-east-1a.availabilityzone"
$subnet = "1.1.1.1``/1 (vpc-12345678910).network"
$networkMapping = @{"0"="XDHyp:\HostingUnits\$hostingUnitName\$availabilityZone\$subnet.network"}
$serviceOffering = "XDHyp:\HostingUnits\$hostingUnitName\T3 Medium Instance.serviceoffering"
$customProperties = "AwsCaptureInstanceProperties,false;AwsOperationalResourcesTagging,false"
$securityGroupPath = "XDHyp:\HostingUnits\default.securitygroup"

Set-ProvScheme -ProvisioningSchemeName $provisioningSchemeName `
-CustomProperties $customProperties `
-NetworkMapping $networkMapping `
-SecurityGroup $securityGroupPath `
-ServiceOffering $serviceOffering
```
**Note**: The updated ProvScheme's property values will be applicable to new machines post Set-ProvScheme, not to the existing machines. It is not yet supported on existing machines.

[Set-ProvScheme Documentation](https://developer-docs.citrix.com/en-us/citrix-virtual-apps-desktops-sdk/current-release/machinecreation/set-provscheme)

For Catalog, you can change the description and rename the catalog 

To change the description, use `Set-BrokerCatalog`
```powershell
$description = "This is a new description"
Set-BrokerCatalog -Name $provisioningSchemeName -Description $description
```
[Set-BrokerCatalog Documentation](https://developer-docs.citrix.com/en-us/citrix-virtual-apps-desktops-sdk/current-release/broker/set-brokercatalog)

To change the name of the catalog, use `Rename-BrokerCatalog`
```powershell
$newCatalogName = "new-demo-provScheme"
Rename-BrokerCatalog -Name $provisioningSchemeName -NewName $newCatalogeName
```

[Rename-BrokerCatalog Documentation](https://developer-docs.citrix.com/en-us/citrix-virtual-apps-desktops-sdk/current-release/broker/rename-brokercatalog)<br>

### Delete ProvScheme and Catalog
To remove the catalog, use `Remove-BrokerCatalog` and pass in the catalog name
```powershell
$provisioningSchemeName = "demo-provScheme"
Remove-BrokerCatalog -Name $provisioningSchemeName
```
[Remove-BrokerCatalog Documentation](https://developer-docs.citrix.com/en-us/citrix-virtual-apps-desktops-sdk/current-release/broker/remove-brokercatalog)

To remove the provscheme, use `Remove-ProvScheme`. <br> 
```powershell
$provisioningSchemeName = "demo-provScheme"
Remove-ProvScheme -ProvisioningSchemeName $provisioningSchemeName
```
You can also pass in the optional parameter `ForgetVM`. If this parameter is present, MCS will remove the provisioning scheme data from the Citrix site database and also delete Citrix-assigned identifiers(like tags or custom-attributes) on provisioning scheme, VMs and their related resources from hypervisor. The VMs and related resources created in the provisioning scheme still remain in the hypervisor.
```powershell
Remove-ProvScheme -ProvisioningSchemeName $provisioningSchemeName -ForgetVM
```

There is also another optional parameter `PurgeDBOnly`. If this option is specified, this command will only remove the provisioning scheme data from the Citrix site database. However, the VMs and related resources created in the provisioning scheme still remain in the hypervisor. This cannot be used with `ForgetVM` 
```powershell
Remove-ProvScheme -ProvisioningSchemeName $provisioningSchemeName -PurgeDBOnly
```
**Note**: This will not remove the Citrix-assigned identifiers(like tags or custom-attributes).

[Remove-ProvScheme Documentation](https://developer-docs.citrix.com/en-us/citrix-virtual-apps-desktops-sdk/current-release/machinecreation/remove-provscheme)