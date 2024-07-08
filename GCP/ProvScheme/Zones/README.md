# Catalog Zones
## Overview
Using MCS Provisioning, you can provision machines into specific Zones in GCP environments. Regions in GCP have three or more zones. Putting resources in different zones reduces the risk of an infrastructure outage affecting all resources simultaneously. Zones are denoted using the region name followed an alphabetical suffix (a, b, c...). For example, the us-west1 region has three zones: us-west1-a, us-west1-b, and us-west1-c. To learn more about GCP regions and zones, please refer to the [GCP documentation](https://cloud.google.com/compute/docs/regions-zones).

With MCS, you can specify one or more zones to provision your machines into. If more than one zone is provided, the machines are randomly distributed across the zones. If no zones are specified, machines are randomly distributed across all available zones in the region.
While distributing machines across zones, MCS also considers machine types, accelerators and storage types available in the given zone(s). 

## Check if your desired machine type is supported by the zone in the given region
Not not all machine types are available in all zones in a region. To check if a machine type is supported in a zone, please refer to the [Google Cloud documentation](https://cloud.google.com/compute/docs/regions-zones#available).


## How to use zones
To configure zones through PowerShell, use the `CatalogZones` custom property available for the New-ProvScheme operation. The CatalogZones property defines the list of zones to provision machines into. It can include one or more of the GCP supported zones.
The format should be "project-id:region:zone1". Multiple zones should be separated by a comma. For example, in the following snippet, we specify zones b and c for project my-project-id in region us-east1. 

```powershell
$customProperties = @"
<CustomProperties xmlns="http://schemas.citrix.com/2014/xd/machinecreation" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">
<Property xsi:type="StringProperty" Name="CatalogZones" Value="my-project-id:us-east1:b,my-project-id:us-east1:c" />
</CustomProperties>
"@
```

You can also change the zone configuration on an existing catalog using the Set-ProvScheme command. An example is provided in the Set-Catalog-Zone.ps1.ps1 script.

**Note**: The updated zones will be applicable to new machines post Set-ProvScheme, not to the existing machines. Updating zone of existing machines is not currently supported.

## Common error cases
* If the provided zone is invalid, the error message would be: "Cannot find or invalid zone(s) 'invalid-zone', Valid zones are: [list of valid zones in the region]".
* If the provided service offering is not supported in the zone, appropriate error message will be displayed.

Documentation: https://docs.citrix.com/en-us/citrix-daas/install-configure/machine-catalogs-create/create-machine-catalog-gcp
