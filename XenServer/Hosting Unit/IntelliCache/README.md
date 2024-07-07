# Using the IntelliCache Feature of XenServer for Hosting Unit Creation

This page details the use of XenServer's IntelliCache feature for creating a Hosting Unit in Citrix Virtual Apps and Desktops (CVAD). The script `Create-HostingUnit-IntelliCache.ps1` shows an example usage of `New-Item` with the IntelliCache feature.



## 1. Understanding the IntelliCache Feature of XenServer

Intellicache caches temporary and non-persistent operating-system data on the local XenServer host. IntelliCache is available for Machine Creation Services (MCS)-based desktop workloads that use NFS storage. Intellicache enhances the performance of virtual machines by caching read requests locally, thus reducing the need to fetch data from shared storage repeatedly. This is especially beneficial in environments with high read operations. 

The figure below illustrates the differences in read and write operations between scenarios using IntelliCache and those not utilizing it:

<div align="center">
    <img src="https://support.citrix.com/files/public/support/article/CTX222322/images/0EM60000000DtEP.png" width="500" height="300"> 
</div>

Below is a summary of the trade-offs of using IntelliCache:

- **Advantages of Using Intellicache:** 
    - Reduced network traffic due to frequent read operations from shared storage.
    - Improves read performance for virtual machines.
    
- **Disadvantages of Using Intellicache:** 
    - Increased usage and reliance on local storage.
    - Potentially complex storage configuration and management.



## 2. Understanding the PowerShell Cmdlet for the IntelliCache Feature

To enable the IntelliCache feature, set **UseLocalStorageCaching** parameter of the **New-Item** cmdlet in the Step 3, Creating a Network Resource, as shown below.

```powershell
New-Item `
    -UseLocalStorageCaching `
    -HypervisorConnectionName $ConnectionName `
    # Additional  Parameters...
```



## 3. Example Full Scripts Utilizing IntelliCache.

1. [Creation of a Hosting Connection and associated resources with IntelliCache](../../Hosting%20Connection/Add%20Hosting%20Connection/Add-HostingConnection-IntelliCache.ps1)
2. [Creation of a Hosting Unit with IntelliCache](../Add%20Hosting%20Unit/Add-HostingUnit-IntelliCache.ps1)



## 4. Reference Documents

For more detailed information on XenServer's virtual GPU (vGPU) features, please refer the pages below.
1. [XenServer Documentation - What is IntelliCache?](https://docs.xenserver.com/en-us/citrix-hypervisor/storage/intellicache.html)


