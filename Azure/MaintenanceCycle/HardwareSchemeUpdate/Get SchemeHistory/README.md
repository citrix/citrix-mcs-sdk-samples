# Get Scheme History

To get the scheme history, the following parameters are optional and can be passed as a filter parameters
- `ProvisioningSchemeName`
- `ProvisioningSchemeUid`
- `ImageVersionSpecUid`
- `ProvisioningSchemeHistoryVersion`

```
$provisioningSchemeName = "ScaleTest"
$ProvisioningSchemeHistoryVersion = 1

###############################################################
# Gets Provisioning Scheme History
###############################################################
Get-ProvSchemeHistory -ProvisioningSchemeName $provisioningSchemeName -ProvisioningSchemeHistoryVersion $ProvisioningSchemeHistoryVersion
```
