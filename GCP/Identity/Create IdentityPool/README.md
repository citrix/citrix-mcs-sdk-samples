## Create Identity Pool

### Overview
New-AcctIdentityPool is used to create a new identity pool. Identity pools can be one of multiple types (i.e. ActiveDirectory, HybridAzureAD, or Workgroup).

### OnPrem Active Directory Accounts
You can create a identity pool with AD computer accounts.
The following properties (naming scheme, domain, identity pool name, naming scheme type) must be provided.	
```powershell
$identityPoolName = "demo-identitypool"
$domain = "demo.local"
$identityType = "ActiveDirectory"
$namingScheme = "demo-###"
$namingSchemeType = "Numeric" # Can be Numeric, Alphabetic, or None (Default is Numeric)
$deviceManagementType = "None"
$zoneUid = "Zone Uid" # should be Guid
$OU = "CN=Computers,DC=demo,DC=local" # OU defined
$startCount = 1

New-AcctIdentityPool -DeviceManagementType $deviceManagementType `
    -Domain $domain `
    -IdentityPoolName $identityPoolName `
    -IdentityType  $identityType `
    -NamingScheme $namingScheme `
    -NamingSchemeType $namingSchemeType `
    -OU $OU `
    -StartCount $startCount `
    -ZoneUid $zoneUid
```
**Note**: If you don't want a naming scheme type, you have to input `None`

[More info about New-AcctIdentityPool](https://developer-docs.citrix.com/en-us/citrix-virtual-apps-desktops-sdk/current-release/adidentity/new-acctidentitypool)


### Non Domain Joined Accounts
You can create a Non-domain-joined identity pool by using the parameter `WorkgroupMachine` and exclude the Domain parameter. This eliminates the need to specify all AD-specific parameters including domain administrator credentials when creating provisioned VMs.
```powershell
$identityPoolName = "demo-identitypool"
$identityType = "Workgroup"
$namingScheme = "demo-###"
$namingSchemeType = "Numeric" # Can be Numeric, Alphabetic, or None (Default is Numeric)

New-AcctIdentityPool -IdentityPoolName $identityPoolName ` 
    -IdentityType $identityType ` 
    -NamingScheme $namingScheme ` 
    -NamingSchemeType $namingSchemeType `
    -WorkgroupMachine
```
**Note**: If you don't want a naming scheme type, you have to input `None`

[More info about Non-domain-joined identity pool](https://docs.citrix.com/en-us/citrix-daas/install-configure/machine-identities/non-domain-joined)


### Hybrid Azure Active Directory Accounts 
You can create an identity pool with Hybrid Azure AD computer accounts 
The following properties (identity pool name, naming scheme, naming scheme type, device management type, domain, identity type) must be provided.
```powershell
$identityPoolName = "demo-identitypool"
$namingScheme = "demo-###"
$namingSchemeType = "Numeric" # Can be Numeric, Alphabetic, or None (Default is Numeric)
$deviceManagementType = "None"
$identityType = "HybridAzureAD"
$zoneUid = "58320c9b-1c76-4712-8385-790873e85a0e" # Zone Uid
$domain = "demo.local"
$OU = "CN=Computers,DC=demo,DC=local"
$startCount = 1

New-AcctIdentityPool -DeviceManagementType $deviceManagementType `
    -Domain $domain `
    -IdentityPoolName $identityPoolName `
    -IdentityType  $identityType `
    -NamingScheme $namingScheme `
    -NamingSchemeType $namingSchemeType `
    -OU $OU `
    -StartCount $startCount `
    -ZoneUid $zoneUid
```
**Note**: If you don't want a naming scheme type, you have to input `None`

### Common error cases
1. Namingscheme does not have enough characters or has too many characters.
2. Namingscheme starts with a period (.)
3. Namingscheme does not have '#' character.
4. Identity Pool with the same name already exists.

