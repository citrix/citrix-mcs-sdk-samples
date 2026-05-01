# Update Provisioning Scheme

This page explains the use of the Update-ProvScheme.ps1 script.

Update-ProvScheme.ps1 updates the RAM, CPUs, Cores per socket, and Machine Profile for a Provisioning Scheme.

## Using the script

### Parameters

- Required parameters:
    - `ProvisioningSchemeName`: Name of the new provisioning scheme
- Optional Parameters:
    - `MachineProfile`:         Path to Prism Central Template Version for hardware specification
    - `NetworkMapping`:         Specifies how the attached NICs are mapped to networks (required when using MachineProfile)
    - `CustomProperties`:       Used to provide `ClusterId`(as GUID), and `CPUCores`(Cores per CPU, overrides the setting in master image or machine profile Template Version) values
    - `VMCpuCount`:             Number of vCPUs (overrides the setting in master image or machine profile Template Version)
    - `VMMemoryMB`:             VM memory in MB (overrides the setting in master image or machine profile Template Version)

**Important:** The MachineProfile must have at least one NIC, and the number of NICs in the MachineProfile must match the subnet mappings in NetworkMapping.

The total number of NICs for the template version can be obtained from the AdditionalData of its inventory item using the following:
```powershell
$tv = Get-Item -Path "XDHyp:\HostingUnits\myHostingUnit\Templates.folder\HardwareProfile.template\hardwarespec.templateversion"
$tv.AdditionalData.TotalNics
```

**Note:** When using `MachineProfile`, hardware properties are updated from the Machine Profile template version. This does not update the hardware specification of existing ProvVMs in the catalog. Only new ProvVMs added to the catalog will have the hardware specification from the Machine Profile. Command-line parameters like `VMCpuCount`, `VMMemoryMB`, and `CPUCores` in `CustomProperties` take precedence over values in the Machine Profile.

### Example
The script can be executed like the example below:

For example: To change the Cores per CPU setting
```powershell

# Setting up customProperties as a variable for better readability

$customProperties = @"
    <CustomProperties xmlns="http://schemas.citrix.com/2014/xd/machinecreation">
        <StringProperty Name="ClusterId" Value="00001111-2222-3333-4444-555556666666"/>
        <StringProperty Name="CPUCores" Value="2"/>
    </CustomProperties>
"@
.\Update-ProvScheme.ps1 `
    -ProvisioningSchemeName "myProvScheme" `
    -CustomProperties $customProperties
```

For example: To change the CPU and Memory Setting
```powershell
$customProperties = @"
    <CustomProperties xmlns="http://schemas.citrix.com/2014/xd/machinecreation">
        <StringProperty Name="ClusterId" Value="00001111-2222-3333-4444-555556666666"/>
        <StringProperty Name="CPUCores" Value="2"/>
    </CustomProperties>
"@
.\Update-ProvScheme.ps1 `
    -ProvisioningSchemeName "myProvScheme" `
    -CustomProperties $customProperties `
    -VMCpuCount 2 `
    -VMMemoryMB 4096
```

For example: To update a catalog with a new machine profile
```powershell
.\Update-ProvScheme.ps1 `
    -ProvisioningSchemeName "myProvScheme" `
    -MachineProfile "XDHyp:\HostingUnits\myHostingUnit\Templates.folder\HardwareProfile.template\hardwarespec.templateversion" `
    -NetworkMapping @{"0"="XDHyp:\HostingUnits\myHostingUnit\Clusters.folder\cluster01.cluster\Network-A.network"}
```

For example: To update a catalog with a machine profile and override specific hardware settings
```powershell
$customProperties = @"
    <CustomProperties xmlns="http://schemas.citrix.com/2014/xd/machinecreation">
        <StringProperty Name="ClusterId" Value="00001111-2222-3333-4444-555556666666"/>
        <StringProperty Name="CPUCores" Value="2"/>
    </CustomProperties>
"@
.\Update-ProvScheme.ps1 `
    -ProvisioningSchemeName "myProvScheme" `
    -MachineProfile "XDHyp:\HostingUnits\myHostingUnit\Templates.folder\HardwareProfile.template\hardwarespec.templateversion" `
    -NetworkMapping @{"0"="XDHyp:\HostingUnits\myHostingUnit\Clusters.folder\cluster01.cluster\Network-A.network"} `
    -CustomProperties $customProperties `
    -VMCpuCount 4 `
    -VMMemoryMB 8192
```
