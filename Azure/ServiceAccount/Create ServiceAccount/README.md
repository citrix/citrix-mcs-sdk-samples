## Create Service Account

### Overview
New-AcctServiceAccount is used to create a new service account. The scripts in this folder create an `AzureAD` service account with each of the three authentication modes. To learn about the authentication modes and their requirements, see [Service Account](../README.md).

### Application client secret
The service account authenticates with the client secret of an app registration. `AccountId` is the application (client) id of the app registration, and `AccountSecret` is its client secret. If `SecretExpiryTime` is not specified, the secret never expires.
```powershell
$tenantId = "TenantId" # Microsoft Entra tenant id
$applicationId = "AppId" # Application (client) id of the app registration
$applicationSecret = Read-Host 'Please enter your application secret' -AsSecureString
$secretExpiryTime = "2027-09-09"
$displayName = "demo-serviceaccount"
$description = "Microsoft Entra ID and Intune device management"
$capabilities = @("AzureADDeviceManagement", "IntuneDeviceManagement")

New-AcctServiceAccount -IdentityProviderType "AzureAD" `
    -IdentityProviderIdentifier $tenantId `
    -AccountId $applicationId `
    -AccountSecret $applicationSecret `
    -SecretExpiryTime $secretExpiryTime `
    -DisplayName $displayName `
    -Description $description `
    -Capabilities $capabilities
```

### System-assigned managed identity
The service account obtains its Microsoft Graph tokens from the system-assigned managed identity of the Cloud Connectors. Neither an account id nor a secret is supplied. The `AuthenticationMode` is set in the custom properties, together with the zone whose Cloud Connectors carry the identity.
```powershell
$tenantId = "TenantId" # Microsoft Entra tenant id
$zoneName = "demo-resource-location" # Resource location whose Cloud Connectors carry the managed identity
$displayName = "demo-serviceaccount"
$description = "Microsoft Entra ID and Intune device management"
$capabilities = @("AzureADDeviceManagement", "IntuneDeviceManagement")

$zone = Get-ConfigZone -Name $zoneName
$customProperties = [ordered]@{
    ProxyHypervisorTrafficThroughConnector = $true
    ZoneUid = @($zone.Uid.ToString())
    AuthenticationMode = "SystemAssignedManagedIdentity"
} | ConvertTo-Json -Compress

New-AcctServiceAccount -IdentityProviderType "AzureAD" `
    -IdentityProviderIdentifier $tenantId `
    -DisplayName $displayName `
    -Description $description `
    -Capabilities $capabilities `
    -CustomProperties $customProperties
```

### User-assigned managed identity
The service account obtains its Microsoft Graph tokens from a user-assigned managed identity assigned to the Cloud Connectors. `AccountId` carries the client id of the managed identity, and no secret is supplied.
```powershell
$tenantId = "TenantId" # Microsoft Entra tenant id
$managedIdentityClientId = "ManagedIdentityClientId" # Client id of the user-assigned managed identity
$zoneName = "demo-resource-location" # Resource location whose Cloud Connectors carry the managed identity
$displayName = "demo-serviceaccount"
$description = "Microsoft Entra ID and Intune device management"
$capabilities = @("AzureADDeviceManagement", "IntuneDeviceManagement")

$zone = Get-ConfigZone -Name $zoneName
$customProperties = [ordered]@{
    ProxyHypervisorTrafficThroughConnector = $true
    ZoneUid = @($zone.Uid.ToString())
    AuthenticationMode = "UserAssignedManagedIdentity"
} | ConvertTo-Json -Compress

New-AcctServiceAccount -IdentityProviderType "AzureAD" `
    -IdentityProviderIdentifier $tenantId `
    -AccountId $managedIdentityClientId `
    -DisplayName $displayName `
    -Description $description `
    -Capabilities $capabilities `
    -CustomProperties $customProperties
```
**Note**: Creating a managed identity backed service account acquires a Microsoft Graph token from the managed identity before the account is saved, so the managed identity must already be in place on the Cloud Connectors. A managed identity backed service account stores no secret; an `AccountSecret` supplied with one is discarded.

[More info about New-AcctServiceAccount](https://developer-docs.citrix.com/en-us/citrix-daas-sdk/adidentity/new-acctserviceaccount)

### Grant Microsoft Graph permissions to a managed identity
A managed identity has no API permissions page in the Azure portal, so its Microsoft Graph application permissions are granted with a script. [Grant-ManagedIdentityGraphPermission.ps1](Grant-ManagedIdentityGraphPermission.ps1) uses the Microsoft Graph PowerShell SDK. Granting application permissions requires the Privileged Role Administrator or Global Administrator role.
```powershell
$tenantId = "TenantId" # Microsoft Entra tenant id
$managedIdentityObjectId = "ManagedIdentityObjectId" # Object (principal) id of the managed identity
$permissions = @("Device.ReadWrite.All", "DeviceManagementManagedDevices.ReadWrite.All")

Connect-MgGraph -TenantId $tenantId -Scopes "Application.Read.All", "AppRoleAssignment.ReadWrite.All"

$graphServicePrincipal = Get-MgServicePrincipal -Filter "appId eq '00000003-0000-0000-c000-000000000000'"
foreach ($permission in $permissions) {
    $appRole = $graphServicePrincipal.AppRoles | Where-Object { $_.Value -eq $permission }
    New-MgServicePrincipalAppRoleAssignment -ServicePrincipalId $managedIdentityObjectId `
        -PrincipalId $managedIdentityObjectId `
        -ResourceId $graphServicePrincipal.Id `
        -AppRoleId $appRole.Id
}
```
**Note**: A newly granted permission can take several minutes to appear in the tokens issued for the managed identity. Until then, the capability may be reported as unhealthy.

### Common error cases

Failed to create a service account if the following things happen -
1. User does not have enough rights/privileges to perform this operation.
2. A service account with the same AccountId already exists for the identity provider.
3. One or more capabilities are not supported.
4. An application client secret service account is created without AccountId or AccountSecret.
5. A managed identity is selected and any of the following apply -
    - The IdentityProviderType is not AzureAD.
    - The deployment is on-premises.
    - A user-assigned managed identity is selected without its client id as the AccountId.
    - The custom properties do not set ProxyHypervisorTrafficThroughConnector and ZoneUid.
    - A Microsoft Entra ID join credential is supplied.
    - A Microsoft Graph token cannot be acquired from the managed identity, because the identity is not assigned to every Cloud Connector in the resource location, the Cloud Connector is unreachable, or the identity has not been granted the required Microsoft Graph permissions.
