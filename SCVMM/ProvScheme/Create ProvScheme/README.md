# Create Provisioning Scheme and Catalog
## How to create Provisioning Scheme
New-ProvScheme is used to create a new provisioning scheme.
The following parameters are required:
- `ProvisioningSchemeName`
- `HostingUnitName`
- `IdentityPoolName` 
- `MasterImageVm`

The following parameters are optional
- `CleanOnBoot`
- `InitialBatchSizeHint`
    - Default value will be `0`
- `VMCpuCount`
    - The default value is the no of processors from the master image VM or machine profile VM (depending on how you want to create a provisioning scheme)
- `NetworkMapping`
    - The default value is the network assigned to the hosting unit.
- `VMMemoryMb`
	- The default value is the amount of memory from the master image VM or machine profile VM (depending on how you want to create a provisioning scheme)

```powershell
$provisioningSchemeName = "demo-provScheme"
$masterVmName= "demo-master"
$masterVmSnapshot= "demo-snapshot"
$hostingUnitName = "demo-hostingunit"
$masterImage = "XDHyp:\HostingUnits\$hostingUnitName\$masterVmName.vm\$masterVmSnapshot.snapshot"
$identityPoolName = $provisioningSchemeName

New-ProvScheme -ProvisioningSchemeName $provisioningSchemeName `
    -CleanOnBoot:$isCleanOnBoot `
    -HostingUnitName $hostingUnitName `
    -IdentityPoolName $identityPoolName `
    -MasterImageVm $masterImage `
```
[New-ProvScheme Documentation Link](https://developer-docs.citrix.com/en-us/citrix-virtual-apps-desktops-sdk/current-release/machinecreation/new-provscheme)

## How to create a Broker catalog
After create a provisioning scheme, create the MCS Catalog. To create the catalog, you need the following parameters:
- `Name`
- `ProvisioningSchemeId`
- `AllocationType`
- `PersistUserChanges`
- `SessionSupport`

```powershell
$allocationType = "Random"
$persistUserChanges = "Discard"
$sessionSupport = "MultiSession"
$description = "This is not required"

# This should now be able to see the catalog in Studio
New-BrokerCatalog -Name $ProvisioningSchemeName `
    -ProvisioningSchemeId $createdProvScheme.ProvisioningSchemeUid `
    -AllocationType $allocationType  `
    -Description $description `
    -IsRemotePC $False `
    -PersistUserChanges $persistUserChanges `
    -ProvisioningType "MCS" `
    -Scope @() `
    -SessionSupport $sessionSupport
```

[New-BrokerCatalog Documentation](https://developer-docs.citrix.com/en-us/citrix-virtual-apps-desktops-sdk/current-release/Broker/new-brokercatalog)

## Common error cases

1. If the source of image is a virtual machine , we get "Virtual Machine is not supported as Master Image. Use a checkpoint/snapshot or a template".
2. If the network for the resource cannot be resolved , we get "The specified network mapping could not be resolved".
