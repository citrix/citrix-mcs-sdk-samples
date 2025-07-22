# Update Provisioning Scheme To Enable or Disable Azure Arc
## How to update Provisioning Scheme with Azure Arc enabled or disabled
Set-ProvScheme is used to udpate the provisioning scheme.
The following parameters are required:
- `ProvisioningSchemeName`

To enable Azure Arc, we need to specify all the Arc parameters
- `EnableAzureArcOnboarding`
- `AzureArcSubscriptionId`
- `AzureArcResourceGroup` 
- `AzureArcRegion`

```powershell
$provisioningSchemeName = "demo-provScheme"
Set-ProvScheme -ProvisioningSchemeName $provisioningSchemeName -EnableAzureArcOnboarding $true`
	-AzureArcSubscriptionId $AzureArcSubscription -AzureArcRegion $AzureArcRegion -AzureArcResourceGroup $AzureArcResourceGroup
```

To disable Azure Arc, we only need
- `EnableAzureArcOnboarding`

```powershell
$provisioningSchemeName = "demo-provScheme"
Set-ProvScheme -ProvisioningSchemeName $provisioningSchemeName -EnableAzureArcOnboarding $false`
```

[Set-ProvScheme Documentation Link](https://developer-docs.citrix.com/en-us/citrix-virtual-apps-desktops-sdk/2411/machinecreation/set-provscheme)

## Common error cases

1. If the hosting unit path of the master image is invalid, the error message is "New-ProvScheme : Path XDHyp:\HostingUnits\MyHostingUnit\MyVM.vm\MySnapshot.snapshot is not valid: Cannot find path 'XDHyp:\HostingUnits\MyHostingUnit' because it does not exist."

2. If the hosting unit path of the network mapping is invalid, the error message is "New-ProvScheme : Path XDHyp:\HostingUnits\MyHostingUnit\MyNetwork.network is not valid: Cannot find path 'XDHyp:\HostingUnits\MyHostingUnit' because it does not exist."
