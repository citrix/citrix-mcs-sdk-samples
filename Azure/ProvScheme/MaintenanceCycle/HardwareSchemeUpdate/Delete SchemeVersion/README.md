# Delete Prov Scheme Version
To delete an inactive provschemeversion created, 

The following parameters are required
- `ProvisioningSchemeName`
- `Version`

```
$provisioningSchemeName = "ScaleTest"

####################################################
# Removes a Provisioning Scheme Version
####################################################
Remove-ProvSchemeVersion -ProvisioningSchemeName $provisioningSchemeName -Version $Version
```