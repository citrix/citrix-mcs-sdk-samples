## Remove Identity Pools

### Overview
Remove-AcctIdentity provides the ability to remove identities from an identity pool.

If the option to remove the account from identity pool or to disable it is specified, the AD operation must succeed for the account to be removed from the Citrix AD Identity Service database.
Use caution when using the Force parameter because this allows removal of accounts that are in the 'inUse' state, which might result in the machines becoming unusable.
```powershell
$identityPoolName = "demo-identitypool"
$identityPoolName = "demo-identitypool01"
$identityAccountName1 = "demo001"
$identityAccountName2 = "demo002"

# Simply remove a identity from identity pool
Remove-AcctIdentity -IdentityPoolName $identityPoolName -IdentityAccountName $identityAccountName1

# Removes a identity from identity pool and delete it from AD
Remove-AcctIdentity -IdentityPoolName $identityPoolName -RemovalOption Delete -IdentityAccountName $identityAccountName2

### Common error cases

Failed to remove an identity pool if the following things happen -
1. The identity to be removed could not be found.
2. User does not have enough rights/privileges to perform this operation.