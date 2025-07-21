# Creating an Identity Pool

The `Create-IdentityPool.ps1` script creates an a new Identity Pool

## Using the script

### Parameters

- Required Parameters:
    - `IdentityPoolName`: The name of the identity pool
    - `ZoneUid`: The UID that corresponds to the Zone in which these AD accounts will be created
    - `NamingScheme`: Defines the template name for AD accounts created in the identity pool
    - `NamingSchemeType`: The type of naming scheme. This can be Numeric or Alphabetic
- Optional Parameters:
    - `AdminAddress`: The primary DDC address
    - `Scope`: The administration scopes to be applied to the new identity pool
    - `WorkGroupMachine`: Indicates whether the accounts created should be part of a workgroup rather than a domain
    - `Domain`: The AD domain name for the pool. Specify this in FQDN format; for example, MyDomain.local

### Examples
    - Create a Domain-Joined IdentityPool
```powershell
.\Create-IdentityPool.ps1 `
    -IdentityPoolName "myIDP" `
    -ZoneUid "00000000-0000-0000-0000-000000000000" `
    -Domain "MyDomain.local" `
    -NamingScheme "MyVM###" `
    -NamingSchemeType "Numeric" `
    -Scope @()
```
    - Create a Non-Domain-Joined IdentityPool
```powershell
.\Create-IdentityPool.ps1 `
    -IdentityPoolName "myIDP" `
    -ZoneUid "00000000-0000-0000-0000-000000000000" `
    -WorkGroupMachine `
    -NamingScheme "MyVM###" `
    -NamingSchemeType "Numeric" `
    -Scope @()
```