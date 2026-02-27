# Azure Extended Zones
## Overview
Azure Extended Zones are small-footprint extensions of existing Azure regions. They enable organizations to run workloads closer to their users for improved performance and compliance. With MCS, you can provision and power-manage VMs in Extended Zones for both persistent and non-persistent catalogs.

Extended Zones are not enabled by default in Azure and must be registered separately for each location. Once configured, Extended Zones appear in the Citrix MCS inventory alongside standard regions, but they will have an `.extendedzone` type instead of `.region`.

To learn more about Azure Extended Zones, refer to Microsoft's documentation: https://learn.microsoft.com/en-us/azure/extended-zones/

## Prerequisites and Limitations
Before using this feature, ensure your Azure subscription is registered for Extended Zones and that your service principal has the required `Microsoft.EdgeZones/extendedZones/read` permission. For complete details on prerequisites, limitations, and registration steps, refer to the Citrix documentation: https://docs.citrix.com/en-us/citrix-daas/install-configure/connections/connection-azure-resource-manager#azure-extended-zones

## How to View Extended Zones via MCS Inventory
Using PowerShell, you can view the available Extended Zones in your hosting connection by using Get-ChildItem. For example:

```powershell
# Look for items with .extendedzone suffix 
Get-ChildItem "XDHyp:\Connections\<your-connection-name>" | Select-Object Name, ObjectTypeName
```

## How to Create a Hosting Unit in an Extended Zone
To create a hosting unit for an Extended Zone, use the `.extendedzone` suffix instead of `.region` in the root path. Extended Zones appear in the Citrix MCS inventory alongside standard regions.

**Standard Region Root Path:**
```powershell
$RootPath = "XDHyp:\Connections\$ConnectionName\East US.region"
```

**Extended Zone Root Path:**
```powershell
$RootPath = "XDHyp:\Connections\$ConnectionName\Los Angeles.extendedzone"
```

## Creating a Provisioning Scheme
After creating your Hosting Unit, proceed with catalog creation using Studio or PowerShell. Ensure your catalog references the Extended Zone Hosting Unit. When creating the ProvScheme, the network mapping will reference the Extended Zone:

```powershell
$networkMapping = @{"0"="XDHyp:\HostingUnits\$hostingUnitName\$extendedZone.extendedzone\virtualprivatecloud.folder\$resourceGroup.resourcegroup\$vNet.virtualprivatecloud\$subnet.network"}
```

For a complete ProvScheme example, see the [ProvScheme > Extended Zones](../../ProvScheme/Extended%20Zones) folder.

## Common Error Cases

**Inventory items shown as "Unknown Extended Zone" or no Extended Zones visible**: This may occur if your subscription is not registered for Extended Zones, the specific Extended Zone is not registered individually, or your service principal is missing the `Microsoft.EdgeZones/extendedZones/read` permission. Verify registration and permissions in the Azure Portal.

Documentation: https://docs.citrix.com/en-us/citrix-daas/install-configure/connections/connection-azure-resource-manager#azure-extended-zones