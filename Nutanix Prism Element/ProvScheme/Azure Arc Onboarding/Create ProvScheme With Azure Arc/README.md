# Create Provisioning Scheme and Catalog With Azure Arc Enabled
## How to create Provisioning Scheme and update identityPool with ServiceAccount that has AzureArcResourceManagement capability
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
	
The following parameters are required to enable Azure Arc
- `EnableAzureArcOnboarding`
- `AzureArcSubscriptionId`
- `AzureArcResourceGroup` 
- `AzureArcRegion`

The following parameters are required to setup Service Account with AzureArcResourceManagement capability
- `tenantId`
- `applicationId`
- `applicationSecret`
- `secretExpiryTime`
- `identityProviderType`

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
	-EnableAzureArcOnboarding `
	-AzureArcSubscriptionId $azureArcSubscriptionId `
	-AzureArcResourceGroup $azureArcResourceGroup `
	-AzureArcRegion $azureArcRegion `
	
$serviceAccount = New-AcctServiceAccount -IdentityProviderType $identityProviderType -IdentityProviderIdentifier $tenantId -AccountId $applicationId -AccountSecret $secureString -SecretExpiryTime $secretExpiryTime -Capabilities "AzureArcResourceManagement"

$identityPool = Get-AcctIdentityPool -IdentityPoolName $identityPoolName
Set-AcctIdentityPool -IdentityPoolUid $identityPool.IdentityPoolUid -ServiceAccountUid $serviceAccount.ServiceAccountUid
	
	
```
[New-ProvScheme Documentation Link](https://developer-docs.citrix.com/en-us/citrix-virtual-apps-desktops-sdk/current-release/machinecreation/new-provscheme)
[New-AcctServiceAccount Documentation Link](https://developer-docs.citrix.com/en-us/citrix-virtual-apps-desktops-sdk/2411/adidentity/new-acctserviceaccount)
[New-AcctIdentityPool Documentation Link](https://developer-docs.citrix.com/en-us/citrix-virtual-apps-desktops-sdk/2411/adidentity/set-acctidentitypool)

## Common Errors During Operation

1. If the hosting unit path of the master image is invalid, the error message is "New-ProvScheme : Path XDHyp:\HostingUnits\MyHostingUnit\MyVM.vm\MySnapshot.snapshot is not valid: Cannot find path 'XDHyp:\HostingUnits\MyHostingUnit' because it does not exist."

2. If the hosting unit path of the network mapping is invalid, the error message is "New-ProvScheme : Path XDHyp:\HostingUnits\MyHostingUnit\MyNetwork.network is not valid: Cannot find path 'XDHyp:\HostingUnits\MyHostingUnit' because it does not exist."
