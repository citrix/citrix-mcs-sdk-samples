## Remove Identity Pools

### Overview
Remove-AcctIdentityPool is used to remove a list of existing identity pools. The identity pools must not have any computer AD accounts before it can be removed.

To remove a specific Identity Pool, use `-IdentityPoolName` parameter in `Remove-AcctIdentityPool`.
```powershell
$identityPoolName = "demo-identitypool"
Remove-AcctIdentityPool -IdentityPoolName $identityPoolName
```
Use `Get-AcctADAccount` to get the AD Accounts in an Identity Pool and use `Remove-AcctADAccount` to remove the given list of AD Accounts
```powershell
$identityPoolName = "demo-identitypool"

# Get the all the AD Accounts in the identity pool
$adAccountNames = Get-AcctADAccount -IdentityPoolName $identityPoolName | Select-Object -ExpandProperty ADAccountName

Remove-AcctADAccount -IdentityPoolName $identityPoolName -ADAccountName $adAccountNames
```
[More info about Get-AcctADAccount](https://developer-docs.citrix.com/en-us/citrix-virtual-apps-desktops-sdk/current-release/adidentity/get-acctadaccount)<br>
[More info about Remove-AcctADAccount](https://developer-docs.citrix.com/en-us/citrix-virtual-apps-desktops-sdk/current-release/adidentity/remove-acctadaccount)<br>

### Common error cases

Failed to remove an identity pool if the following things happen -
1. The identity pool to be removed could not be found.
2. The identity pool is not empty i.e. it contains AD accounts.

