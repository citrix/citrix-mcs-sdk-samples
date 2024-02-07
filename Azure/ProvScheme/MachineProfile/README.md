# MachineProfile
## Overview
Using MCS Provisioning, provisioned VMs can inherit a configuration from an Azure VM or an Azure template spec. When using New-ProvScheme or Set-ProvScheme, you will specify a new parameter: `-MachineProfile`

To learn more about Azure Template Specs, refer to Azure's documentation: https://learn.microsoft.com/en-us/azure/azure-resource-manager/templates/template-specs?tabs=azure-powershell

## Leading Practices
We suggest using MachineProfile for your MCS catalogs. This will allow you to take advantage of more MCS features, as many new features require MachineProfile. 

## How to use MachineProfile
To configure Machine through PowerShell, use the `-MachineProfile` parameter available with the New-ProvScheme operation. The MachineProfile parameter is a string containing a Citrix inventory item path. Currently, only 2 inventory types are supported for the MachineProfile source:
1. **VM**: The MachineProfile points to a VM that exists in Azure. For example:
```powershell
$machineProfile = "XDHyp:\HostingUnits\$hostingUnitName\machineprofile.folder\$resourceGroupName.resourcegroup\$machineProfileVmName.vm"
```
2. **Template Spec**: The MachineProfile points to a version of an Azure Template Spec. For example:
```powershell
$machineProfile = "XDHyp:\HostingUnits\$hostingUnitName\machineprofile.folder\$resourceGroupName.resourcegroup\$templateSpecName.templatespec\$templateSpecVersion.templatespecversion"
```

When using New-ProvScheme, specify the `-MachineProfile` parameter:
```powershell
New-ProvScheme -CleanOnBoot:$isCleanOnBoot 
-ProvisioningSchemeName $provisioningSchemeName 
-HostingUnitName $hostingUnitName 
-IdentityPoolName $identityPoolName 
-InitialBatchSizeHint $numberOfVms 
-MasterImageVM $masterImageVm 
-NetworkMapping $networkMapping 
-CustomProperties $customProperties 
-MachineProfile $machineProfile
```

Once the MachineProfile is added to the catalog, you can optionally delete it from Azure Portal. You can also change the MachineProfile configuration on an existing catalog using the Set-ProvScheme command. You can update existing VMs in the catalog using the Set-ProvVmUpdateTimeWindow command. An example is provided in the Set-MachineProfile-VmSource.ps1 script. 

**Note**: You can use Set-ProvScheme to convert your non-MachineProfile based catalogs to MachineProfile based. However, you cannot convert a MachineProfile based catalog to a non-MachineProfile based catalog. 

## Common error cases
If a user enters an invalid or unsupported MachineProfile configuration, these errors will be caught early when running New-ProvScheme and will return helpful error messages. Some common error cases include:

1. If a template spec version contains Parameters, the user will receive an error: "Error: Using Parameters in the MachineProfile (input from the Azure template spec) is not allowed. When exporting template spec from a virtual machine, make sure you uncheck the "Include parameter" checkbox."
2. If a template spec version does not contain a VM and a NIC, the user will receive an error. For example: \
	a. "Error: No virtual machine found in the MachineProfile (input from the Azure template spec)." \
	b. "Error: No network interface found in the MachineProfile (input from the Azure template spec)."
3. If a user attempts to use MachineProfile without managed disks, they will receive an error: "Machine profile is not supported for unmanaged disk."

Documentation:  
https://docs.citrix.com/en-us/citrix-daas/install-configure/machine-catalogs-create/create-machine-catalog-citrix-azure.html#use-machine-profile-property-values 

https://docs.citrix.com/en-us/citrix-daas/install-configure/machine-catalogs-create/create-machine-catalog-citrix-azure.html#create-an-azure-template-spec

[Documentation]: < https://docs.citrix.com/en-us/citrix-daas/install-configure/machine-catalogs-create/create-machine-catalog-citrix-azure.html#use-machine-profile-property-values >