# Get Provisioning Scheme
## Overview
The `Get-provScheme` cmdlet can be used to retrieve information about a provisioning scheme. For example, you might use the command to retrieve the master image used to create a particular scheme or to retrieve the name of the identity pool associated with a scheme.

### How to get provisioning scheme
You can use the `-ProvisioningSchemeName` to get a specific provisioning scheme by its name:
```powershell
Get-ProvScheme -ProvisioningSchemeName "MyCatalog" 
```

To get all the provisioning schemes in the current site and list their specific properties, you can simply run:
```powershell
Get-ProvScheme | select ProvisioningSchemeName, ProvisioningSchemeVersion, CleanOnBoot, MasterImageVM

ProvisioningSchemeName ProvisioningSchemeVersion CleanOnBoot MasterImageVM
---------------------- ------------------------- ----------- -------------
CatalogA                                       1        True XDHyp:\HostingUnits\Demo\mastervm1.vm\mastersnapshot1.snapshot
CatalogB                                      1        False XDHyp:\HostingUnits\Demo\mastervm2.vm\mastersnapshot2.snapshot
```

You can get a list of ProvScheme with at most a certain number using `MaxRecordCount`.
```powershell
Get-ProvScheme -MaxRecordCount 5
```
**Note**: if no parameter is provided, then the script will return all the ProvSchemes

To delete the provisioning schemes that contain the word “Demo” in their names, you can first retrieve the provisioning schemes using filter, and delete them: 
```powershell
Get-ProvScheme -Filter "ProvisioningSchemeName -like '*Demo*'" | foreach { Remove-ProvScheme -ProvisioningSchemeUid $_.ProvisioningSchemeUid -PurgeDBOnly }
```

[Get-ProvScheme Documentation](https://developer-docs.citrix.com/en-us/citrix-virtual-apps-desktops-sdk/current-release/machinecreation/get-provscheme)

### How to get Catalog Properties
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

