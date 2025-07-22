# Create ProvVM

`Create-ProvVM.ps1` adds a new VM to an existing Provisioning Scheme.

## Using the script

### Parameters

- Required Parameters:
    - `ProvisioningSchemeName`: Name of Provisioning Scheme to add VMs to
    - `UserName`:               Username for AD account
    - `IdentityPoolName`:       Name of Identity Pool associated with the catalog
    - `CatalogName`:            Name of Broker Catalog
- Optional Parameters
    - `Count`:                  Number of VMs to create (default is 1)


### Examples

- Create 1 new VM
```powershell
.\Create-ProvVM.ps1 `
    -ProvisioningSchemeName "MyCatalog" `
    -UserName "myUserName" `
    -IdentityPoolName "myIdentityPool" `
    -CatalogName "myBrokerCatalog"
```
- Create 5 new VMs
```powershell
.\Create-ProvVM.ps1 `
    -ProvisioningSchemeName "MyCatalog" `
    -UserName "myUserName" `
    -IdentityPoolName "myIdentityPool" `
    -CatalogName "myBrokerCatalog" `
    -Count 5
```