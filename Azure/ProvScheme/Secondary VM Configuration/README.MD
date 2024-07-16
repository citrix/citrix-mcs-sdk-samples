# Backup VM SKU list Support
## Overview
Public clouds can sometimes run out of capacity for a specific VM size. Also, if you use Azure Spot VMs, then the VMs are evicted at any time based on Azure’s capacity needs. In such a case of insufficient capacity on Azure or a Spot VM power-on failure, MCS now falls back on the backup VM sizes. You can provide a list of backup VM sizes using a custom property _BackupVmConfiguration_. MCS tries the backup VM sizes in the order that is provided by you in the list. If MCS fails on all backup VM sizes provided, you get an error message. This feature is supported only for a catalog that uses a machine profile and is applicable to both persistent and non-persistent MCS machine catalogs. This feature is currently supported only for Azure environments. 

The backup configuration is currently triggered in the following scenarios:
1. MCS now offers Azure Spot VM provisioning, allowing you to take advantage of unused capacity at significant cost saving. When Spot VMs are currently unavailable for the current ServiceOffering or the Spot price rises beyond what is specified as the max price in a billing profile, the VM can fail to Power On.
2. When the available cores for a particular Service Offering in a region are lower than what you have requested, it can also lead to power on failures.

In the above scenarios, instead of failing, MCS will immediately try the list of backup VM sizes to find one that will work for the current power action.

## How to configure backup configuration
[Create-WithBackupVmConfiguration.ps1](Create-WithBackupVmConfiguration.ps1) has an example script on how to use the custom property _BackupVmConfiguration_ on new Provisioning Schemes.
```
New-ProvScheme -ProvisioningSchemeName "demo" -MasterImageVM "XDHyp:\HostingUnits\azure-zones\image.folder\TestResourceGroup.resourcegroup\TestSnapshot.snapshot" -MachineProfile "XDHyp:\HostingUnits\azure-zones\machineprofile.folder\TestResourceGroup.resourcegroup\TestMachineProfileVM.vm" -CustomProperties "<CustomProperties xmlns=`"http://schemas.citrix.com/2014/xd/machinecreation`" xmlns:xsi=`"http://www.w3.org/2001/XMLSchema-instance`"> <Property xsi:type=`"StringProperty`" Name=`"BackupVmConfiguration`" Value=`"[{'ServiceOffering':'Standard_D2as_v4', 'Type': 'Spot'}, {'ServiceOffering':'Standard_D2as_v4','Type': 'Regular'},{'ServiceOffering': 'Standard_D2s_v3', 'Type': 'Spot'}]`"/></CustomProperties>"
```

[Set-BackupVmConfiguration.ps1](Set-BackupVmConfiguration.ps1) has an example script on how to use the custom property _BackupVmConfiguration_ on existing Provisioning Schemes.
```
Set-ProvScheme -ProvisioningSchemeName "demo" -CustomProperties "<CustomProperties xmlns=`"http://schemas.citrix.com/2014/xd/machinecreation`" xmlns:xsi=`"http://www.w3.org/2001/XMLSchema-instance`"> <Property xsi:type=`"StringProperty`" Name=`"BackupVmConfiguration`" Value=`"[{'ServiceOffering':'Standard_D2as_v4', 'Type': 'Spot'}, {'ServiceOffering':'Standard_D2as_v4','Type': 'Regular'},{'ServiceOffering': 'Standard_D2s_v3', 'Type': 'Spot'}]`"/></CustomProperties>"
```

## Prerequisites to setting up _BackupVmConfiguration_ custom property:
(If any of the following is not meet, we will through out an error.)
<ol>
<li> It is only supported when the machine profile is in use.</li>
<li> Type is optional and can have one of two values: Spot and Regular. When not specified will default to Regular</li>
<li> A combination of ServiceOffering and Type should be unique in the list</li>
<li> Regional Quota should have enough cores for ServiceOffering</li>
<li> Network interfaces count should be no greater than Max Network Interfaces allowed on a ServiceOffering</li>
<li> ServiceOfferings used in this BackupVmConfiguration list should be compatible with currently used custom properties and other catalog features such as:
	<ul>
	<li> Host Groups: If dedicated hosts are being used, then the hosts in the host group must support the ServiceOffering</li>
	<li> Ephemeral OS Disk: If Ephemeral disk is enabled in custom properties, the ServiceOffering must support Ephemeral disks</li>
	<li> Premium Storage: If Premium storage is enabled in custom properties, the ServiceOffering must support Premium storage</li>
	<li> Accelerated Networking: If Accelerated Networking is enabled in MachineProfile, the ServiceOffering must support Accelerated Networking</li>
	<li> DiskEncryptionAtHost: If Encryption at Host is enabled in MachineProfile, the ServiceOffering must support Encryption at Host</li>
	<li> Temporary Storage: If the primary VM size specified in the ServiceOffering parameter supports Temporary disk, then the Service Offering input in the Backup list must also support Temporary disks</li>
	<li> HyperVGeneration: The selected ServiceOffering must be compatible with the VM generation (Generation 1 or 2) on the resource specified in the MasterImageVM parameter </li>
	<li> Hibernation: If Hibernation is enabled in MachineProfile, the ServiceOffering must support Hibernation </li>
	<li> TrustedLaunch: If TrustedLaunch is enabled in MachineProfile, the ServiceOffering must support TrustedLaunch</li>
	<li> Confidential VMs: If Confidential VM is enabled in MachineProfile, the ServiceOffering must support Confidential VM</li>
	</ul>
</li>
</ol>



