## Get Identity Pool Properties

### Overview
Get-AcctIdentityPool is used to retrieve a list of existing identity pools and its properties.

To get a specific Identity Pool, use `-IdentityPoolName` parameter in `Get-AcctIdentityPool`.
```powershell
$identityPoolName = "demo-identitypool"
Get-AcctIdentityPool -IdentityPoolName $identityPoolName
```
You can also get a filtered list of Identity Pool using `-Filter`. The list can be sorted and set a max limit of number Identity Pool you want in a list using `SortBy` and `MaxRecordCount`. <br> [More info about Filter and SortBy](https://developer-docs.citrix.com/en-us/citrix-virtual-apps-desktops-sdk/current-release/adidentity/about_acct_filtering)
```powershell
$filter = "{ NamingSchemeType -eq 'Numeric' }"
$sortBy = "-AvailableAccounts"
$maxRecord = 5

Get-AcctIdentityPool -Filter $filter -SortBy $sortBy -MaxRecordCount $maxRecord
```
**Note**: if no parameter is provided, then the script will return all the Identity Pools

[More info about Get-AcctIdentityPool](https://developer-docs.citrix.com/en-us/citrix-virtual-apps-desktops-sdk/current-release/adidentity/get-acctidentitypool)

### Common Error cases

Failed to get an identity pool details if the following things happen -
1. User does not have enough rights/privileges to perform this operation.
2. A filtering expression in the command could not be interpreted