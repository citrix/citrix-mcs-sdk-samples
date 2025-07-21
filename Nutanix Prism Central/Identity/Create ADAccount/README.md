# Create Active Directory Accounts

The `Create-ADAccount.ps1` script creates an AD computer accounts.

## Using the script

### Parameters

- Required Parameters:
    - IdentityPoolName: The name of the identity pool to add AD computer accounts
    - UserName: The username with permission to create accounts in AD
- Optional Parameters:
    - Count: The number of accounts to be added. 1 if not specified
    - AdminAddress: The primary DDC address


### Examples
```powershell
.\Create-ADAccount.ps1 `
        -IdentityPoolName "MyIdentityPool" `
        -UserName "MyUsername" `
        -Count 1 `
        -AdminAddress "MyDDC.MyDomain.local"
```