# Update Provisioned Virtual Machine
## Overview
The Set-ProvVM command is utilized to modify the configuration of an already provisioned persistent virtual machine.
The properties customized for this virtual machine are unique to the machine, not impacting other machines in the catalog. The machine's final properties result from a combination of the current settings on the provisioning scheme and those specified here. Any properties set at the ProvVM-level using this command take precedence over ProvScheme-level settings.
It's important to note that configuration changes do not immediately apply to the existing machine. To implement the updates, establish an update time window for the machine using Set-ProvVMUpdateTimeWindow and initiate the machine within that window.

For more detailed information, you can refer to the following documentation:
1. [Set-ProvVM](https://developer-docs.citrix.com/en-us/citrix-daas-sdk/machinecreation/set-provvm).
2. [Set-ProvVMUpdateTimeWindow](https://developer-docs.citrix.com/en-us/citrix-virtual-apps-desktops-sdk/current-release/machinecreation/set-provvmupdatetimewindow).

**Note**
1. To inspect the current unique configuration of a machine, use the Get-ProvVMConfiguration command. Each time Set-ProvVM is executed, it increments the version of the provisioning virtual machine by 1. This version increment can be verified by running Get-ProvVMConfiguration.
For more details on [Get-ProvVMConfiguration](https://developer-docs.citrix.com/en-us/citrix-daas-sdk/machinecreation/get-provvmconfiguration).
```powershell
Get-ProvVMConfiguration -ProvisioningSchemeName $provisioningSchemeName -VMName $vmName
```
The original version of this script is compatible with Citrix Virtual Apps and Desktops 7 2402 Long Term Service Release (LTSR). 

2. For a comprehensive view of the final set of properties applied to a machine, considering ProvScheme-level settings, use Get-ProvVMConfigurationResultantSet.
For more details on [Get-ProvVMConfigurationResultantSet](https://developer-docs.citrix.com/en-us/citrix-daas-sdk/machinecreation/get-provvmconfigurationresultantset).
```powershell
Get-ProvVMConfigurationResultantSet -ProvisioningSchemeName $provisioningSchemeName -VMName $vmName
```
 The original version of this script is compatible with Citrix Virtual Apps and Desktops 7 2402 Long Term Service Release (LTSR).

## Below are the ways to update the provisioned virtual machine
**1. Set ServiceOffering on the provisioned virtual machine**
```powershell
Set-ProvVM -ProvisioningSchemeName "MyCatalog" -VMName "MyVM" -ServiceOffering "XDHyp:\Connections\my-connection-name\East US.region\serviceoffering.folder\Standard_B1ls.serviceoffering"
```

**2. Set CustomProperties on the provisioned virtual machine**
For instance, you can change the StorageType to Premium_LRS for a Virtual Machine. The properties related to the provisioned virtual machine are specific to the target hosting infrastructure. For more details, [refer](https://developer-docs.citrix.com/en-us/citrix-virtual-apps-desktops-sdk/current-release/MachineCreation/about_Prov_CustomProperties.html). If a property name already exists, its value is updated; otherwise, it is added. These properties are then merged with any previously set custom properties.
```powershell
$customProperties = @"
<CustomProperties xmlns="http://schemas.citrix.com/2014/xd/machinecreation" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">
<Property xsi:type="StringProperty" Name="StorageType" Value="Premium_LRS" />
</CustomProperties>
"@

Set-ProvVM -ProvisioningSchemeName "MyCatalog" -VMName "MyVM" -CustomProperties $customProperties
```

**3. Set MachineProfile on the provisioned virtual machine**
Updating the MachineProfile allows for the modification of the configuration on the virtual machine. The path to the template is specified to obtain hypervisor-specific settings applied to the virtual machine. Specific settings are associated with corresponding CustomProperties. In cases where properties exist in the MachineProfile but not in the CustomProperties, values from the template will be written to the CustomProperties.
```powershell
$machineProfile = "XDHyp:\HostingUnits\my-hostingunit-name\machineprofile.folder\myResourceGroupName.resourcegroup\myTemplateSpecName.templatespec\myTemplateSpecVersion.templatespecversion"
or 
$machineProfile = "XDHyp:\HostingUnits\my-hostingunit-name\machineprofile.folder\myResourceGroupName.resourcegroup\machineProfileVmName.vm"

Set-ProvVM -ProvisioningSchemeName "MyCatalog" -VMName "MyVM" -MachineProfile $machineProfile
```

**4. Clear the configuration on the provisioned virtual machine**
The RevertToProvSchemeConfiguration command is employed to clear all existing configuration for the specified machine. This operation is mutually exclusive with parameters that apply configuration settings.
```powershell
Set-ProvVM -ProvisioningSchemeName "MyCatalog" -VMName "MyVM" -RevertToProvSchemeConfiguration
```

## Errors that may occur during the execution of Set-ProvVM:
Failed to run Set-ProvVM if the specified ProvisioningSchemeName/VMName could not be found. Error message example "The specified ProvisioningScheme could not be located."

## Next steps
1. To retrieve information about a Provisioning virtual machine take the reference of sample scripts in Get ProvVM.
2. To remove a Provisioning virtual machine take the reference of sample scripts in Remove ProvVM.
3. To provision a new virtual machine take the reference of sample scripts in Add ProvVM.