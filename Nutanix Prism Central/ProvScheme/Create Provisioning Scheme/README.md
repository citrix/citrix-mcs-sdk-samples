# Add Provisioning Scheme

This page explains the use of the Create-ProvScheme.ps1 script.

This script creates a Provisioning Scheme.

## Using the script

Get the ID (Guid) of Prism Central Cluster where you wish to provision machines, For example:
```powershell
GET-ITEM XDHyp:\HostingUnits\myHostingUnit\Clusters.folder\cluster01.cluster | ft FullName, Id

FullName                       Id
--------                       --
cluster01.cluster 00001111-2222-3333-4444-555556666666
```

### Parameters

- Required parameters:
    - `ProvisioningSchemeName`: Name of the new provisioning scheme
    - `ProvisioningSchemeType`: The Provisioning Scheme Type
    - `HostingUnitName`:        Name of the hosting unit used
    - `IdentityPoolName`:       Name of the Identity Pool used
    - `NetworkMapping`:         Specifies how the attached NICs are mapped to networks
    - `CustomProperties`:       Used to provide `ClusterId`(as GUID), and `CPUCores`(Cores per CPU, overrides the setting in master image or machine profile Template Version) values
    - `MasterImageVM`:          Path to Prism Central Template Version
- Optional Parameters:
    - `MachineProfile`:         Path to Prism Central Template Version for hardware specification
    - `VMCpuCount`:             Number of vCPUs (this will override the setting in master image or machine profile Template Version)
    - `VMMemoryMB`:             VM memory in MB (this will override the setting in master image or machine profile Template Version)
    - `InitialBatchSizeHint`:   The number of VMs that will be initially added to the Provisioning Scheme
    - `CleanOnBoot`:            Reset VM's to their initial state on each power on
    - `Scope`:                  Administration scopes for the identity pool
    - `RunAsynchronously`:      Run command asynchronously, returns ProvTask ID

**Important:** The MachineProfile must have at least one NIC, and the number of NICs in the MachineProfile must match the subnet mappings in NetworkMapping.

The total number of NICs for the template version can be obtained from the AdditionalData of its inventory item using the following:
```powershell
$tv = Get-Item -Path "XDHyp:\HostingUnits\myHostingUnit\Templates.folder\HardwareProfile.template\hardwarespec.templateversion"
$tv.AdditionalData.TotalNics
```

**Note:** When using `MachineProfile`, hardware properties are captured from the Machine Profile template version. The `OS Disk`, `vTPM`, and `Secure Boot` properties are always captured from the master image, even when a machine profile is used. Command-line parameters like `VMCpuCount`, `VMMemoryMB`, and `CPUCores` in `CustomProperties` take precedence over values in the Machine Profile.

### Example
The script can be executed like the example below:
```powershell
# Setting up customProperties as a variable for better readability
$customProperties = @"
    <CustomProperties xmlns="http://schemas.citrix.com/2014/xd/machinecreation">
        <StringProperty Name="ClusterId" Value="00001111-2222-3333-4444-555556666666"/>
        <StringProperty Name="CPUCores" Value="1"/>
    </CustomProperties>
"@

# Create a non-persistent Provisioning Scheme
.\Create-ProvScheme.ps1 `
    -ProvisioningSchemeName "myProvScheme" `
    -ProvisioningSchemeType "MCS" `
    -HostingUnitName "myHostingUnit" `
    -IdentityPoolName "myIdp" `
    -NetworkMapping @{"0"="XDHyp:\HostingUnits\myHostingUnit\Clusters.folder\cluster01.cluster\Network-A.network"} `
    -CustomProperties $customProperties `
    -MasterImageVM "XDHyp:\HostingUnits\myHostingUnit\Templates.folder\CitrixVda.template\win2022-vda-2411.templateversion" `
    -InitialBatchSizeHint 1 `
    -CleanOnBoot `
    -Scope @() `
    -RunAsynchronously

# Create a persistent Provisioning Scheme with changes saved locally on the device and override CPU and Memory settings
.\Create-ProvScheme.ps1 `
    -ProvisioningSchemeName "myProvScheme" `
    -ProvisioningSchemeType "MCS" `
    -HostingUnitName "myHostingUnit" `
    -IdentityPoolName "myIdp" `
    -NetworkMapping @{"0"="XDHyp:\HostingUnits\myHostingUnit\Clusters.folder\cluster01.cluster\Network-A.network"} `
    -CustomProperties $customProperties `
    -MasterImageVM "XDHyp:\HostingUnits\myHostingUnit\Templates.folder\CitrixVda.template\win2022-vda-2411.templateversion" `
    -VMCpuCount 3 `
    -VMMemoryMB 6144 `
    -InitialBatchSizeHint 1 `
    -Scope @() `
    -RunAsynchronously

# Create a Provisioning Scheme using Machine Profile for hardware specification
.\Create-ProvScheme.ps1 `
    -ProvisioningSchemeName "myProvScheme" `
    -ProvisioningSchemeType "MCS" `
    -HostingUnitName "myHostingUnit" `
    -IdentityPoolName "myIdp" `
    -NetworkMapping @{"0"="XDHyp:\HostingUnits\myHostingUnit\Clusters.folder\cluster01.cluster\Network-A.network"} `
    -CustomProperties $customProperties `
    -MasterImageVM "XDHyp:\HostingUnits\myHostingUnit\Templates.folder\CitrixVda.template\win2022-vda-2411.templateversion" `
    -MachineProfile "XDHyp:\HostingUnits\myHostingUnit\Templates.folder\HardwareProfile.template\hardwarespec.templateversion" `
    -InitialBatchSizeHint 1 `
    -CleanOnBoot `
    -Scope @() `
    -RunAsynchronously

# Create a Provisioning Scheme using Machine Profile with overridden hardware specification
.\Create-ProvScheme.ps1 `
    -ProvisioningSchemeName "myProvScheme" `
    -ProvisioningSchemeType "MCS" `
    -HostingUnitName "myHostingUnit" `
    -IdentityPoolName "myIdp" `
    -NetworkMapping @{"0"="XDHyp:\HostingUnits\myHostingUnit\Clusters.folder\cluster01.cluster\Network-A.network"} `
    -CustomProperties $customProperties `
    -MasterImageVM "XDHyp:\HostingUnits\myHostingUnit\Templates.folder\CitrixVda.template\win2022-vda-2411.templateversion" `
    -MachineProfile "XDHyp:\HostingUnits\myHostingUnit\Templates.folder\HardwareProfile.template\hardwarespec.templateversion" `
    -VMCpuCount 4 `
    -VMMemoryMB 8192 `
    -InitialBatchSizeHint 1 `
    -CleanOnBoot `
    -Scope @() `
    -RunAsynchronously
```