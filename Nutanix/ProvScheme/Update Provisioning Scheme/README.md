# Add Provisioning Scheme

This page explains the use of the Update-ProvScheme.ps1 script.

Update-ProvScheme.ps1 updates the RAM, CPUs and Cores per socket values for a Provisioning Scheme.

## Using the script

Ensure that:
1. The vCPU value in the CustomProperties matches the value in the VMCpuCount parameter
2. The RAM value in the CustomProperties matches the value in the VMMemoryMB parameter

### Parameters

- Required parameters:
    - `ProvisioningSchemeName`: Name of the new provisioning scheme
    - `CustomProperties`: Used to provide `ContainerPath`(as hypervisor path), `vCPU` count, `RAM`, and `CPUCores`(Cores per CPU) values
- Optional Parameters:
    - `VMCpuCount`: Number of vCPUs
    - `VMMemoryMB`: VM memory in MB

### Example
The script can be executed like the example below:
```powershell
# Setting up customProperties as a variable for better readability
$customProperties = @"
    <CustomProperties xmlns="http://schemas.citrix.com/2014/xd/machinecreation">
        <StringProperty Name="ContainerPath" Value="/myContainer.storage"/>
        <StringProperty Name="vCPU" Value="2"/>
        <StringProperty Name="RAM" Value="4096"/>
        <StringProperty Name="CPUCores" Value="1"/>    
    </CustomProperties>
"@
.\Update-ProvScheme.ps1 `
    -ProvisioningSchemeName "myProvScheme" `
    -CustomProperties $customProperties `
    -VMCpuCount 2 `
    -VMMemoryMB 4096
```