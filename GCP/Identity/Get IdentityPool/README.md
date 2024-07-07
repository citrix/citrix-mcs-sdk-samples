## Get Identity Pool Properties

### Overview
```Get-AcctIdentityPool``` cmdlet is used to retrieve a list of existing identity pools and its properties.

To get a specific Identity Pool, use `Get-AcctIdentityPool` cmdlet with `-IdentityPoolName` parameter.
```powershell
$identityPoolName = "demo-identitypool"
Get-AcctIdentityPool -IdentityPoolName $identityPoolName
```
You can also get a filtered list of identity pools using `-Filter`. The list can be sorted using `SortBy` and number of records returned can be limited using `MaxRecordCount`. <br> [More info about Filter and SortBy](https://developer-docs.citrix.com/en-us/citrix-virtual-apps-desktops-sdk/current-release/adidentity/about_acct_filtering)
```powershell
$filter = "{ NamingSchemeType -eq 'Numeric' }"
$sortBy = "-AvailableAccounts"
$maxRecord = 5

Get-AcctIdentityPool -Filter $filter -SortBy $sortBy -MaxRecordCount $maxRecord
```
**Note**: if no parameter is provided, then the script will return all the Identity Pools

[More info about Get-AcctIdentityPool](https://developer-docs.citrix.com/en-us/citrix-virtual-apps-desktops-sdk/current-release/adidentity/get-acctidentitypool)

### Common Error cases
1. User does not have enough rights/privileges to perform this operation.
2. A filtering expression in the command could not be interpreted.