## Unlock Identity

### Overview
Unlock-AcctIdentity is used to unlock the given identity accounts.
An identity account is marked as locked while the Machine Creation Services (MCS) are processing tasks relating to the account.
If these tasks are forcibly stopped, an account can remain locked despite no longer being processed. This command resolves this
issue, but use it with caution because unlocking an account that MCS expects to be locked can result in an MCS operation being
cancelled. Use this command only when MCS has locked an account for use in a provisioning operation and the operation has failed
without unlocking the account.

```powershell
$identityAccountName = "demo001"
Unlock-AcctIdentity -IdentityAccountName $identityAccountName
```
**Note**: The lock state in Active Directory is unrelated to the lock state in the identity service. This command does NOT make any changes to the account information stored in Active Directory or Azure AD, only modifies the account state stored in the Citrix AD Identity Service database.<br>

### Common error cases

Failed to unlock an identity if the following things happen -
1. User does not have enough rights/privileges to perform this operation.
2. The identity to be repair/reset could not be found.