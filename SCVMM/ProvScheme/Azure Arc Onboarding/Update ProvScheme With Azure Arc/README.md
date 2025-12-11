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

1. If the source of image is a virtual machine , we get "Virtual Machine is not supported as Master Image. Use a checkpoint/snapshot or a template".
2. If the network for the resource cannot be resolved , we get "The specified network mapping could not be resolved".
