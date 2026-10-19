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

[Create-WithBackupVmConfiguration.ps1](Create-WithBackupVmConfiguration.ps1) - Creates a new provisioning scheme with backup VM configuration using only Regular priority VMs.

```powershell
$customProperties = @'
{
    "BackupVmConfiguration": [{"InstanceType": "t3.medium", "MarketType": "spot"}, {"InstanceType": "t3.large"}]
}
'@

New-ProvScheme -ProvisioningSchemeName "demo" `
  -CleanOnBoot:$false `
  -HostingUnitName "demo-hu" `
  -IdentityPoolName "demo-ip" `
  -MasterImageVM "XDHyp:\HostingUnits\demo-hu\demo-master-image (ami-12345678910).template" `
  -MachineProfile "XDHyp:\HostingUnits\demo-hu\us-east-1a\Demo Machine Profile VM (i-012345678910).vm" `
  -CustomProperties $customProperties
```

### Updating Existing Provisioning Schemes

[Update-ProvScheme-WithBackupVmConfiguration.ps1](Update-ProvScheme-WithBackupVmConfiguration.ps1) - Updates backup VM configuration on existing provisioning schemes.

```powershell
$customProperties = @'
{
    "BackupVmConfiguration": [{"InstanceType": "t3.medium", "MarketType": "spot"}, {"InstanceType": "t3.large"}]
}
'@

Set-ProvScheme -ProvisioningSchemeName "demo" -CustomProperties $customProperties
```

### Updating Individual VMs

[Update-ProvSchemeAndVMs-WithBackupVmConfiguration.ps1](Update-ProvSchemeAndVMs-WithBackupVmConfiguration.ps1) - Apply backup VM configuration changes to the VMs on a provisioning scheme via service windows.

```powershell
$customProperties = @'
{
    "BackupVmConfiguration": [{"InstanceType": "t3.medium", "MarketType": "spot"}, {"InstanceType": "t3.large"}]
}
'@

$newProvSchemeVersion = New-ProvSchemeVersion -ProvisioningSchemeName $provisioningSchemeName -CustomProperties $customProperties

New-ProvSchemeHardwareUpdate -ProvisioningSchemeVersion $newProvSchemeVersion.ProvisioningSchemeVersionCreated -StartsNow -AllVMs -MaxDurationInMinutes 100 -ProvisioningSchemeName $provisioningSchemeName
```

## Useful Links

**SDK Commands:**

1. [Set-ProvScheme](https://developer-docs.citrix.com/en-us/citrix-daas-sdk/machinecreation/set-provscheme)
2. [New-ProvSchemeVersion](https://developer-docs.citrix.com/en-us/citrix-daas-sdk/machinecreation/new-provschemeversion)
3. [New-ProvSchemeHardwareUpdate](https://developer-docs.citrix.com/en-us/citrix-daas-sdk/machinecreation/new-provschemehardwareupdate)

## Prerequisites

Before setting up the `BackupVmConfiguration` custom property, ensure the following requirements are met (failure to meet any requirement will result in an error):
1. The instance type t2.small in the BackupVmConfiguration is not supported
2. The Backup SKU cannot be the same as the Primary SKU (t3.micro)

### Basic Requirements

1. **Regional Quota**: Sufficient AWS quota must be available for all backup Service Offerings

