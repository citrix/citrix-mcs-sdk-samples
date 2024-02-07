## Create Identity Pool

### Overview
New-AcctIdentityPool is used to create a new identity pool.

### Active Directory Accounts
You can create a identity pool with AD computer accounts.
The following properties (naming scheme, domain, zone UID, identity pool name, naming scheme type) must be provided.	
```powershell
$identityPoolName = "demo-identitypool"
$domain = "demo.local"
$namingScheme = "demo-###"
$namingSchemeType = "Numeric" # Can be Numeric, Alphabetic, or None (Default is Numeric)
New-AcctIdentityPool -IdentityPoolName $identityPoolName -NamingScheme $namingScheme -NamingSchemeType $namingSchemeType -Domain $domain
```
**Note**: If you don't want a naming scheme type, you have to input `None`

[More info about New-AcctIdentityPool](https://developer-docs.citrix.com/en-us/citrix-virtual-apps-desktops-sdk/current-release/adidentity/new-acctidentitypool)


### Non Domain Joined Accounts
You can create a Non-domain-joined identity pool by using the parameter `WorkgroupMachine` and exclude the Domain parameter. This eliminates the need to specify all AD-specific parameters including domain administrator credentials when creating provisioned VMs.
```powershell
New-AcctIdentityPool -IdentityPoolName $identityPoolName -NamingScheme $namingScheme -NamingSchemeType $namingSchemeType -WorkgroupMachine
```

[More info about Non-domain-joined identity pool](https://docs.citrix.com/en-us/citrix-daas/install-configure/machine-identities/non-domain-joined)

### Common error cases

Failed to create an identity pool if the following things happen -
1. Namingscheme does not have enough characters or has too many characters.
2. Namingscheme starts with a period (.)
3. Namingscheme does not have '#' character.
4. Identity Pool with the same name already exists.


