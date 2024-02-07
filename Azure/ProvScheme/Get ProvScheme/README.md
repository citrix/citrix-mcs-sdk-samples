# Get Provisioning Scheme
## Overview
Using MCS Provisioning, you can create and configure virtual machines for Citrix Virtual Apps and Desktops by defining a provisioning scheme. A provisioning scheme is a collection of data that includes information such as the hosting unit, identity pool, master image, network mapping, machine profile, and more. You can use the `Get-provScheme` cmdlet to retrieve information about a provisioning scheme. For example, you might use the command to retrieve the master image used to create a particular scheme or to retrieve the name of the identity pool associated with a scheme.

## How to get provisioning scheme
You can use the Get-provScheme cmdlet with various parameters to filter, sort, or limit the results. For example, you can use the `-ProvisioningSchemeName` to get a specific provisioning scheme by its name:
```powershell
Get-ProvScheme -ProvisioningSchemeName "MyCatalog" 
```

To get all the provisioning schemes in the current site and list their specific properties, you can simply run:
```powershell
Get-ProvScheme | select ProvisioningSchemeName, ProvisioningSchemeVersion, CleanOnBoot, MasterImageVM

ProvisioningSchemeName ProvisioningSchemeVersion CleanOnBoot MasterImageVM
---------------------- ------------------------- ----------- -------------
CatalogA                                       3        True XDHyp:\HostingUnits\Demo\image.folder\demo.resourcegroup\snapshotDemo.snapshot
CatalogB                                       1       False XDHyp:\HostingUnits\Demo\image.folder\demo.resourcegroup\diskA.manageddisk
CatalogC                                       2        True XDHyp:\HostingUnits\Demo\image.folder\demo.resourcegroup\snapshotB.snapshot
```

To delete the provisioning schemes that contain the word “Demo” in their names, you can first retrieve the provisioning schemes using filter, and delete them: 
```powershell
Get-ProvScheme -Filter "ProvisioningSchemeName -like '*Demo*'" | foreach { Remove-ProvScheme -ProvisioningSchemeUid $_.ProvisioningSchemeUid -PurgeDBOnly }
```