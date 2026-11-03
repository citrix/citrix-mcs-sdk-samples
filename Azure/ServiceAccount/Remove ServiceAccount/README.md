## Remove Service Account

### Overview
Remove-AcctServiceAccount is used to remove an existing service account.

A service account cannot be removed while an identity pool still uses it. Use `Get-AcctServiceAccountIdentityPool` to find those identity pools, and assign them another service account with `Set-AcctIdentityPool -ServiceAccountUid` first.
```powershell
$serviceAccountUid = "00000000-0000-0000-0000-000000000000"

$identityPools = (Get-AcctServiceAccountIdentityPool -ServiceAccountUid $serviceAccountUid).IdentityPools
if ($identityPools)
{
    throw "The service account is still used by the identity pools: $($identityPools.IdentityPoolName -join ', ')."
}

Remove-AcctServiceAccount -ServiceAccountUid $serviceAccountUid
```
**Note**: A managed identity backed service account is removed the same way. Removing the service account does not change the managed identity or its Microsoft Graph permissions in Azure.

[More info about Remove-AcctServiceAccount](https://developer-docs.citrix.com/en-us/citrix-daas-sdk/adidentity/remove-acctserviceaccount)

### Common error cases

Failed to remove a service account if the following things happen -
1. User does not have enough rights/privileges to perform this operation.
2. The service account cannot be found.
3. The service account is still used by one or more identity pools.
