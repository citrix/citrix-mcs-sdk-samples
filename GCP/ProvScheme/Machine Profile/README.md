# MachineProfile
## Overview
Using MCS Provisioning, provisioned VMs can inherit a configuration from a GCP instance (VM) or an instance template. When using New-ProvScheme or Set-ProvScheme, you should specify a new parameter: `-MachineProfile`. 
The Create-ProvScheme script also uses the New-BrokerCatalog command to enable the catalog to be managed from Studio. To learn more about New-BrokerCatalog, refer to the [New-BrokerCatalog documentation](https://developer-docs.citrix.com/en-us/citrix-virtual-apps-desktops-sdk/2311/Broker/New-BrokerCatalog.html). To learn more about Instance templates in GCP, refer to the [GCP documentation](https://cloud.google.com/compute/docs/instance-templates).

## How to use MachineProfile
To configure the machine profile through PowerShell, use the `-MachineProfile` parameter for the New-ProvScheme operation. The MachineProfile parameter is a string containing a Citrix inventory item path. Currently, only 2 inventory types are supported as MachineProfile:
1. **Instance**: The MachineProfile points to a VM that exists in GCP. For example:
```powershell
$machineProfile = "XDHyp:\HostingUnits\$hostingUnitName\$machineProfileVmName.vm"
```
2. **Instance Template**: The MachineProfile points to a GCP instance template. For example:
```powershell
$machineProfile = "XDHyp:\HostingUnits\$hostingUnitName\instanceTemplates.folder\$instanceTemplateName.template"
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

You can also change the MachineProfile configuration on an existing catalog using the Set-ProvScheme command. The updated machine profile will be applicable to new machines post operation, not to the existing machines. You can update existing VMs in the catalog using the Set-ProvVmUpdateTimeWindow command. Examples are provided in the Set-MachineProfile-Instance.ps1 and Set-MachineProfile-InstanceTemplate.ps1 scripts.

## Troubleshooting Create ProvScheme -
If, for some reason, New-ProvScheme fails, you might see an error message from the New-BrokerCatalog command "New-BrokerCatalog : Invalid provisioning scheme". This error message indicates that provScheme was never created hence the ProvisioningSchemeId parameter is null. To understand what caused the failure in New-ProvScheme, you can try executing the script without the New-BrokerCatalog command. Below are some common errors thrown by New-ProvScheme and their possible reasons:
* If the Identity pool is invalid, you would see an error "An exception occurred.  The associated message was Identity Pool could not be located".
* If Hosting unit is invalid, you would see an error "Path XDHyp:\HostingUnits\HostingUnitName\machine-profile-vm.vm is not valid: Cannot find path 'XDHyp:\HostingUnits\HostingUnitName' because it does not exist.".
* There are some other scenarios where you would see that task is completed with Status "Finished" but there are Terminating errors indicating various reasons like below -
	* Terminating error "master image was not found" - indicates master image snapshot was not found in the specified project.
	* Terminating error is "Network does not exist." - indicates either specified VPC or subnet is invalid.
	* Other terminating errors are self-explanatory e.g. "Machine 'machine-vm' in region 'region' in Project with projectId 'my-project' not found" or "No Template named 'machine-profile-template' was found in the Templates of project ID 'my-project'".
	
## Troubleshooting Set ProvScheme -
* If the provisioningSchemeName is invalid, you would see an error "The specified ProvisioningScheme could not be located."
* If MachineProfile is a VM but is invalid, you would see an error "Machine 'machprof-vm' in region 'region' in Project with projectId 'project-id' not found".
* If MachineProfile is an instance template but is invalid, you would see an error "No Template named 'test-template-2-invalid' was found in the Templates of project ID 'haipham'".

Documentation:  
https://docs.citrix.com/en-us/citrix-daas/install-configure/machine-catalogs-create/create-machine-catalog-gcp#create-a-machine-catalog-with-machine-profile-as-an-instance-template

https://docs.citrix.com/en-us/citrix-daas/install-configure/machine-catalogs-create/create-machine-catalog-gcp#create-a-machine-catalog-using-a-machine-profile
