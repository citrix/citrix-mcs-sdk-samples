# Add Provisioning Scheme

This page explains the use of the Update-ProvScheme.ps1 script.

Update-ProvScheme.ps1 updates the RAM, CPUs and Cores per socket values for a Provisioning Scheme.

## Using the script

### Parameters

- Required parameters:
    - `ProvisioningSchemeName`: Name of the new provisioning scheme
- Optional Parameters:
    - `CustomProperties`:       Used to provide `ClusterId`(as GUID), and `CPUCores`(Cores per CPU) values
    - `VMCpuCount`:             Number of vCPUs
    - `VMMemoryMB`:             VM memory in MB

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

"@
.\Update-ProvScheme.ps1 `
    -ProvisioningSchemeName "myProvScheme" `
    -CustomProperties $customProperties `
    -VMCpuCount 2 `
    -VMMemoryMB 4096 `
```
