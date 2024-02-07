# Identity Pool
## Overview
Identity pool is a container for identities that can be configured with all the information required for new Active Directory accounts to be created.

## How to use Identity Pool
In MCS, Identity Pool is often used to create the AD accounts for the created provisioned machines in a catalog.

### Creating Identity Pool
To create an Identity Pool, you first need need the following: naming scheme, domain, zone UID, and the name of the identity pool you want to create.<br>
To get the following resources mentioned above, refer to the AWS Hypervisor [Readme](../README.md)<br>
There are restrictions to what the value can be for the naming scheme and the name of the identity pool. Refer to the [public Citrix documentation](https://developer-docs.citrix.com/en-us/citrix-virtual-apps-desktops-sdk/current-release/adidentity/new-acctidentitypool#parameters) to about the restrictions.
```powershell
$identityPoolName = "demo-identitypool"
$domain = "demo.local"
$namingScheme = "demo-###"
$namingSchemeType = "Numeric" # Can be Numeric, Alphabetic, or None
$zoneUid = "00000000-0000-0000-0000-000000000000"
```
It is not required to include the naming scheme type, but it will default to `Numeric`. Naming scheme type can be either `Numeric`, `Alphabetic`, `None`. **Note**: If you don't want a naming scheme type, you have to input `None`
```powershell
$namingSchemeType = "Numeric" # Can be Numeric, Alphabetic, or None
```
Use `New-AcctIdentityPool` to create the Identity Pool
```powershell
New-AcctIdentityPool -IdentityPoolName $identityPoolName -NamingScheme $namingScheme -NamingSchemeType $namingSchemeType -Domain $domain -ZoneUid $zoneUid
```
[More info about New-AcctIdentityPool](https://developer-docs.citrix.com/en-us/citrix-virtual-apps-desktops-sdk/current-release/adidentity/new-acctidentitypool)

You can create a Non-domain-joined identity pool by using the parameter `WorkgroupMachine` and exclude the Domain parameter. This eliminates the need to specify all AD-specific parameters including domain administrator credentials when creating provisioned VMs.
```powershell
New-AcctIdentityPool -IdentityPoolName $identityPoolName -NamingScheme $namingScheme -NamingSchemeType $namingSchemeType -ZoneUid $zoneUid -WorkgroupMachine
```

[More info about Non-domain-joined identity pool](https://docs.citrix.com/en-us/citrix-daas/install-configure/machine-identities/non-domain-joined)

### Getting Identity Pool Properties
To get a specific Identity Pool, use `-IdentityPoolName` parameter in `Get-AcctIdentityPool`.
```powershell
$identityPoolName = "demo-identitypool"
Get-AcctIdentityPool -IdentityPoolName $identityPoolName
```
You can also get a filtered list of Identity Pool using `-Filter`. The list can be sorted and set a max limit of number Identity Pool you want in a list using `SortBy` and `MaxRecordCount`. <br> [More info about Filter and SortBy](https://developer-docs.citrix.com/en-us/citrix-virtual-apps-desktops-sdk/current-release/adidentity/about_acct_filtering)
```powershell
$filter = "{ NamingSchemeType -eq 'Numeric' }"
$sortBy = "-AvailableAccounts"
$maxRecord = 5

Get-AcctIdentityPool -Filter $filter -SortBy $sortBy -MaxRecordCount $maxRecord
```
**Note**: if no parameter is provided, then the script will return all the Identity Pools

[More info about Get-AcctIdentityPool](https://developer-docs.citrix.com/en-us/citrix-virtual-apps-desktops-sdk/current-release/adidentity/get-acctidentitypool)

### Updating Identity Pool Properties
You can change the following properties for Hosting Connection: name, naming scheme, domain, naming scheme type, and zone UID

To rename the Identity Pool, use `Rename-AcctIdentityPool`
```powershell
$identityPoolName = "demo-identitypool"
$newIdentityPoolName = "new-demo-identitypool"
Rename-AcctIdentityPool -IdentityPoolName $identityPoolName -NewIdentityPoolName $newIdentityPoolName
```
**Note**: You will now be using the new Identity Pool name whenever you need to make any calls to it.<br>
[More info about Rename-AcctIdentityPool](https://developer-docs.citrix.com/en-us/citrix-virtual-apps-desktops-sdk/current-release/adidentity/rename-acctidentitypool)

To change the other properties of an Identity Pool, use `Set-AcctIdentityPool`
```powershell
$identityPoolName = "demo-identitypool"
$namingScheme = "demo-###"
$domain = "demo.local"
$namingSchemeType = "Numeric"
$zoneUid = "00000000-0000-0000-0000-000000000000"

Set-AcctIdentityPool -IdentityPoolName $identityPoolName -NamingScheme $namingScheme -NamingSchemeType $namingSchemeType -Domain $domain -ZoneUid $zoneUid
```
[More info about Set-AcctIdentityPool](https://developer-docs.citrix.com/en-us/citrix-virtual-apps-desktops-sdk/current-release/adidentity/set-acctidentitypool)

### Deleting Identity Pool
Before deleting an Identity Pool, make sure there are no AD Accounts in the Identity Pool.

Use `Get-AcctADAccount` to get the AD Accounts in an Identity Pool and use `Remove-AcctADAccount` to remove the given list of AD Accounts
```powershell
$identityPoolName = "demo-identitypool"

# Get the all the AD Accounts in the identity pool
$adAccountNames = Get-AcctADAccount -IdentityPoolName $identityPoolName | Select-Object -ExpandProperty ADAccountName

Remove-AcctADAccount -IdentityPoolName $identityPoolName -ADAccountName $adAccountNames
```
[More info about Get-AcctADAccount](https://developer-docs.citrix.com/en-us/citrix-virtual-apps-desktops-sdk/current-release/adidentity/get-acctadaccount)<br>
[More info about Remove-AcctADAccount](https://developer-docs.citrix.com/en-us/citrix-virtual-apps-desktops-sdk/current-release/adidentity/remove-acctadaccount)<br>

To remove the Identity Pool, use `Remove-AcctIdentityPool`
```powershell
$identityPoolName = "demo-identitypool"
Remove-AcctIdentityPool -IdentityPoolName $identityPoolName
```
[More info about Remove-AcctIdentityPool](https://developer-docs.citrix.com/en-us/citrix-virtual-apps-desktops-sdk/current-release/adidentity/remove-acctidentitypool)

## Common Error Case
Remove all the AD Accounts in the Identity Pool before removing the Identity Pool.

If a user enters a string that does not follow the identity pool restriction, these type of errors would show up
1. If you include an illegal character to IdentityPoolName: Cannot validate argument on parameter 'IdentityPoolName'. The string contains illegal characters. The following characters are invalid:\/;:#.*?=<>|[]()"'
2. If you do not include a **#** to the naming scheme when using either `Numeric` or `Alphabetic` as the naming scheme type: The operation returned an unexpected result code Citrix.XDPowerShell.ADIdentityStatus.NamingSchemeAndNamingSchemeTypeMustBeUsedTogether