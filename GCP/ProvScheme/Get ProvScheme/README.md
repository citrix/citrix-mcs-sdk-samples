# Get Provisioning Scheme
## Overview
Using MCS Provisioning, you can create and configure virtual machines by defining a provisioning scheme. A provisioning scheme holds information such as hosting unit, identity pool, master image, network mapping, machine profile, machine type etc. You can use the `Get-provScheme` cmdlet to retrieve information about a provisioning scheme.

## How to get provisioning scheme
You can use the Get-provScheme cmdlet with various parameters to filter, sort or limit the results. For example, you can use the `-ProvisioningSchemeName` parameter to get a specific provisioning scheme by its name:
```powershell
Get-ProvScheme -ProvisioningSchemeName "MyCatalog" 
```

You can get all the provisioning schemes in the current site and list their specific properties. For example, below script gets Name, Version, CleanOnBoot and MasterImage for all schemes:
```powershell
Get-ProvScheme | select ProvisioningSchemeName, ProvisioningSchemeVersion, CleanOnBoot, MasterImageVM

ProvisioningSchemeName ProvisioningSchemeVersion CleanOnBoot MasterImageVM
---------------------- ------------------------- ----------- -------------
CatalogA                                       3        True XDHyp:\HostingUnits\Demo\image.folder\demo.resourcegroup\snapshotDemo.snapshot
CatalogB                                       1       False XDHyp:\HostingUnits\Demo\image.folder\demo.resourcegroup\diskA.manageddisk
CatalogC                                       2        True XDHyp:\HostingUnits\Demo\image.folder\demo.resourcegroup\snapshotB.snapshot
```

Another example of using a filter is shown below. It deletes provisioning schemes that contain the word “Demo” in their names. 
```powershell
Get-ProvScheme -Filter "ProvisioningSchemeName -like '*Demo*'" | foreach { Remove-ProvScheme -ProvisioningSchemeUid $_.ProvisioningSchemeUid}
```