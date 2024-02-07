# Provisioning Scheme Version
## Overview
When you create a new provisioning scheme, it will start with version number 1. Each time you modify a provisioning scheme using the `Set-ProvScheme` cmdlet, the version number will be incremented by 1. This helps you keep track of the changes and revert to a previous version if needed. You can use the `Get-ProvSchemeVersion` cmdlet to list all the provisioning scheme configuration versions or retrieve a particular provisioning scheme version by number. You can also use the `Remove-ProvSchemeVersion` cmdlet to delete a specific version of a provisioning scheme from the Citrix site database. The provisioning scheme version feature is compatible with Citrix Virtual Apps and Desktops 7 2402 Long Term Service Release (LTSR).

## How to use Provisioning Scheme Version
After a provisioning scheme is created or modified, a provisioning scheme version is saved. You can list the versions to track changes. For example, the MachineProfile of "MyCatalog" has been updated multiple times. To get a list of all saved provisioning scheme configuration versions related to the provisioning scheme name, you can run:
```powershell
Get-ProvSchemeVersion -ProvisioningSchemeName "MyCatalog" | select ProvisioningSchemeName, ProvisioningSchemeUid, MachineProfile, ServiceOffering, Version | sort version

ProvisioningSchemeName : MyCatalog
ProvisioningSchemeUid  : 5b37b311-fa3f-49dd-b93b-661b9e6fa571
MachineProfile         : machineprofile.folder\demo.resourcegroup\demo-vm.templatespec\demo1.templatespecversion
ServiceOffering        : serviceoffering.folder\Standard_D2s_v5.serviceoffering
Version                : 1

ProvisioningSchemeName : MyCatalog
ProvisioningSchemeUid  : 5b37b311-fa3f-49dd-b93b-661b9e6fa571
MachineProfile         : machineprofile.folder\demo.resourcegroup\demo-vm.templatespec\demo2.templatespecversion
ServiceOffering        : serviceoffering.folder\Standard_D2s_v3.serviceoffering
Version                : 2

ProvisioningSchemeName : MyCatalog
ProvisioningSchemeUid  : 5b37b311-fa3f-49dd-b93b-661b9e6fa571
MachineProfile         : machineprofile.folder\demo.resourcegroup\demo-vm.templatespec\demo3.templatespecversion
ServiceOffering        : serviceoffering.folder\Standard_D2s_v5.serviceoffering
Version                : 3
```

You can get a particular saved provisioning scheme version by the provisioning scheme name and version number. For example,
```powershell
Get-ProvSchemeVersion -ProvisioningSchemeName "MyCatalog"  -Version 2
```

You can delete provisioning scheme versions as long as they aren't referenced by a VM. For example,
```powershell
Remove-ProvSchemeVersion -ProvisioningSchemeName "MyCatalog"  -Version 2
```
**Note**: After removing version number 2, if you modify the provisioning scheme again, a new provisioning scheme version will be created and saved. In this example, the new version number will be 4 by incrementing current version number 3 by 1.

You can store 99 versions for a provisioning scheme by default. You can change this maximum number with the Powershell cmdlet `Set-ProvServiceConfigurationData`. For example:
```powershell
Set-ProvServiceConfigurationData -Name "MaxProvSchemeVersions" -Value 150
```
After this update, you can store 150 versions for a provisioning scheme. And the maximum value you can set is 32,000.

## How to revert provisioning scheme to a different Provisioning Scheme Version
After you modify the provisioning scheme, we store each modification as a provisioning scheme version in the Citrix site database. In the example, there are 3 versions assoicated with the catalog. Version 3 is the current configuration. You can revert the provisioning scheme to a previous version. For example:
```powershell
Get-ProvSchemeVersion -ProvisioningSchemeName "MyCatalog" | select ProvisioningSchemeName, ProvisioningSchemeUid, Version | sort version

ProvisioningSchemeName : MyCatalog
ProvisioningSchemeUid  : 5b37b311-fa3f-49dd-b93b-661b9e6fa571
Version                : 1

ProvisioningSchemeName : MyCatalog
ProvisioningSchemeUid  : 5b37b311-fa3f-49dd-b93b-661b9e6fa571
Version                : 2

ProvisioningSchemeName : MyCatalog
ProvisioningSchemeUid  : 5b37b311-fa3f-49dd-b93b-661b9e6fa571
Version                : 3

Set-ProvScheme -ProvisioningSchemeName "MyCatalog" -Version 2
```
**Notes**: When `-Version` parameter is used, you cannot specify other parameters to modify settings at the same time.

## Common error cases
If a user enters an invalid or unsupported value for parameters, `Set-ProvScheme` will catch these errors early and return helpful error messages. Here are some examples:
1. If you attempt to remove a provisioning scheme version that is being referenced by machines, you will receive an error message: "The provisioning scheme version cannot be removed due to it being referenced by other resources."
2. If you attempt to remove a provisioning scheme version that is the current version, you will receive an error message: "The provisioning scheme version cannot be removed since it is the current version.".
3. If you attempt to modify a provisioning scheme and it has reached the maximum version number, you will receive an error message: "The change in provisioning scheme could not be performed due to the maximum version number being exceeded. Older versions were not able to be pruned.".