## New Identity Properties

### Overview
New-AcctIdentity is used to create identities and register them in an already existing identity pool.

```powershell
$identityPoolName = "demo-identitypool"
$count = 5
New-AcctIdentity -IdentityPoolName $identityPoolName -Count $count

```
### Common Error cases

Failed to create an identity details if the following things happen -
1. User does not have enough rights/privileges to perform this operation.
2. An identity with the same SID already exists.
3. Identity name exceeds the max 15 character name limit.
4. The IdentityPoolName does not exist.
