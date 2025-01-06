## Repair/Reset Identity

### Repair Identity
Repair-AcctIdentity is used to repair the given identity accounts in identity pool.

```powershell
$identityAccountName1 = "demo001"
$identityAccountName2 = "demo002"
$target1 = "IdentityInfo"
$target2 = "UserCertificate"
Repair-AcctIdentity -IdentityAccountName $identityAccountName1 -target $target1
Repair-AcctIdentity -IdentityAccountName $identityAccountName2 -target $target2
```
**Note**: Unlike "Reset-AcctIdentity", this command will not reset 'Tainted' accounts and make them to be 'Available' in the identity pool.<br>

### Reset Identity

Reset-AcctIdentity is used to reset identity accounts of the identity pool that behave abnormally. It resets "Tainted" accounts to "Available".

```powershell
$identityAccountName = "demo001"
Reset-AcctIdentity -IdentityAccountName $identityAccountName
```

### Common error cases

Failed to repair/reset an identity if the following things happen -
1. User does not have enough rights/privileges to perform this operation.
2. The identity to be repair/reset could not be found.