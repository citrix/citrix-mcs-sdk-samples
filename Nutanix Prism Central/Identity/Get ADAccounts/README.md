# Creating an Identity Pool

The `Get-ADAccounts.ps1` returns AD Accounts within an identity pool.

## Using the script

### Parameters

- Required Parameters:
    - `IdentityPoolName`: The name of the identity pool

### Examples

```powershell
.\Get-ADAccounts.ps1 `
        -IdentityPoolName "MyIdentityPool"
```