# Creating an Identity Pool

The `Remove-ADAccount.ps1` removes AD Accounts within an identity pool.

## Using the script

### Parameters

- Required Parameters:
    - IdentityPoolName: Name of the identity pool from which AD computer accounts will be removed
- Optional Paramters:
    - ADAccountNames: Names of the specific accounts to be removed.
    - RemoveAllAccounts: A flag to indicate whether all AD accounts within the specified identity pool should be removed.
    - AdminAddress: The primary DDC address.

### Examples
- Remove specific AD accounts:
```powershell
.\Remove-ADAccount.ps1 `
    -IdentityPoolName "myIDP" `
    -ADAccountNames "MyDomain\MyVM1","MyDomain\MyVM2" `
```
- Remove all AD accounts:
```powershell
.\Remove-ADAccount.ps1 `
    -IdentityPoolName "myIDP" `
    -RemoveAllAccounts `
```