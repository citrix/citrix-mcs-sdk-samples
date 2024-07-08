# Update Provisioning Scheme
## Overview
After creating an MCS catalog, you can modify the custom properties, machine profile, network mapping, service offering, and other parameters of an existing provisioning scheme by running `Set-ProvScheme` cmdlet. 

To use Set-ProvScheme, you need to specify the provisioning scheme you want to modify by its name (`-ProvisioningSchemeName`) or identifier (`-ProvisioningSchemeUid`). 

When changing a configuration using CustomProperties, you only need to specify the property that needs to be modified. A property may be set explicitly or through MachineProfile. For example you can define StorageType in both CustomProperties and MachineProfile, or machine type can be set in both ServiceOffering and MachineProfile. In this case, explicitly defined values take precedence. If property is not explicitly set, the value will be derived from the MachineProfile.

## How to update provisioning scheme
Provisioning scheme settings can be set directly through parameters when running the powershell command Set-ProvScheme. The example below shows how to change the ServiceOffering explicitly:
```powershell
Set-ProvScheme -ProvisioningSchemeName "MyCatalog" -ServiceOffering "XDHyp:\HostingUnits\$hostingUnitName\machineTypes.folder\$serviceOffering.serviceoffering"
```

You can also modify the provisioning scheme's CustomProperties. For example, to change the StorageType to pd-ssd for a catalog:
```powershell
$customProperties = '<CustomProperties xmlns="http://schemas.citrix.com/2014/xd/machinecreation" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">
<Property xsi:type="StringProperty" Name="StorageType" Value="pd-ssd" />
</CustomProperties>'

Set-ProvScheme -ProvisioningSchemeName "MyCatalog" -CustomProperties $customProperties
```

GCP catalogs can inherit certain properties from MachineProfile (either a VM or an instance template). You can modify the MachineProfile of a catalog via `-MachineProfile` parameter. For example:
```powershell
$machineProfile = "XDHyp:\HostingUnits\$hostingUnitName\$machineProfileVmName.vm"

Set-ProvScheme -ProvisioningSchemeName "MyCatalog" -MachineProfile $machineProfile
```
Please refer to the example script in "GCP\ProvScheme\Machine Profile\Set-Instance-As-MachineProfile.ps1".


To change MachineProfile to a new instance template:
```powershell
$machineProfile = "XDHyp:\HostingUnits\$hostingUnitName\instanceTemplates.folder\$instanceTemplateName.template"

Set-ProvScheme -ProvisioningSchemeName "MyCatalog" -MachineProfile $machineProfile
```
Please refer to the example script in "GCP\ProvScheme\Machine Profile\Set-InstanceTemplate-As-MachineProfile.ps1".


You can also change the Network Mapping for a catalog. For example:
```powershell
$networkMapping = @{"0"="XDHyp:\HostingUnits\$hostingUnitName\$vpcName.virtualprivatecloud\$subnetName.network"}
Set-ProvScheme -ProvisioningSchemeName $provisioningSchemeName -NetworkMapping $networkMapping
```
Please refer to the example script in "GCP\ProvScheme\Update Provisioning Scheme\Update-ProvScheme-Network-Mapping.ps1".

## How to revert to a previous provisioning scheme version
After modifying the provisioning scheme, each modification is stored as a provisioning scheme version in the Citrix site database. In this example, there are 3 versions associated with the catalog, with version 3 as the current configuration. The provisioning scheme is reverted to version 2 using Set-ProvScheme:
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
**Note**: When the `-Version` parameter is used, you cannot specify other parameters to modify settings at the same time. The provisioning scheme version feature is compatible with Citrix Virtual Apps and Desktops 7 2402 Long Term Service Release (LTSR).

## How to apply changes to existing catalog machines
After running Set-ProvScheme, any new catalog machines created after the modification will have the new configuration. For existing catalog machines, you need to run  `Set-ProvVMUpdateTimeWindow` to set a time window on provisioned virtual machines during which they will undergo a property change on boot. The provisioning scheme changes will be applied to the specified existing machines when they are next booted within the time window. 

You can schedule all existing VMs in the catalog to be updated with the new configuration on the next power on, for example:
```powershell
Set-ProvVmUpdateTimeWindow -ProvisioningSchemeName "MyCatalog"
```

You can also apply changes to specific machines (VM01 and VM02), while other catalog machines retain their existing configurations. For example:
```powershell
Set-ProvVmUpdateTimeWindow -ProvisioningSchemeName "MyCatalog" -VMName VM01, VM02 -StartsNow -DurationInMinutes -1
```

## Common error cases
If a user enters an invalid or unsupported value for parameters, `Set-ProvScheme` will catch these errors early and return helpful error messages. Here are some examples:
* If the VPC name or subnet name is invalid: "The specified network path could not be resolved. Please ensure that the path includes a drive specification and path to a location within a HostingUnit.".
* If the service offering is invalid: "Set-prov scheme validation failed".
* If the provisioning scheme name is invalid: "The specified ProvisioningScheme could not be located.".
* If the machine profile is invalid: "Machine 'machprof-vm' in region 'region' in Project with projectId 'project-id' not found".
* If the cryptokey specified in CustomProperties is invalid: "Invalid CryptoKeyId specified in ProvScheme CustomSettings. Error occurred while validating crypto key 'project-id:region:my-regional-ring:my-regional-ring'".
* If the storage type specified in CustomProperties is invalid: "Set-prov scheme validation failed. Cannot find Boot disktype 'my-storage-type' in zones 'my-zone'".
* If you are trying to set PersistOsDisk in CustomProperties for a catalog with WBC disabled: "PersistOsDisk property can be set only for non-persistent catalog with WBC enabled.".