# Ephemeral OS Disks (UseEphemeralOsDisks)
## Overview
Using MCS Provisioning, you can provision machines using Ephemeral OS Disks in Azure environments. With Ephemeral OS Disks, your OS Disk will be stored on the cache or temporary disk. The cache disk is preferred, but the temporary disk will be used if the cache disk does not have enough space. More information on this feature can be found [here][Documentation].

To learn more about Azure Ephemeral OsDisks, refer to Azure's documentation: https://learn.microsoft.com/en-us/azure/virtual-machines/ephemeral-os-disks 

## Requirements & Limitations
1. Only supported with Azure Managed Disks. 
2. Only supported when the `UseSharedImageGallery` custom property is set to true. Your mastered image must be stored in an Azure Compute Gallery (ACG).  **Note:** An ACG is also known as a Shared Image Gallery (SIG).
3. Only supported for some Azure Service Offerings. When choosing your machine size, ensure that the cache disk or temp disk is large enough to store a 127 GiB OS Disk.
4. Cannot be used with MCSIO. 
5. Cannot be used with Azure Hibernation/sleep capability.

## Leading Practices
If your Azure Service Offering supports it, we suggest using Ephemeral OS Disks for non-persistent catalogs. Ephemeral OS Disks offer lower read/write latency and help save on storage costs. 

## Check if your Service Offering supports Ephemeral OS Disks
Using PowerShell, you can view the Citrix DaaS offering inventory items by using Get-Item. For example, to view the Eastern US region Standard_D8s_v3 service offering: 

```powershell
$serviceOffering = Get-Item -path "XDHyp:\Connections\my-connection-name\East US.region\serviceoffering.folder\Standard_D8s_v3.serviceoffering"
$serviceOffering.AdditionalData
```
To view the ephemeral OS Disk support, use the AdditionalData parameter for the item. The AdditionalData has a key *SupportsEphemeralOSDisk* which indicates whether the ServiceOffering in that region supports ephemeral OS Disk. If *SupportsEphemeralOSDisk* is false, that means ephemeral OS Disks are not supported for that service offering in that region.

## How to use Ephemeral OS Disks
To configure ephemeral OS Disks through PowerShell, use the `UseEphemeralOsDisks` custom property available with the New-ProvScheme operation. The UseEphemeralOsDisks property is a boolean.

Ephemeral OS Disks require managed disks (`UseManagedDisks`) and an Azure Compute Gallery (`UseSharedImageGallery`). In this example, we set UseEphemeralOsDisks, UseManagedDisks, and UseSharedImageGallery to True:
```powershell
$customProperties = @"
<CustomProperties xmlns="http://schemas.citrix.com/2014/xd/machinecreation" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">
roperty xsi:type="StringProperty" Name="UseManagedDisks" Value="true" />
roperty xsi:type="StringProperty" Name="UseSharedImageGallery" Value="true" />
<Property xsi:type="StringProperty" Name="UseEphemeralOsDisks" Value="true" />
</CustomProperties>
"@
```
**Note:** You cannot change the UseEphemeralOsDisk custom property on an existing catalog and VMs. 

## Common error cases
If an invalid configuration is specified, errors will be caught early when running New-ProvScheme and will return helpful error messages.

1. If a user attempts to use ephemeral OS Disks for a service offering that does not support it, they will receive an error: "The machine size: 'xxx' does not support Ephemeral OS Disks."
2. If a user attempts to use ephemeral OS Disks with MCSIO, they will receive an error: "Error: MCSIO and ephemeral OS disk cannot be enabled at the same time." 
3. If the cache disk and temp disk do not have enough space to store the OS Disk, the user will receive an error: "Ephemeral OS disks can be used only with machines that have a cache disk or temp disk that is larger than the master image disk. A 'xxx' machine has a 'xxx' GB cache disk and a 'xxx' GB temp disk, but the master image is 'xxx' GB."

Documentation: https://docs.citrix.com/en-us/citrix-daas/install-configure/machine-catalogs-create/create-machine-catalog-citrix-azure.html#azure-ephemeral-disk

[Documentation]: < https://docs.citrix.com/en-us/citrix-daas/install-configure/machine-catalogs-create/create-machine-catalog-citrix-azure.html#azure-ephemeral-disk >