## Update/Rename Identity Pool

### RenameIdentity Pool
Rename-AcctIdentityPool is used to change the name of an existing identity pool.

To rename the Identity Pool, use `Rename-AcctIdentityPool`
```powershell
$identityPoolName = "demo-identitypool"
$newIdentityPoolName = "new-demo-identitypool"
Rename-AcctIdentityPool -IdentityPoolName $identityPoolName -NewIdentityPoolName $newIdentityPoolName
```
**Note**: You will now be using the new Identity Pool name whenever you need to make any calls to it.<br>
[More info about Rename-AcctIdentityPool](https://developer-docs.citrix.com/en-us/citrix-virtual-apps-desktops-sdk/current-release/adidentity/rename-acctidentitypool)

### Update Identity Pool

Set-AcctIdentityPool is used to update properties of an Identity Pool such as naming scheme, domain, naming scheme type, and zone UID.

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

Failed to update an identity pool if the following things happen -
1. Namingscheme does not have enough characters or has too many characters.
2. Namingscheme starts with a period (.)
3. Namingscheme does not have '#' character.
4. Identity Pool with the same name already exists.