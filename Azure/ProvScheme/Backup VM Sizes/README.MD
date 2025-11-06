# Backup VM SKU List Support

## Table of Contents

- [Overview](#overview)
- [How It Works](#how-it-works)
- [Available Scripts](#available-scripts)
  - [Creating New Provisioning Schemes](#creating-new-provisioning-schemes)
  - [Updating Existing Provisioning Schemes](#updating-existing-provisioning-schemes)
  - [Updating Individual VMs](#updating-individual-vms)
- [Prerequisites](#prerequisites)

## Overview

Public clouds can run out of capacity for specific VM sizes. When Azure lacks capacity, MCS automatically falls back to a preconfigured list of backup VM sizes. This curated list, tailored by the customer to their workload requirements, increases the likelihood that one of these sizes has sufficient capacity to boot on Power On or Resume operations.

## How It Works

The workflow is as follows:

1. User issues a PowerOn or Resume command through Citrix Studio.

2. MCS calls Azure and monitors for exceptions. If the error contains codes ‘QuotaExceeded’, ‘AllocationFailed’, ‘ZonalAllocationFailed’, or ‘SKUNotAvailable’, MCS tries the backup sizes sequentially until the VM starts and runs successfully. If all sizes fail, the power action is marked as failed.
The VM remains configured on the backup size until a shutdown or hibernate request occurs.

3. On the next PowerOn or Resume, MCS attempts to restore the primary size configured on the Catalog via the ServiceOffering property or MachineProfile. If the primary size fails again, MCS repeats the backup size fallback as described above.

*Note*: Some configuration changes, such as switching from a Spot VM to a Regular priority VM, require deleting and recreating the VM.

## Available Scripts

### Creating New Provisioning Schemes

**Regular Priority VMs Only**

[Create-WithBackupVmConfiguration.ps1](Create-WithBackupVmConfiguration.ps1) - Creates a new provisioning scheme with backup VM configuration using only Regular priority VMs.

```powershell
New-ProvScheme -ProvisioningSchemeName "demo" `
  -MasterImageVM "XDHyp:\HostingUnits\azure-zones\image.folder\TestResourceGroup.resourcegroup\TestSnapshot.snapshot" `
  -MachineProfile "XDHyp:\HostingUnits\azure-zones\machineprofile.folder\TestResourceGroup.resourcegroup\TestMachineProfileVM.vm" `
  -CustomProperties "<CustomProperties xmlns=`"http://schemas.citrix.com/2014/xd/machinecreation`" xmlns:xsi=`"http://www.w3.org/2001/XMLSchema-instance`"> <Property xsi:type=`"StringProperty`" Name=`"BackupVmConfiguration`" Value=`"[{&quot;ServiceOffering&quot;:&quot;Standard_D2as_v4&quot;},{&quot;ServiceOffering&quot;:&quot;Standard_D2s_v3&quot;}]`"/></CustomProperties>"
```

**Mixed Regular and Spot Priority VMs**

[Create-WithBackupVmConfigurationWithSpot.ps1](Create-WithBackupVmConfigurationWithSpot.ps1) - Creates a new provisioning scheme with backup VM configuration using both Regular and Spot priority VMs.

```powershell
New-ProvScheme -ProvisioningSchemeName "demo" `
  -MasterImageVM "XDHyp:\HostingUnits\azure-zones\image.folder\TestResourceGroup.resourcegroup\TestSnapshot.snapshot" `
  -MachineProfile "XDHyp:\HostingUnits\azure-zones\machineprofile.folder\TestResourceGroup.resourcegroup\TestMachineProfileVM.vm" `
  -CustomProperties "<CustomProperties xmlns=`"http://schemas.citrix.com/2014/xd/machinecreation`" xmlns:xsi=`"http://www.w3.org/2001/XMLSchema-instance`"> <Property xsi:type=`"StringProperty`" Name=`"BackupVmConfiguration`" Value=`"[{&quot;ServiceOffering&quot;:&quot;Standard_D2as_v4&quot;, &quot;Type&quot;: &quot;Spot&quot;}, {&quot;ServiceOffering&quot;:&quot;Standard_D2as_v4&quot;,&quot;Type&quot;: &quot;Regular&quot;},{&quot;ServiceOffering&quot;: &quot;Standard_D2s_v3&quot;, &quot;Type&quot;: &quot;Spot&quot;}]`"/></CustomProperties>"
```

### Updating Existing Provisioning Schemes

**Regular Priority VMs Only**

[Set-ProvSchemeBackupVmConfiguration.ps1](Set-ProvSchemeBackupVmConfiguration.ps1) - Updates backup VM configuration on existing provisioning schemes using only Regular priority VMs.

```powershell
Set-ProvScheme -ProvisioningSchemeName "demo" `
  -CustomProperties "<CustomProperties xmlns=`"http://schemas.citrix.com/2014/xd/machinecreation`" xmlns:xsi=`"http://www.w3.org/2001/XMLSchema-instance`"> <Property xsi:type=`"StringProperty`" Name=`"BackupVmConfiguration`" Value=`"[{&quot;ServiceOffering&quot;:&quot;Standard_D2as_v4&quot;}, {&quot;ServiceOffering&quot;:&quot;Standard_D2as_v4&quot;},{&quot;ServiceOffering&quot;: &quot;Standard_D2s_v3&quot;}]`"/></CustomProperties>"
```

**Mixed Regular and Spot Priority VMs**

[Set-ProvSchemeBackupVmConfigurationWithSpot.ps1](Set-ProvSchemeBackupVmConfigurationWithSpot.ps1) - Updates backup VM configuration on existing provisioning schemes using both Regular and Spot priority VMs.

```powershell
Set-ProvScheme -ProvisioningSchemeName "demo" `
  -CustomProperties "<CustomProperties xmlns=`"http://schemas.citrix.com/2014/xd/machinecreation`" xmlns:xsi=`"http://www.w3.org/2001/XMLSchema-instance`"> <Property xsi:type=`"StringProperty`" Name=`"BackupVmConfiguration`" Value=`"[{&quot;ServiceOffering&quot;:&quot;Standard_D2as_v4&quot;, &quot;Type&quot;: &quot;Spot&quot;}, {&quot;ServiceOffering&quot;:&quot;Standard_D2as_v4&quot;,&quot;Type&quot;: &quot;Regular&quot;},{&quot;ServiceOffering&quot;: &quot;Standard_D2s_v3&quot;, &quot;Type&quot;: &quot;Spot&quot;}]`"/></CustomProperties>"
```

### Updating Existing VMs

**Regular Priority VMs Only**

[Set-ProvVMBackupVmConfiguration.ps1](Set-ProvVMBackupVmConfiguration.ps1) - Updates backup VM configuration on individual existing VMs using only Regular priority VMs.

```powershell
Set-ProvVM -ProvisioningSchemeName "demo" -VMName "test-vm" `
  -CustomProperties "<CustomProperties xmlns=`"http://schemas.citrix.com/2014/xd/machinecreation`" xmlns:xsi=`"http://www.w3.org/2001/XMLSchema-instance`"> <Property xsi:type=`"StringProperty`" Name=`"BackupVmConfiguration`" Value=`"[{&quot;ServiceOffering&quot;:&quot;Standard_D2as_v4&quot;}, {&quot;ServiceOffering&quot;:&quot;Standard_D2as_v4&quot;},{&quot;ServiceOffering&quot;: &quot;Standard_D2s_v3&quot;}]`"/></CustomProperties>"
```

**Mixed Regular and Spot Priority VMs**

[Set-ProvVMBackupVmConfigurationWithSpot.ps1](Set-ProvVMBackupVmConfigurationWithSpot.ps1) - Updates backup VM configuration on individual existing VMs using both Regular and Spot priority VMs.

```powershell
Set-ProvVM -ProvisioningSchemeName "demo" -VMName "test-vm" `
  -CustomProperties "<CustomProperties xmlns=`"http://schemas.citrix.com/2014/xd/machinecreation`" xmlns:xsi=`"http://www.w3.org/2001/XMLSchema-instance`"> <Property xsi:type=`"StringProperty`" Name=`"BackupVmConfiguration`" Value=`"[{&quot;ServiceOffering&quot;:&quot;Standard_D2as_v4&quot;, &quot;Type&quot;: &quot;Spot&quot;}, {&quot;ServiceOffering&quot;:&quot;Standard_D2as_v4&quot;,&quot;Type&quot;: &quot;Regular&quot;},{&quot;ServiceOffering&quot;: &quot;Standard_D2s_v3&quot;, &quot;Type&quot;: &quot;Spot&quot;}]`"/></CustomProperties>"
```

## Useful Links

**SDK Commands:**

1. [Set-ProvScheme](https://developer-docs.citrix.com/en-us/citrix-daas-sdk/machinecreation/set-provscheme)
2. [Set-ProvVM](https://developer-docs.citrix.com/en-us/citrix-daas-sdk/machinecreation/set-provvm)
3. [Set-ProvVmUpdateTimeWindow](https://developer-docs.citrix.com/en-us/citrix-daas-sdk/machinecreation/set-provvmupdatetimewindow)


## Prerequisites

Before setting up the `BackupVmConfiguration` custom property, ensure the following requirements are met (failure to meet any requirement will result in an error):

### Basic Requirements

1. **Machine Profile Required**: This feature is only supported when a machine profile is configured in the catalog
2. **VM Type Values**: `Type` parameter is optional and accepts `Spot` or `Regular` (defaults to `Regular` if not specified)
3. **Unique Combinations**: Each combination of `ServiceOffering` and `Type` must be unique in the backup list
4. **Regional Quota**: Sufficient Azure quota must be available for all backup VM sizes
5. **Network Interfaces**: Number of network interfaces must not exceed the maximum supported by each backup VM size

### Feature Compatibility Requirements

Backup VM sizes must be compatible with all currently enabled catalog features and custom properties:

- **Host Groups**: If dedicated hosts are used, the host group must support the backup VM size
- **Ephemeral OS Disk**: If enabled, backup VM sizes must support ephemeral disks
- **Premium Storage**: If enabled, backup VM sizes must support premium storage
- **Accelerated Networking**: If enabled in MachineProfile, backup VM sizes must support accelerated networking
- **Disk Encryption at Host**: If enabled in MachineProfile, backup VM sizes must support encryption at host
- **Temporary Storage**: If primary VM size supports temporary disk, backup sizes must also support temporary disks
- **Hyper-V Generation**: Backup VM sizes must be compatible with the VM generation (Gen 1 or Gen 2) of the master image
- **Hibernation**: If enabled in MachineProfile, backup VM sizes must support hibernation
- **Trusted Launch**: If enabled in MachineProfile, backup VM sizes must support Trusted Launch
- **Confidential VMs**: If enabled in MachineProfile, backup VM sizes must support Confidential VMs
- **Disk Controller Type**: Backup VM sizes must support the same disk controller type (SCSI or NVMe) as the primary VM
