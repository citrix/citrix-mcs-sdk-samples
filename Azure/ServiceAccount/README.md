# Service Account

## Overview
A service account holds the credential that MCS uses to call an identity provider on your behalf. Once a service account is assigned to an identity pool, MCS uses it to manage the machine identities of that pool. For example, when a machine of a Microsoft Entra ID joined catalog is deleted, MCS uses the service account to delete the machine's Microsoft Entra ID device and Intune managed device.

A service account is bound to exactly one identity provider:
- `AzureAD` - a Microsoft Entra ID tenant. The service account obtains application-only Microsoft Graph tokens.
- `ActiveDirectory` - an Active Directory domain.

The scripts in this folder use `AzureAD` service accounts for device management. Microsoft Entra ID join credentials on a service account are not covered by these samples.

### Capabilities
The capabilities of a service account decide what MCS may do with it. Each Microsoft Graph capability needs the matching Microsoft Graph application permissions granted to the identity the account authenticates as. When a permission is missing, the capability is reported as unhealthy and its `FailureReason` names the permission.

| Capability | What MCS does with it | Microsoft Graph application permissions |
|---|---|---|
| `AzureADDeviceManagement` | Query, update and delete Microsoft Entra ID device objects | `Device.ReadWrite.All` |
| `AzureADSecurityGroupManagement` | Read security groups and add group members | `Group.ReadWrite.All`, `GroupMember.ReadWrite.All` |
| `IntuneDeviceManagement` | Query and delete Intune managed devices | `DeviceManagementManagedDevices.ReadWrite.All` |
| `AzureArcResourceManagement` | Onboard provisioned machines to Azure Arc. Requires an application client secret; not supported with a managed identity | Not applicable |

### Authentication modes
An `AzureAD` service account can authenticate in three ways. The mode is selected by the `AuthenticationMode` key of the service account's custom properties, which is the same custom property an Azure hosting connection uses. There is no separate parameter for it.

| AuthenticationMode | AccountId | AccountSecret | Where the Microsoft Graph token comes from |
|---|---|---|---|
| `AppClientSecret` (the default when absent) | Application (client) id of the app registration | Client secret of the app registration | The app registration |
| `SystemAssignedManagedIdentity` | Not supplied | Not supplied | The system-assigned managed identity of the Cloud Connectors |
| `UserAssignedManagedIdentity` | Client id of the managed identity | Not supplied | A user-assigned managed identity assigned to the Cloud Connectors |

### Managed identity requirements
A managed identity backed service account has no client secret to store, rotate, or let expire. It is supported with the following requirements:
1. It is available on Citrix DaaS only. An on-premises deployment has no Cloud Connector to hold the identity.
2. The `IdentityProviderType` must be `AzureAD`.
3. The custom properties must route the traffic through the Cloud Connector: set `ProxyHypervisorTrafficThroughConnector` to `true` and `ZoneUid` to the Uid of the zone (resource location) whose Cloud Connectors carry the identity. Use the `Uid` returned by `Get-ConfigZone`, not the `ExternalUid`.
4. The Cloud Connectors of that resource location must be Azure VMs, since a managed identity exists only on an Azure resource. The managed identity must be enabled (system-assigned) or assigned (user-assigned) on every one of them.
5. The managed identity must belong to the same Microsoft Entra tenant as the `IdentityProviderIdentifier` of the service account. The service cannot detect a managed identity from another tenant, so verify this yourself.
6. The Microsoft Graph application permissions must be granted to the managed identity. There is no Azure portal page for this; use [Grant-ManagedIdentityGraphPermission.ps1](Create%20ServiceAccount/Grant-ManagedIdentityGraphPermission.ps1). Each system-assigned managed identity is a separate service principal, so grant the permissions to the identity of every Cloud Connector VM.
7. The service account manages devices only. It cannot hold a Microsoft Entra ID join credential, and it does not support Azure Arc onboarding (`AzureArcResourceManagement`); use a service account with an application client secret for that.
8. The service account cannot be used with an identity pool that spans Microsoft Entra tenants.

### Use a service account with an identity pool
Assign the service account to an identity pool with `Set-AcctIdentityPool`. To create identity pools, see [Identity](../Identity/README.md).
```powershell
$identityPoolName = "demo-identitypool"
$serviceAccountUid = "00000000-0000-0000-0000-000000000000"

Set-AcctIdentityPool -IdentityPoolName $identityPoolName -ServiceAccountUid $serviceAccountUid
```

## How to use Service Account
There are four folders of scripts which help the user to perform CRUD (Create, Read, Update, Delete) operations on service accounts.
1. Create ServiceAccount scripts - To create a service account with an application client secret, a system-assigned managed identity, or a user-assigned managed identity
    - [Readme](Create%20ServiceAccount/README.md)
2. Get ServiceAccount scripts - To get the information of existing service accounts and the identity pools that use them
    - [Readme](Get%20ServiceAccount/README.md)
3. Update ServiceAccount scripts - To edit the settings of a service account, switch it between authentication modes, and manage its scopes
    - [Readme](Update%20ServiceAccount/README.md)
4. Remove ServiceAccount scripts - To remove an existing service account
    - [Readme](Remove%20ServiceAccount/README.md)
