# MCS Storage Optimization
## Overview
When using MCS to manage random non-persistent machines in a catalog, you can enable write-back cache for machines to improve I/O performance.  
Write-back cache is referred to as MCSIO. For more information, see these blog articles:

https://www.citrix.com/blogs/2016/08/03/introducing-mcs-storage-optimisation

https://www.citrix.com/blogs/2020/04/22/enable-persist-write-back-cache-for-mcs-pooled-catalog-in-azure-part-1/

## Prerequisites
VDAs must be higher than 7.9 (we suggest 7.15+) and installed with a current MCSIO driver. Installing this driver is an option when you install or upgrade a VDA. By default, that driver isn’t installed.  
To enable drive letter assignment for disk caches, the Operating System must be Windows and the VDA version must be 2305 or later.

## Leading Practices
We suggest using MCS Storage Optimization for non-persistent catalogs that are ready/write-heavy. 

The required write-back cache disk storage depends on the use case. As a starting point, consider the following configuration for a medium workload:
* Desktop: 15 GB
* Server: 40-60 GB

Similarly, the RAM cache usage depends on the use case as well. As a starting point, consider the following configuration for a medium workload:
* Desktop: 512 MB
* Server: 4-8 GB

You can start with these settings and test to find the ideal configuration based on your workload. For more information on leading practices, refer to the "Disk Cache" and "RAM Cache" sections of the Citrix VDI Handbook: https://docs.citrix.com/en-us/xenapp-and-xendesktop/7-15-ltsr/downloads/Citrix%20VDI%20Handbook%207.15%20LTSR.pdf

## How to use Write-Back Cache
You can use write-back cache by using the `UseWriteBackCache` parameter along with a required `WriteBackCacheDiskSize` parameter.  
Parameter `WriteBackCacheMemorySize` is optional but recommended where temporary data is initially written to the memory cache. When the memory cache reaches its configured limit, the oldest data is moved to the temporary data cache disk. We recommend using WriteBackCacheMemorySize and WriteBackCacheDiskSize together. 
Parameter `WriteBackCacheDriveLetter` is optional and is a customized drive letter of write-back cache disk which can be any character between ‘E’ and ‘Z’. If not specified, the drive letter is auto assigned by operating system.  
For details on how to configure the write-back cache to suit your solutions, check out the [Configure cache for temporary data](https://docs.citrix.com/en-us/citrix-daas/install-configure/machine-catalogs-create.html#configure-cache-for-temporary-data) page.  

[Create-MCSIO.ps1](Create-MCSIO.ps1) gives a simple example on how to enable write-cache on your catalog.

There are other customizations that can be done on a catalog that has write-back cache enabled.

**Using Temporary disk**: Indicates whether to use Azure temporary storage to store write back cache file. Specify either True or False. If this property is not specified, the UseTempDiskForWBC parameter is set to False by default.  
For example:
```powershell
$customProperties = @"
<CustomProperties xmlns="http://schemas.citrix.com/2014/xd/machinecreation" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">
<Property xsi:type="StringProperty" Name="UseTempDiskForWBC" Value="true" />
</CustomProperties>
"@
```
[Create-MCSIO-TempStorage.ps1](Create-MCSIO-TempStorage.ps1) has an example script on how to use Azure Temporary storage for write-back cache.

**Persisting Write-Back Cache disk**: Persist the write back cache disk for the non-persistent provisioned virtual machine between power cycles. Specify either True or False. If this property is not specified, the write back cache disk is deleted when the virtual machine is shut down, and is re-created when the virtual machine is powered on.  
For example:
```powershell
$customProperties = @"
<CustomProperties xmlns="http://schemas.citrix.com/2014/xd/machinecreation" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">
<Property xsi:type="StringProperty" Name="PersistWBC" Value="true" />
</CustomProperties>
"@
```
[Create-MCSIO-PersistWbc.ps1](Create-MCSIO-PersistWbc.ps1) has an example script on how to persist write-back cache on a vm shutdown.

Documentation: https://docs.citrix.com/en-us/citrix-daas/install-configure/machine-catalogs-create.html#machine-creation-services-mcs-storage-optimization 