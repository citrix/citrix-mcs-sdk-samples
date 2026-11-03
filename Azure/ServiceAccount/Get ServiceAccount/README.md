## Get Service Account Properties

### Overview
Get-AcctServiceAccount is used to retrieve a list of existing service accounts and their properties.

To get a specific service account, use the `-ServiceAccountUid` parameter in `Get-AcctServiceAccount`. To get the service accounts of a Microsoft Entra tenant, use `-IdentityProviderIdentifier`.
```powershell
$serviceAccountUid = "00000000-0000-0000-0000-000000000000"
$tenantId = "TenantId"

Get-AcctServiceAccount -ServiceAccountUid $serviceAccountUid
Get-AcctServiceAccount -IdentityProviderIdentifier $tenantId
```
You can also get a filtered list of service accounts using `-Filter`. The list can be sorted and limited to a maximum number of service accounts using `SortBy` and `MaxRecordCount`. <br> [More info about Filter and SortBy](https://developer-docs.citrix.com/en-us/citrix-virtual-apps-desktops-sdk/current-release/adidentity/about_acct_filtering)
```powershell
$filter = "{ IdentityProviderType -eq 'AzureAD' }"
$sortBy = "DisplayName"
$maxRecord = 5

Get-AcctServiceAccount -Filter $filter -SortBy $sortBy -MaxRecordCount $maxRecord
```
**Note**: if no parameter is provided, then the script will return all the service accounts

### Capability health
Each capability of a service account reports its own health. When the identity the service account authenticates as lacks a Microsoft Graph permission, the capability is unhealthy and `FailureReason` names the missing permission.
```powershell
$serviceAccount = Get-AcctServiceAccount -ServiceAccountUid $serviceAccountUid
$serviceAccount.Capabilities | Format-Table Name, EffectiveScope, IsHealthy, FailureReason
```

### Authentication mode
The authentication mode is the `AuthenticationMode` key of the custom properties. When it is absent, the service account authenticates with an application client secret.
```powershell
$authenticationMode = "AppClientSecret"
if ($serviceAccount.CustomProperties)
{
    $customProperties = $serviceAccount.CustomProperties | ConvertFrom-Json
    if ($customProperties.AuthenticationMode) { $authenticationMode = $customProperties.AuthenticationMode }
}
```
For a user-assigned managed identity, `AccountId` is the client id of the managed identity. For a system-assigned managed identity, `AccountId` is empty.

[More info about Get-AcctServiceAccount](https://developer-docs.citrix.com/en-us/citrix-daas-sdk/adidentity/get-acctserviceaccount)

### Identity pools of a service account
Get-AcctServiceAccountIdentityPool is used to retrieve the identity pools that use a service account.
```powershell
$serviceAccountUid = "00000000-0000-0000-0000-000000000000"
(Get-AcctServiceAccountIdentityPool -ServiceAccountUid $serviceAccountUid).IdentityPools
```
[More info about Get-AcctServiceAccountIdentityPool](https://developer-docs.citrix.com/en-us/citrix-daas-sdk/adidentity/get-acctserviceaccountidentitypool)

### Common error cases

Failed to get the service account details if the following things happen -
1. User does not have enough rights/privileges to perform this operation.
2. A filtering expression in the command could not be interpreted.
