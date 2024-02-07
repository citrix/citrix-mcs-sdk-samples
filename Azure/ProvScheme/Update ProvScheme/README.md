# Update Provisioning Scheme
## Overview
After creating an MCS catalog, you can modify the custom properties, machine profile, network mapping, security group, and other parameters of an existing provisioning scheme by running `Set-ProvScheme`. 

To use Set-ProvScheme, you need to specify the provisioning scheme you want to modify by its provisioning scheme name (`-ProvisioningSchemeName`) or identifier (`-ProvisioningSchemeUid`). 

When changing a configuration using CustomProperties, you only need to specify the property that needs to be modified. When a property can be set by both Set-ProvScheme parameter and MachineProfile, for example you can define StorageType in both CustomProperties and MachineProfile, or machine size can be set in both ServiceOffering and MachineProfile, the setting specified by particular parameter will be applied first. If it is not specifically set, properties defined in MachineProfile will be applied.

## How to update provisioning scheme
Provisioning scheme settings can be set directly through parameters when running the powershell command Set-ProvScheme. Here is an example to change ServiceOffering directly:
```powershell
Set-ProvScheme -ProvisioningSchemeName "MyCatalog" -ServiceOffering "XDHyp:\Connections\my-connection-name\East US.region\serviceoffering.folder\Standard_B1ls.serviceoffering"
```

You can also modify provisioning scheme's CustomProperties. For example, to change the StorageType to Premium_LRS for a catalog:
```powershell
$customProperties = '<CustomProperties xmlns="http://schemas.citrix.com/2014/xd/machinecreation" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">
<Property xsi:type="StringProperty" Name="StorageType" Value="Premium_LRS" />
</CustomProperties>'

Set-ProvScheme -ProvisioningSchemeName "MyCatalog" -CustomProperties $customProperties
```

Azure catalogs can inherit certain properties from MachineProfile (either a VM or a template spec). You can modify MachineProfile to a new template spec, for example:
```powershell
$machineProfile = "XDHyp:\HostingUnits\my-hostingunit-name\machineprofile.folder\myResourceGroupName.resourcegroup\myTemplateSpecName.templatespec\myTemplateSpecVersion.templatespecversion"

Set-ProvScheme -ProvisioningSchemeName "MyCatalog" -MachineProfile $machineProfile
```

To change MachineProfile to a new VM, for example:
```powershell
$machineProfile = "XDHyp:\HostingUnits\my-hostingunit-name\machineprofile.folder\myResourceGroupName.resourcegroup\demoMachine.vm"

Set-ProvScheme -ProvisioningSchemeName "MyCatalog" -MachineProfile $machineProfile
```

## How to revert to a previous provisioning scheme version
After you modify the provisioning scheme, we store each modification as a provisioning scheme version in the Citrix site database. In the example, there are 3 versions associated with the catalog. Version 3 is the current configuration. You can revert the provisioning scheme to a previous version. For example:
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
**Notes**: When the `-Version` parameter is used, you cannot specify other parameters to modify settings at the same time. The provisioning scheme version feature is compatible with Citrix Virtual Apps and Desktops 7 2402 Long Term Service Release (LTSR).

## How to apply changes to existing catalog machines
After running Set-ProvScheme, any new catalog machines created after the modification will have the new configuration. For existing catalog machines, you need to run  `Set-ProvVMUpdateTimeWindow` to set a time window on provisioned virtual machines during which they will undergo a property change on boot. The provisioning scheme changes will be applied to the specified existing machines when they are next booted within the time window. 

You can schedule all existing VMs in the catalog to be updated with the new configuration on the next power on, for example:
```powershell
Set-ProvVmUpdateTimeWindow -ProvisioningSchemeName "MyCatalog"
```

You can also apply changes to specific machines (VM01 and VM02), while other catalog machines retain their configurations from before the change. For example:
```powershell
Set-ProvVmUpdateTimeWindow -ProvisioningSchemeName "MyCatalog" -VMName VM01, VM02 -StartsNow -DurationInMinutes -1
```

## Common error cases
If a user enters an invalid or unsupported value for parameters, `Set-ProvScheme` will catch these errors early and return helpful error messages. Here are some examples:
1. If the ResourceGroup defined in CustomProperties cannot be retrieved from Azure, you will receive an error message: "Could not find supplied resource group 'xxxx' within the subscription and region".
2. If you specify a different ResourceGroup name in CustomProperties, you will receive an error message: "ResourceGroup cannot be changed once the catalog is created".
3. If you attempt to change an accelerated network enabled catalog to use a machine size that doesn't support accelerated networking, you will receive an error message: "The machine size {XXX} does not support Accelerated Networking".
4. If you attempt to change service offering and scheme version at the same time, you will receive an error message: "Cannot change provisioning scheme settings while also changing the provisioning scheme version".