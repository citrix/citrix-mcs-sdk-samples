# Get ProvVMConfiguration
To get the ProvVMConfiguration created, the following parameters are optional and can be passed as a filter parameters
- `Version`
- `ProvisioningSchemeName`
- `ADAccountSid`

```
$ADAccountSid = "00000000-0000-0000-0000-000000000000"
$Version = 4
$provisioningSchemeName = "ScaleTest"

###############################################################
# Gets ProvVMConfiguration
###############################################################
Get-ProvVMConfiguration -ADAccountSid $ADAccountSid -Version $Version -ProvisioningSchemeName $provisioningSchemeName 
```
