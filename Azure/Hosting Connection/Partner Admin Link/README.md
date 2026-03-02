# Azure Partner Admin Link (PAL)
## Overview
Partner Admin Link (PAL) is a Microsoft feature that allows Azure resource usage to be attributed to a partner organization. With this feature, the Citrix Partner ID (353109) is automatically associated with the identity configured on your Azure connection.

By default, connections are automatically associated with the Citrix Partner ID once per day. You can opt out of this association by setting the `DisablePartnerIdAssociation` custom property on your connection to true.

To learn more about Microsoft Partner Admin Link, refer to Microsoft's documentation: https://learn.microsoft.com/en-us/azure/cost-management-billing/manage/link-partner-id

## Supported Credential Types
This feature is supported for all Azure connection credential types, including:
- Service Principal (AppClientSecret)
- User Assigned Managed Identity
- System Assigned Managed Identity

## How to Disable Partner ID Association

To disable the automatic association of the Citrix Partner ID, you can set the `DisablePartnerIdAssociation` custom property on your hosting connection to `true.` See the `Disable-PartnerIdAssociation.ps1` script for a complete example.

**Note:** Setting `DisablePartnerIdAssociation` to `true` prevents new associations for the connection, but it does not remove the Citrix Partner ID if it was previously assigned.

## How to Enable Partner ID Association

To re-enable automatic Partner ID association (if you previously disabled it), see the `Enable-PartnerIdAssociation.ps1` script. This script sets the `DisablePartnerIdAssociation` property to `false` on your connection's custom properties.

## How to Check Current PAL Status
**Prerequisite:** Install the Az.ManagementPartner module before using the `Check-PartnerIdStatus.ps1` script:
```powershell
Install-Module -Name Az.ManagementPartner -AllowClobber -Scope CurrentUser
```

You can verify the current Partner Admin Link setting by authenticating with your Azure identity and using Azure PowerShell cmdlets. See the `Check-PartnerIdStatus.ps1` script for a complete example.

The script will:
1. Authenticate with your Azure identity (example uses Service Principal)
2. Use `Get-AzManagementPartner` to check if a Partner ID is associated
3. Display the Partner ID information if one exists

The output will show the Partner ID (353109 for Citrix) if it is currently associated.

**Note:** The authentication method varies by identity type:
- **Service Principal**: `Connect-AzAccount -ServicePrincipal -TenantId <tenant> -Credential $credential`
- **System Assigned Managed Identity**: `Connect-AzAccount -Identity`
- **User Assigned Managed Identity**: `Connect-AzAccount -Identity -AccountId <client-id>`

## How to Remove Citrix PAL

To fully disable & remove the Citrix PAL: 
- First, disable automatic association (see the previous section), 
- Then remove the existing Partner ID association using the powershell snippet below. **Note:** Removing without disabling means Citrix will re-associate it on the next daily attempt.

To completely remove the Citrix Partner ID association (not just disable future associations), you must use Azure PowerShell:

```powershell
# Authenticate with your identity (method varies by type - see note above)
Connect-AzAccount -Identity  # Example for System Assigned Managed Identity

# Remove the Partner ID
Remove-AzManagementPartner -PartnerId 353109
```

Documentation: https://docs.citrix.com/en-us/citrix-daas/install-configure/connections/connection-azure-resource-manager#azure-partner-admin-link-pal-for-citrix-partner-id