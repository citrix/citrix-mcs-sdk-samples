# Amazon WorkSpaces Core Provisioning Scheme
## Overview
Provisioning Scheme can be seen as a "template" used to store the parameters and create the VMs. It includes details like the Machine Profile of the VM as well as the UID of the Image Version Spec used in this provisioning scheme. Provisioning Scheme is used to create a catalog.

## How to use Provisioning Scheme and Catalog
### Create ProvScheme and Catalog
To create a Provisioning Scheme, the following parameters are required:
- `ProvisioningSchemeName`
- `HostingUnitName`
- `IdentityPoolName` 
- `ImageVersionSpecUid`
- `MachineProfile`
- `CleanOnBoot`

The following parameters are optional
- `InitialBatchSizeHint`
    - Default value will be `0`
- `ServiceOffering`
    - This is used to override the service offering in the Machine Profile. The value should be the full path of the service offering.
- `NetworkMapping`
    - This is used to override the network mapping in the Machine Profile. The value should be a dictionary of the network devices with the full path of the network items.

To get the following resources mentioned above using powershell:
```powershell
# To get a list of Hosting units' full path
Get-ChildItem -Path "XDHyp:\HostingUnits" | Select FullPath
# To get a list of Machine Profile VMs' full path
Get-ChildItem -Path "XDHyp:\HostingUnits\[hosting unit name]" | Where-Object ObjectTypeName -eq "vm" | Select FullPath
# To get a list of Machine Profile Launch Template Versions' full path
Get-ChildItem -Path "XDHyp:\HostingUnits\[hosting unit name]" | Where-Object ObjectTypeName -eq "launchtemplateversion" | Select FullPath
# To get a list of service offerings' full path
Get-ChildItem -Path "XDHyp:\HostingUnits\[hosting unit name]" | Where-Object ObjectTypeName -eq "serviceoffering" | Select FullPath
# To get a list of security group' full path
Get-ChildItem -Path "XDHyp:\HostingUnits\[hosting unit name]" | Where-Object ObjectTypeName -eq "securitygroup" | Select FullPath
# To get a list of networks' full path
Get-ChildItem -Path "XDHyp:\HostingUnits\[hosting unit name]\[availability zone name]" | Where-Object ObjectTypeName -eq "network" | Select FullPath
```

Once you have the values, create the provisioning scheme with `New-ProvScheme` (Note that the -CleanOnBoot parameter is required and must be $true for Amazon WorkSpaces Core)
```powershell
$isCleanOnBoot = $true
$provisioningSchemeName = "demo-provScheme"
$availabilityZone = "us-east-1a.availabilityzone"
$identityPoolName = $provisioningSchemeName
$hostingUnitName = "demo-hostingunit"
$numberOfVms = 1
$machineProfile = "XDHyp:\HostingUnits\$hostingUnitName\$availabilityZone\machine-profile-vm (i-12345678910).vm"

# The ImageVersionSpecUid is returned when creating a prepared image (See 'Image Management')
$imageVersionSpecUid = "00000000-0000-0000-0000-000000000000"

# These are optional parameters which can be used to override the values in the Machine Profile
$serviceOffering = "XDHyp:\HostingUnits\$hostingUnitName\T2 Medium Instance.serviceoffering"

# Create Provisioning Scheme
$createdProvScheme = New-ProvScheme -ProvisioningSchemeName $provisioningSchemeName `
    -CleanOnBoot:$isCleanOnBoot `
    -HostingUnitName $hostingUnitName `
    -IdentityPoolName $identityPoolName `
    -InitialBatchSizeHint $numberOfVms `
    -MachineProfile $machineProfile `
    -ImageVersionSpecUid $imageVersionSpecUid
```
[New-ProvScheme Documentation Link](https://developer-docs.citrix.com/en-us/citrix-daas-sdk/machinecreation/new-provscheme)

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

[New-BrokerCatalog Documentation](https://developer-docs.citrix.com/en-us/citrix-daas-sdk/Broker/new-brokercatalog)

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

[Get-ProvScheme Documentation](https://developer-docs.citrix.com/en-us/citrix-daas-sdk/machinecreation/get-provscheme)

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

[Get-BrokerCatalog Documentation](https://developer-docs.citrix.com/en-us/citrix-daas-sdk/Broker/get-brokercatalog)

# Updating Catalog properties
## Description
You can change the following properties of a ProvScheme:
- `ImageVersionSpecUid`
- `ProvisioningSchemeName` 
- `IdentityPoolName`
- `MachineProfile`

To change the ImageVersionSpecUid, use `Set-ProvSchemeImage`
```powershell
$imageVersionSpecUid = "00000000-0000-0000-0000-000000000000"
Set-ProvSchemeImage -ImageVersionSpecUid $imageVersionSpecUid -ProvisioningSchemeName $provisioningSchemeName
```

[Set-ProvSchemeImage Documentation](https://developer-docs.citrix.com/en-us/citrix-daas-sdk/machinecreation/set-provschemeimage)

To change the ProvScheme name, use `Rename-ProvScheme`
```powershell
$newprovisioningSchemeName = "new-demo-provScheme"
Rename-ProvScheme -ProvisioningSchemeName $provisioningSchemeName -NewProvisioningSchemeName $newprovisioningSchemeName
```
[Rename-ProvScheme Documentation](https://developer-docs.citrix.com/en-us/citrix-daas-sdk/machinecreation/rename-provscheme)

To change the other ProvScheme properties, use `Set-ProvScheme`
```powershell
$provisioningSchemeName = "demo-provScheme"
$availabilityZone = "us-east-1a.availabilityzone"
$machineProfile = "XDHyp:\HostingUnits\$hostingUnitName\$availabilityZone\machine-profile-vm (i-12345678910).vm"

Set-ProvScheme -ProvisioningSchemeName $provisioningSchemeName `
-MachineProfile $machineProfile

```
**Note**: The updated ProvScheme's property values will be applicable to new machines created after the issued commands, not to the existing machines. It is not yet supported on existing machines.

[Set-ProvScheme Documentation](https://developer-docs.citrix.com/en-us/citrix-daas-sdk/machinecreation/set-provscheme)

For Catalog, you can change the description and rename the catalog 

To change the description, use `Set-BrokerCatalog`
```powershell
$description = "This is a new description"
Set-BrokerCatalog -Name $provisioningSchemeName -Description $description
```
[Set-BrokerCatalog Documentation](https://developer-docs.citrix.com/en-us/citrix-daas-sdk/broker/set-brokercatalog)

To change the name of the catalog, use `Rename-BrokerCatalog`
```powershell
$newCatalogName = "new-demo-provScheme"
Rename-BrokerCatalog -Name $provisioningSchemeName -NewName $newCatalogeName
```

[Rename-BrokerCatalog Documentation](https://developer-docs.citrix.com/en-us/citrix-daas-sdk/broker/rename-brokercatalog)<br>

### Delete ProvScheme and Catalog
To remove the catalog, use `Remove-BrokerCatalog` and pass in the catalog name
```powershell
$provisioningSchemeName = "demo-provScheme"
Remove-BrokerCatalog -Name $provisioningSchemeName
```
[Remove-BrokerCatalog Documentation](https://developer-docs.citrix.com/en-us/citrix-daas-sdk/broker/remove-brokercatalog)

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

[Remove-ProvScheme Documentation](https://developer-docs.citrix.com/en-us/citrix-daas-sdk/machinecreation/remove-provscheme)