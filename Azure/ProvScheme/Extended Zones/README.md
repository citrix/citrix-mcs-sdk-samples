# Azure Extended Zones
## Overview
When creating a provisioning scheme for Azure Extended Zones, the primary difference from Azure regions is in the network mapping path. The network mapping must reference the Extended Zone (using `.extendedzone`) instead of a region (using `.region`).

To learn more about Azure Extended Zones, refer to Microsoft's documentation: https://learn.microsoft.com/en-us/azure/extended-zones/

## Prerequisites
Before creating a ProvScheme for an Extended Zone:
1. A hosting connection to Azure must be created
2. **A hosting unit for the Extended Zone must be created** (see [Hosting Unit > Azure Extended Zones](../../Hosting%20Unit/Extended%20Zones))
3. Azure Extended Zones must be registered in your subscription
4. Your service principal must have the `Microsoft.EdgeZones/extendedZones/read` permission

For complete details on prerequisites, limitations, and supported features, refer to the Citrix documentation: https://docs.citrix.com/en-us/citrix-daas/install-configure/connections/connection-azure-resource-manager#azure-extended-zones

## How to use Extended Zones with ProvScheme

When creating a ProvScheme, the network mapping path must reference the Extended Zone:
**Extended Zone:**
```powershell
$networkMapping = @{"0"="XDHyp:\HostingUnits\$hostingUnitName\$extendedZone.extendedzone\virtualprivatecloud.folder\$resourceGroup.resourcegroup\$vNet.virtualprivatecloud\$subnet.network"}
```

Documentation: https://docs.citrix.com/en-us/citrix-daas/install-configure/connections/connection-azure-resource-manager#azure-extended-zones