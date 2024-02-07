# Availability Zones
## Overview
Using MCS Provisioning, you can provision machines into specific Availability Zones in Azure environments. Availability Zones are physically separate datacenters within an Azure region. Each zone has its own power, cooling, & networking. If one zone experiences an outage, the other zones may still be operational. Zone names are typically numeric, i.e. Zone 1, 2, and 3. To learn more about Azure Availability Zones, refer to Azure's documentation: https://learn.microsoft.com/en-us/azure/reliability/availability-zones-overview?tabs=azure-cli

With MCS, you can specify one or more availability zones to provision your machines into. If more than one zone is provided, the machines are randomly distributed across the zones.

## Leading Practices
We suggest using this feature to distribute your VMs across all supported zones, i.e. 1, 2, 3. If this feature is not used, Azure decides how to assign the Zones based on zone health, capacity, etc. There is no guarantee that your VMs will be split across multiple zones. With this feature, you have more control over your VM's placement, and the VMs in your catalog will be distributed evenly across the zones. This means that if one Availability Zone has an outage, you will still have operational VMs in the other zone(s).

## Check if your Region supports Availability Zones for your desired ServiceOffering type
Using PowerShell, you can view the Citrix DaaS offering inventory items by using Get-Item. For example, to view the Eastern US region Standard_B1ls service offering:

```powershell
$serviceOffering = Get-Item -path "XDHyp:\Connections\my-connection-name\East US.region\serviceoffering.folder\Standard_B1ls.serviceoffering"
$serviceOffering.AdditionalData
```
To view the zones, use the AdditionalData parameter for the item. The AdditionalData has a key ServiceOfferingSupportedAvailabilityZones which indicates whether the ServiceOffering in that region supports Availability Zones.  
If ServiceOfferingSupportedAvailabilityZones is blank or empty, that means Availability Zones are not supported for that service offering in that region.

## How to use Availability Zones
To configure Availability Zones through PowerShell, use the `Zones` custom property available with the New-ProvScheme operation. The Zones property defines a list of Availability Zones to provision machines into; it can include one or more of the supported Availability Zones.
In this example, we specify Zones 1, 2, and 3.

```powershell
$customProperties = @"
<CustomProperties xmlns="http://schemas.citrix.com/2014/xd/machinecreation" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">
<Property xsi:type="StringProperty" Name="Zones" Value="1,2,3" />
</CustomProperties>
"@
```
**Note**: If no zones are specified, Azure will decide where to place the machines within the region. If more than one zone is specified, MCS randomly distributes the machines across the zones.

You can also change the Availability Zone configuration on an existing catalog using the Set-ProvScheme command. An example is provided in the Set-AvailabilityZones.ps1 script.

**Note**: The updated availability zones will be applicable to new machines post Set-ProvScheme, not to the existing machines. It is not yet supported on existing machines. 

## Common error cases
If a user enters invalid or unsupported zones, these errors will be caught early when running New-ProvScheme and will return helpful error messages.

1. If a user attempts to use zones for a service offering that does not support zones, they will receive an error: "Error: The availability zones are not supported in the given service offering."
2. If a service offering does support zones, but the user enters an invalid zone, they will receive an error: "Error: The availability zones requested by you are not valid. Please reenter a valid availability zone." 
3. If a user attempts to use zones without managed disks, they will receive an error: "Error: The virtual machines deployed to availability zones must use managed disks." This is a constraint on Azure's side, where you can only provision vms into a zone if the vms use managed disks.

Documentation: https://docs.citrix.com/en-us/citrix-daas/install-configure/machine-catalogs-create/create-machine-catalog-citrix-azure#configuring-availability-zones-through-powershell
