# Add Provisioning Scheme

This page explains the use of the Create-ProvisioningScheme.ps1 script.

This script creates a Provisioning Scheme.

## Using the script

### Parameters

- Required parameters:
    - `ProvisioningSchemeName`: Name of the new provisioning scheme
    - `ProvisioningSchemeType`: The Provisioning Scheme Type
    - `HostingUnitName`: Name of the hosting unit used
    - `IdentityPoolName`: Name of the Identity Pool used
    - `NetworkMapping`: Specifies how the attached NICs are mapped to networks
    - `CustomProperties`: Used to provide `ContainerPath`(as hypervisor path), `vCPU` count, `RAM`, and `CPUCores`(Cores per CPU) values
    - `MasterImageVM`: Path to VM snapshot or template
- Optional Parameters:
    - `InitialBatchSizeHint`: The number of VMs that will be intially added to the Provisioning Scheme
    - `CleanOnBoot`: Reset VM's to their initial state on each power on
    - `Scope`: Administration scopes for the identity pool
    - `RunAsynchronously`: Run command asynchronously, returns ProvTask ID

### Example
The script can be executed like the example below:
```powershell
# Setting up customProperties as a variable for better readability
$customProperties = @"
    <CustomProperties xmlns="http://schemas.citrix.com/2014/xd/machinecreation">
        <StringProperty Name="ContainerPath" Value="/myContainer.storage"/>
        <StringProperty Name="vCPU" Value="3"/>
        <StringProperty Name="RAM" Value="6144"/>
        <StringProperty Name="CPUCores" Value="3"/>    
    </CustomProperties>
"@

# Create a non-persistent Provisioning Scheme 
.\Create-ProvisioningScheme.ps1 `
    -ProvisioningSchemeName "myProvScheme" `
    -ProvisioningSchemeType "MCS" `
    -HostingUnitName "myHostingUnit" `
    -IdentityPoolName "myIdp" `
    -NetworkMapping @{"0"="XDHyp:\HostingUnits\myHostingUnit\myNetwork.network"} `
    -CustomProperties $customProperties `
    -MasterImageVM "XDHyp:\HostingUnits\myHostingUnit\myMasterImage.template" `
    -InitialBatchSizeHint 1 `
    -CleanOnBoot `
    -Scope @() `
    -RunAsynchronously
```