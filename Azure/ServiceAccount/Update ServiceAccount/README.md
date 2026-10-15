## Update Service Account

### Overview
Set-AcctServiceAccount is used to update the properties of a service account, such as its display name, description, capabilities, secret, and authentication mode.

### Update Service Account
`-Capabilities` replaces the capabilities of the service account, so supply the full set the service account should end up with.
```powershell
$serviceAccountUid = "00000000-0000-0000-0000-000000000000"
$displayName = "demo-serviceaccount"
$description = "Microsoft Entra ID, Intune and security group management"
$capabilities = @("AzureADDeviceManagement", "AzureADSecurityGroupManagement", "IntuneDeviceManagement")

Set-AcctServiceAccount -ServiceAccountUid $serviceAccountUid -DisplayName $displayName -Description $description -Capabilities $capabilities
```

### Update the application client secret
When the client secret of the app registration is renewed, update the service account with the new secret and its expiry time. Passing `""` as `SecretExpiryTime` sets the secret to never expire. This applies to a service account that authenticates with an application client secret; a managed identity backed service account has no secret.
```powershell
$serviceAccountUid = "00000000-0000-0000-0000-000000000000"
$applicationSecret = Read-Host 'Please enter your new application secret' -AsSecureString
$secretExpiryTime = "2028-09-09"

Set-AcctServiceAccount -ServiceAccountUid $serviceAccountUid -AccountSecret $applicationSecret -SecretExpiryTime $secretExpiryTime
```

### Switch the authentication mode
The authentication mode is switched by changing `AuthenticationMode` in `-CustomProperties`. The whole set of custom properties is replaced, so supply all the properties the service account should end up with. To learn about the authentication modes and their requirements, see [Service Account](../README.md).

| Switch to | Supply with the custom properties | What happens to the stored credentials |
|---|---|---|
| `SystemAssignedManagedIdentity` | Nothing else | AccountId, the secret and its expiry are cleared |
| `UserAssignedManagedIdentity` | `-AccountId` with the client id of the managed identity | AccountId is overwritten, and the secret and its expiry are cleared |
| `AppClientSecret` | `-AccountId` and `-AccountSecret` of the app registration, and optionally `-SecretExpiryTime` | AccountId and the secret are stored again |

The application client secret is not retained when a service account moves to a managed identity, so switching back requires the application id and secret again. An `-AccountSecret` supplied with a switch to a managed identity is discarded rather than stored. Keep a service account that has the `AzureArcResourceManagement` capability on an application client secret, because Azure Arc onboarding is not supported with a managed identity.

Switch to a system-assigned managed identity:
```powershell
$serviceAccountUid = "00000000-0000-0000-0000-000000000000"
$zoneName = "demo-resource-location" # Resource location whose Cloud Connectors carry the managed identity

$zone = Get-ConfigZone -Name $zoneName
$customProperties = [ordered]@{
    ProxyHypervisorTrafficThroughConnector = $true
    ZoneUid = @($zone.Uid.ToString())
    AuthenticationMode = "SystemAssignedManagedIdentity"
} | ConvertTo-Json -Compress

Set-AcctServiceAccount -ServiceAccountUid $serviceAccountUid -CustomProperties $customProperties
```

Switch to a user-assigned managed identity:
```powershell
$serviceAccountUid = "00000000-0000-0000-0000-000000000000"
$managedIdentityClientId = "ManagedIdentityClientId" # Client id of the user-assigned managed identity
$zoneName = "demo-resource-location" # Resource location whose Cloud Connectors carry the managed identity

$zone = Get-ConfigZone -Name $zoneName
$customProperties = [ordered]@{
    ProxyHypervisorTrafficThroughConnector = $true
    ZoneUid = @($zone.Uid.ToString())
    AuthenticationMode = "UserAssignedManagedIdentity"
} | ConvertTo-Json -Compress

Set-AcctServiceAccount -ServiceAccountUid $serviceAccountUid -AccountId $managedIdentityClientId -CustomProperties $customProperties
```

Switch back to an application client secret:
```powershell
$serviceAccountUid = "00000000-0000-0000-0000-000000000000"
$applicationId = "AppId" # Application (client) id of the app registration
$applicationSecret = Read-Host 'Please enter your application secret' -AsSecureString
$secretExpiryTime = "2027-09-09"
$zoneName = "demo-resource-location"

$zone = Get-ConfigZone -Name $zoneName
$customProperties = [ordered]@{
    ProxyHypervisorTrafficThroughConnector = $true
    ZoneUid = @($zone.Uid.ToString())
    AuthenticationMode = "AppClientSecret"
} | ConvertTo-Json -Compress

Set-AcctServiceAccount -ServiceAccountUid $serviceAccountUid `
    -AccountId $applicationId `
    -AccountSecret $applicationSecret `
    -SecretExpiryTime $secretExpiryTime `
    -CustomProperties $customProperties
```
**Note**: When you update the custom properties of a managed identity backed service account for any other reason, keep `AuthenticationMode` in them. Custom properties without `AuthenticationMode` select the application client secret, and the update is refused unless the application id and secret are supplied with it.

[More info about Set-AcctServiceAccount](https://developer-docs.citrix.com/en-us/citrix-daas-sdk/adidentity/set-acctserviceaccount)

### Update the effective scope of a capability
Set-AcctServiceAccountCapabilityEffectiveScope is used to set the scope a capability of the service account applies to. For an `AzureAD` service account, the effective scope can be an Azure subscription id in the Microsoft Entra tenant.
```powershell
$serviceAccountUid = "00000000-0000-0000-0000-000000000000"
$capability = "AzureArcResourceManagement"
$effectiveScope = "SubscriptionId" # Azure subscription id

Set-AcctServiceAccountCapabilityEffectiveScope -ServiceAccountUid $serviceAccountUid -Capability $capability -EffectiveScope $effectiveScope
```
[More info about Set-AcctServiceAccountCapabilityEffectiveScope](https://developer-docs.citrix.com/en-us/citrix-daas-sdk/adidentity/set-acctserviceaccountcapabilityeffectivescope)

### Add or remove scopes
Add-AcctServiceAccountScope and Remove-AcctServiceAccountScope are used to add a service account to, or remove it from, administration scopes.
```powershell
$serviceAccountUid = "00000000-0000-0000-0000-000000000000"
$scopes = @("Finance", "Marketing")

Add-AcctServiceAccountScope -Scope $scopes -ServiceAccountUid $serviceAccountUid
Remove-AcctServiceAccountScope -Scope $scopes -ServiceAccountUid $serviceAccountUid
```
[More info about Add-AcctServiceAccountScope](https://developer-docs.citrix.com/en-us/citrix-daas-sdk/adidentity/add-acctserviceaccountscope)<br>
[More info about Remove-AcctServiceAccountScope](https://developer-docs.citrix.com/en-us/citrix-daas-sdk/adidentity/remove-acctserviceaccountscope)

### Common error cases

Failed to update a service account if the following things happen -
1. User does not have enough rights/privileges to perform this operation.
2. The service account or the scope cannot be found.
3. One or more capabilities are not supported, or the capability whose effective scope is set is not a capability of the service account.
4. A user-assigned managed identity is selected without its client id as the AccountId.
5. The service account is switched back to an application client secret without the AccountId and AccountSecret.
6. A managed identity is selected and the IdentityProviderType is not AzureAD, the deployment is on-premises, the custom properties do not set ProxyHypervisorTrafficThroughConnector and ZoneUid, or the service account holds a Microsoft Entra ID join credential.
7. A managed identity is selected for a service account that already serves an identity pool spanning Microsoft Entra tenants.
8. A Microsoft Graph token cannot be acquired from the managed identity, because the identity is not assigned to every Cloud Connector in the resource location, the Cloud Connector is unreachable, or the identity has not been granted the required Microsoft Graph permissions.
