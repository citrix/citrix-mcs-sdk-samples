## Update/Rename Identity Pool

### Rename Identity Pool

To rename the Identity Pool, use `Rename-AcctIdentityPool` cmdlet.
```powershell
$identityPoolName = "demo-identitypool"
$newIdentityPoolName = "new-demo-identitypool"
Rename-AcctIdentityPool -IdentityPoolName $identityPoolName -NewIdentityPoolName $newIdentityPoolName
```

[More info about Rename-AcctIdentityPool](https://developer-docs.citrix.com/en-us/citrix-virtual-apps-desktops-sdk/current-release/adidentity/rename-acctidentitypool)

### Update Identity Pool

```Set-AcctIdentityPool``` cmdlet is used to update properties of an Identity Pool such as naming scheme, domain, naming scheme type, or zone UID.

```powershell
$identityPoolName = "demo-identitypool"
$namingScheme = "demo-###"
$domain = "demo.local"
$namingSchemeType = "Numeric"
$zoneUid = "Zone Uid" # should be Guid

Set-AcctIdentityPool -IdentityPoolName $identityPoolName -NamingScheme $namingScheme -NamingSchemeType $namingSchemeType -Domain $domain -ZoneUid $zoneUid
```
[More info about Set-AcctIdentityPool](https://developer-docs.citrix.com/en-us/citrix-virtual-apps-desktops-sdk/current-release/adidentity/set-acctidentitypool)

### Common error cases
1. Namingscheme does not have enough characters or has too many characters.
2. Namingscheme starts with a period (.)
3. Namingscheme does not have '#' character.
4. An Identity Pool with the same name already exists.
5. Domain name is invalid/does not exist.
6. Zone UID is invalid/does not exist.