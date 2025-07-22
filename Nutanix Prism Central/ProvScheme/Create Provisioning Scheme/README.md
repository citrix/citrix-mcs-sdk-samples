# Add Provisioning Scheme

This page explains the use of the Create-ProvScheme.ps1 script.

This script creates a Provisioning Scheme.

## Using the script

Get the ID (Guid) of Prism Central Cluster where you wish to provsion machines, For example:
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
    - `CustomProperties`:       Used to provide `ClusterId`(as GUID), and `CPUCores`(Cores per CPU) values
    - `MasterImageVM`:          Path to Prism Central Template Version
- Optional Parameters:
    - `VMCpuCount`:             Number of vCPUs (this will override the setting in Template Version)
    - `VMMemoryMB`:             VM memory in MB (this will override the setting in Template Version)
    - `InitialBatchSizeHint`:   The number of VMs that will be intially added to the Provisioning Scheme
    - `CleanOnBoot`:            Reset VM's to their initial state on each power on
    - `Scope`:                  Administration scopes for the identity pool
    - `RunAsynchronously`:      Run command asynchronously, returns ProvTask ID
    - `PersistUserChanges`:     User data persistence method

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
    -NetworkMapping @{"0"="XDHyp:\HostingUnits\myHostingUnit\Clusters.folder\cluster01.cluster\NetworkA.network"} `
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
    -NetworkMapping @{"0"="XDHyp:\HostingUnits\myHostingUnit\Clusters.folder\cluster01.cluster\NetworkA.network"} `
    -CustomProperties $customProperties `
    -MasterImageVM "XDHyp:\HostingUnits\myHostingUnit\Templates.folder\CitrixVda.template\win2022-vda-2411.templateversion" `
    -VMCpuCount 3 `
    -VMMemoryMB 6144 `
    -InitialBatchSizeHint 1 `
    -Scope @() `
    -RunAsynchronously `
    -PersistUserChanges OnLocal
```