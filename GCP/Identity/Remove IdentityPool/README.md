## Remove Identity Pools

### Overview
Remove-AcctIdentityPool cmdlet is used to remove a list of existing identity pools. The identity pools must not have any computer AD accounts before it can be removed.

To remove a specific Identity Pool, use `Remove-AcctIdentityPool` cmdlet with `-IdentityPoolName` parameter.
```powershell
$identityPoolName = "demo-identitypool"
Remove-AcctIdentityPool -IdentityPoolName $identityPoolName
```
To remove the AD Accounts from the identity pool, use `Get-AcctADAccount` in conjunction with `Remove-AcctADAccount`.
```powershell
$identityPoolName = "demo-identitypool"

# Get the all the AD Accounts in the identity pool
$adAccountNames = Get-AcctADAccount -IdentityPoolName $identityPoolName | Select-Object -ExpandProperty ADAccountName

Remove-AcctADAccount -IdentityPoolName $identityPoolName -ADAccountName $adAccountNames
```
[More info about Get-AcctADAccount](https://developer-docs.citrix.com/en-us/citrix-virtual-apps-desktops-sdk/current-release/adidentity/get-acctadaccount)<br>
[More info about Remove-AcctADAccount](https://developer-docs.citrix.com/en-us/citrix-virtual-apps-desktops-sdk/current-release/adidentity/remove-acctadaccount)<br>

### Common error cases
1. The identity pool to be removed could not be found.
2. The identity pool is not empty i.e. it contains AD accounts.