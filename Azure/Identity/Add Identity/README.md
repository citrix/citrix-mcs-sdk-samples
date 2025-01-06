## Add Identity Properties

### Overview
Add-AcctIdentity is used to import given identities into an existing identity pool.

```powershell
$identityPoolName = "demo-identitypool"
$identityName1 = "demo-001"
$identityName2 = "demo-002"
Add-AcctIdentity -IdentityPoolName $identityPoolName -IdentityAccountName $identityName1, $identityName2

```
### Common Error cases

Failed to import an identity into the given identity pool if the following things happen -
1. User does not have enough rights/privileges to perform this operation.
2. The identity does not  exists.
3. The identity is already in the given identity pool.
4. The IdentityPoolName does not exist.
