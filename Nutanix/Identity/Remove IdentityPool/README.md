# Creating an Identity Pool

The `Remove-IdentityPool.ps1` script removes an identity pool.

## Using the script

> NOTE: Ensure there are no AD Accounts associated with this Identity Pool. 

### Parameters

- Required Parameters:
    - IdentityPoolName: Name of the identity pool to be removed
- Optional Paramters:
    - AdminAddress: The primary DDC address.

### Examples
```powershell
.\Remove-IdentityPool.ps1 `
    -IdentityPoolName "MyIdentityPool" `
    -AdminAddress "MyDDC.MyDomain.local"
```