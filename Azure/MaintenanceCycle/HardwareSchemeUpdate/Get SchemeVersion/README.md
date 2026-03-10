# Get Scheme Version
To get the scheme version created, the following parameters are mandatory
- `ProvisioningSchemeName`

To get the scheme version created, the following parameters are optional and can be passed as a filter parameters
- `Version`

```
$provisioningSchemeName = "ScaleTest"
$Version = 1

###############################################################
# Gets Provisioning Scheme Version
###############################################################
Get-ProvSchemeVersion -ProvisioningSchemeName $provisioningSchemeName -Version $Version
```
