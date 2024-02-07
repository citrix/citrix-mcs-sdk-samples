### Create ProvScheme and Catalog
To create a Provisioning Scheme, the following parameters are required:

```powershell
# [User Input Required] Set parameters for New-ProvScheme
$isCleanOnBoot = $true
$provisioningSchemeName = "demo-provScheme"
$identityPoolName = $provisioningSchemeName
$hostingUnitName = "demo-hostingUnit"
$masterImageResourceGroupName = "demo-resourceGroup"
$masterImage = "demo-snapshot.snapshot"
$vNet = "MyVnet"
$subnet = "subnet1"
$masterImagePath = "XDHyp:\HostingUnits\$hostingUnitName\image.folder\$masterImageResourceGroupName.resourcegroup\$masterImage"
$networkMapping = @{"0"="XDHyp:\HostingUnits\$hostingUnitName\East US.region\virtualprivatecloud.folder\$masterImageResourceGroupName.resourcegroup\$vNet.virtualprivatecloud\$subnet.network"}
$numberOfVms = 1   

$createdProvScheme = New-ProvScheme -CleanOnBoot:$isCleanOnBoot `
-ProvisioningSchemeName $provisioningSchemeName `
-HostingUnitName $hostingUnitName `
-IdentityPoolName $identityPoolName `
-InitialBatchSizeHint $numberOfVms `
-MasterImageVM $masterImagePath `
-NetworkMapping $networkMapping `
```

After creating a provisioning scheme, create the MCS Catalog. To create the catalog, you need the following parameters:
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
