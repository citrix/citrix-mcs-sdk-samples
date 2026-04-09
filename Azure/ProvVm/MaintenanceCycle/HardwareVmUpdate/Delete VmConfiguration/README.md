# Delete ProvVMConfiguration
To delete an inactive ProvVMConfiguration created, 

The following parameters are required
- `ADAccountSid`
- `ConfigurationVersion`

```
$ADAccountSid = "00000000-0000-0000-0000-000000000000"
$ConfigurationVersion = 4

####################################################
# Removes a ProvVMConfiguration
####################################################
Remove-ProvVMConfiguration -ADAccountSid $ADAccountSid -ConfigurationVersion $ConfigurationVersion
```