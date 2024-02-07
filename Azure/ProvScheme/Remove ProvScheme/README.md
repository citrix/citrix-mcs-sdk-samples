# Remove Provisioning Scheme
## Overview
Using MCS Provisioning, you can remove a provisioning scheme using the `Remove-ProvScheme` PowerShell cmdlet. In general, the command will remove the provisioning scheme data from the Citrix site database and also delete its associated resources, such as base disk snapshots from the hypervisor. Before you run the command, make sure there are no catalog machines associated with the provisioning scheme. You can run `Get-ProvVM -ProvisioningSchemeName ...` to verify an empty result is returned. However, under certain circumstances, you may want to keep resources on the hypervisor while removing the provisioning scheme data from the database. In such cases, you can use the `-ForgetVM` parameter or `-PrugeDBOnly` parameter. 

## How to remove a provisioning scheme
When the MCS catalog doesn't contain any machine, you can simply run Remove-ProvScheme to remove the provisioning scheme. For example: 
```powershell
Remove-ProvScheme -ProvisioningSchemeName "MyCatalog" 
```

## How to remove a provisioning scheme while retaining persistent catalog machines in Azure (ForgetVM)
The `ForgetVM` parameter is useful when you want to remove the provisioning scheme data from the Citrix site database, while retaining catalog machines created in Azure. For example:
```powershell
Remove-ProvScheme -ProvisioningSchemeName "MyCatalog" -ForgetVM
```
When you use the `-ForgetVM` parameter, the provisioning scheme data is removed from the Citrix site database, and catlog-level resources like base disk snapshot are also deleted from Azure. The Azure VMs and their related Azure resources (disks, network interfaces, etc.) will remain in Azure; however, resource tags (tag names start with `Citrix`, for example CitrixProvisioningSchemeId) created during MCS provisioning process will be removed.
**Note**: 
1. `ForgetVM` is only applied to a machine catalog that has persistent VMs. 
2. `ForgetVM` and `PurgeDBOnly` parameters cannot be specified at the same time.

## How to remove a provisioning scheme when the hypervisor connection is lost (PurgeDBOnly)
The `PurgeDBOnly` parameter is useful when you are no longer able to contact the hypervisor and want to remove a provisioning scheme from the Citrix site database only. For example:
```powershell
Remove-ProvScheme -ProvisioningSchemeName "MyCatalog" -PurgeDBOnly
```
When you use the `-PurgeDBOnly` parameter, the Azure resources related to provisioning scheme, such as base disk snapshot, resource group if created, VMs, disks, NICs will remain in Azure. Tags created during the MCS provisioning process will also remain.
**Note**: `ForgetVM` and `PurgeDBOnly` parameters cannot be specified at the same time.

## Common error case
If you attempt to remove a provisioning scheme that contains virtual machines, and the `ForgetVM` or `PurgeDBOnly` parameter is not specified, you will receive an error: "Unable to remove the provisioning scheme as it still contains virtual machines, either delete all the ProvVMs in the ProvScheme and try again, or call Remove-ProvScheme with the parameter -PurgeDB to remove the provscheme and leave the VMs on the hypervisor/cloud."