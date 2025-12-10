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

Public clouds can run out of capacity for specific Service Offerings. When AWS lacks capacity, MCS automatically falls back to a preconfigured list of backup Service Offerings. This curated list, tailored by the customer to their workload requirements, increases the likelihood that one of these Service Offerings has sufficient capacity to boot on Power On or Resume operations.

## How It Works

The workflow is as follows:

1. User issues a PowerOn or Resume command through Citrix Studio.

2. MCS calls AWS and monitors for exceptions. If the error contains ‘Resource Not Available’, MCS tries the backup Service Offerings sequentially until the VM starts and runs successfully. If all Service Offerings fail, the power action is marked as failed.
The VM remains configured on the backup Service Offering until a shutdown or hibernate request occurs.

3. On the next PowerOn or Resume, MCS attempts to restore the primary Service Offering configured on the Catalog via the ServiceOffering property or MachineProfile. If the primary Service Offering fails again, MCS repeats the backup Service Offering fallback as described above.

*Note*: Some configuration changes, such as switching from a Spot VM to a Regular priority VM, require deleting and recreating the VM. Also, make sure the primary service offering is not in the secondary service offering list. Including the primary Service Offering in the secondary list will cause a failure.

## Available Scripts

### Creating New Provisioning Schemes

**Regular Priority VMs Only**

[Create-WithBackupVmConfiguration.ps1](Create-WithBackupVmConfiguration.ps1) - Creates a new provisioning scheme with backup VM configuration using only Regular priority VMs.

```powershell
New-ProvScheme -ProvisioningSchemeName "demo" `
  -CleanOnBoot:$false `
  -HostingUnitName "demo-hu" `
  -IdentityPoolName "demo-ip" `
  -MasterImageVM "XDHyp:\HostingUnits\demo-hu\demo-master-image (ami-12345678910).template" `
  -MachineProfile "XDHyp:\HostingUnits\demo-hu\us-east-1a\Demo Machine Profile VM (i-012345678910).vm" `
  -CustomProperties "BackupVmConfiguration,t2.small|t2.large|t3.small|t3.large"
```

**Mixed Regular and Spot Priority VMs**

[Create-WithBackupVmConfigurationWithSpot.ps1](Create-WithBackupVmConfigurationWithSpot.ps1) - Creates a new provisioning scheme with backup VM configuration using both Regular and Spot priority VMs.

```powershell
New-ProvScheme -ProvisioningSchemeName "demo" `
  -CleanOnBoot:$false `
  -HostingUnitName "demo-hu" `
  -IdentityPoolName "demo-ip" `
  -MasterImageVM "XDHyp:\HostingUnits\demo-hu\demo-master-image (ami-12345678910).template" `
  -MachineProfile "XDHyp:\HostingUnits\demo-hu\us-east-1a\Demo Machine Profile VM (i-012345678910).vm" `
  -CustomProperties "BackupVmConfiguration,t2.small|t2.large|t3.small:Spot|t3.large:Spot"
```

### Updating Existing Provisioning Schemes

**Regular Priority VMs Only**

[Set-ProvSchemeBackupVmConfiguration.ps1](Set-ProvSchemeBackupVmConfiguration.ps1) - Updates backup VM configuration on existing provisioning schemes using only Regular priority VMs.

```powershell
Set-ProvScheme -ProvisioningSchemeName "demo" `
  -CustomProperties "BackupVmConfiguration,t2.small|t2.large|t3.small|t3.large"
```

**Mixed Regular and Spot Priority VMs**

[Set-ProvSchemeBackupVmConfigurationWithSpot.ps1](Set-ProvSchemeBackupVmConfigurationWithSpot.ps1) - Updates backup VM configuration on existing provisioning schemes using both Regular and Spot priority VMs.

```powershell
Set-ProvScheme -ProvisioningSchemeName "demo" `
  -CustomProperties "BackupVmConfiguration,t2.small|t2.large|t3.small:Spot|t3.large:Spot"
```

## Useful Links

**SDK Commands:**

1. [Set-ProvScheme](https://developer-docs.citrix.com/en-us/citrix-daas-sdk/machinecreation/set-provscheme)

## Prerequisites

Before setting up the `BackupVmConfiguration` custom property, ensure the following requirements are met (failure to meet any requirement will result in an error):

### Basic Requirements

1. **Regional Quota**: Sufficient AWS quota must be available for all backup Service Offerings

