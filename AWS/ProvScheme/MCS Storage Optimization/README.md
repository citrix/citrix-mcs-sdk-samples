# MCS Storage Optimization
## Overview
When using MCS to manage random non-persistent machines in a catalog, you can enable write-back cache for machines to improve I/O performance.  
Write-back cache is referred to as MCSIO. For more information, see these blog articles:

https://www.citrix.com/blogs/2016/08/03/introducing-mcs-storage-optimisation

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
You can use write-back cache by using the `UseWriteBackCache` parameter along with a required parameters `WriteBackCacheDiskSize` parameter and `WriteBackCacheMemorySize`. Temporary data is initially written to the memory cache. When the memory cache reaches its configured limit, the oldest data is moved to the temporary data cache disk.
Parameter `WriteBackCacheDriveLetter` is optional and is a customized drive letter of write-back cache disk which can be any character between ‘E’ and ‘Z’. If not specified, the drive letter is auto assigned by operating system.  
For details on how to configure the write-back cache to suit your solutions, check out the [Configure cache for temporary data](https://docs.citrix.com/en-us/citrix-daas/install-configure/machine-catalogs-create.html#configure-cache-for-temporary-data) page.  

[Create-MCSIO-ProvScheme.ps1](Create-MCSIO-ProvScheme.ps1) gives a simple example on how to enable write-cache on your catalog.

There are other customizations that can be done on a catalog that has write-back cache enabled.

**Persisting Write-Back Cache disk**: Persist the write back cache disk for the non-persistent provisioned virtual machine between power cycles. Specify either True or False. If this property is not specified or set to False, the write back cache disk is deleted when the virtual machine is shut down, and is re-created when the virtual machine is powered on.  
For example:
```powershell
$customProperties = "PersistWBC,True;"
```
**Persisting OS disk**: Persist the OS disk for the non-persistent provisioned virtual machine between power cycles. Specify either True or False. If this property is not specified or set to False, the OS Disk is deleted when the virtual machine is shut down, and is re-created when the virtual machine is powered on.
For example:
```powershell
$customProperties = "PersistOSDisk,True;"
```

**Write Back Cache Disk Volume Properties**: WBC Disk Storage Type controls the AWS Volume Type and settings for the Write Back Cache Disk. It defines the volume type which is used for the temporary disk in AWS. This parameter takes a string argument in the following format: ``` volume-type[:iops][:throughput] ```

For example:
```powershell
$customProperties = "WBCDiskStorageType,gp3:3000:135;"
```

[Create-MCSIO-ProvScheme-PersistWbc.ps1](Create-MCSIO-ProvScheme-.ps1) has an example script on how to persist write-back cache and os disk on a vm shutdown. It also defines WBC storage type.

Documentation: https://docs.citrix.com/en-us/citrix-daas/install-configure/machine-catalogs-create.html#machine-creation-services-mcs-storage-optimization 