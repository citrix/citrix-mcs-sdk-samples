## Get Identity Properties

### Overview
Get-AcctIdentity is used to retrieve a list of existing identities and its properties.

To get the specific Identities in a given Identity Pool, use `-IdentityPoolName` parameter in `Get-AcctIdentity`.

To get a specific Identiyand its properties, use `-IdentityAccountId` parameter in `Get-AcctIdentity`. 
```powershell
$identityPoolName = "demo-identitypool"
Get-AcctIdentity -IdentityPoolName $identityPoolName

$identityAccountId = "S-2-7-21-24521345-865934153-2418134190-2784"
Get-AcctIdentity -IdentityAccountId $identityAccountId
```
You can also get a filtered list of Identity using `-Filter`. The list can be sorted and set a max limit of number Identity  you want in a list using `SortBy` and `MaxRecordCount`. <br> [More info about Filter and SortBy](https://developer-docs.citrix.com/en-us/citrix-virtual-apps-desktops-sdk/current-release/adidentity/about_acct_filtering)
```powershell
$filter = "{ State -eq 'InUse' }"
$sortBy = "IdentityPoolUid"
$maxRecord = 5

Get-AcctIdentity -Filter $filter -SortBy $sortBy -MaxRecordCount $maxRecord
```
**Note**: if no parameter is provided, then the script will return all the Identities

[More info about Get-AcctIdentity](https://developer-docs.citrix.com/en-us/citrix-virtual-apps-desktops-sdk/current-release/adidentity/get-acctidentity)

### Common Error cases

Failed to get an identity pool details if the following things happen -
1. User does not have enough rights/privileges to perform this operation.
2. A filtering expression in the command could not be interpreted
