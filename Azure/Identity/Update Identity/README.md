## Update Identity

### Overview
Update-AcctIdentity is used to updates the state of identity accounts in a given identity pool.
It provides the ability to synchronize the state of the identity accounts stored in the AD Identity Service with the accounts themselves.
By default, this checks all accounts marked as 'error' to determine if accounts are still in an error state (i.e. disabled or locked).
If the 'AllAccounts' option is specified, it checks all accounts regardless of error state and updates their status.

```powershell
$identityPoolName = "demo-identitypool"
Update-AcctIdentity -IdentityPoolName $identityPoolName
```

### Common error cases

Failed to unlock an identity if the following things happen -
1. User does not have enough rights/privileges to perform this operation.
2. The identity pool could not be found.