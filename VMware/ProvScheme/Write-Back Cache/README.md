# Using Write-Back Cache Feature of VMware for Machine Catalog Creation

This page describes the use of VMware's Write-Back Cache feature while creating a ProvScheme in Citrix Virtual Apps and Desktops (CVAD). The script `Create-ProvScheme-WriteBackCache.ps1` shows an example usage of `New-ProvScheme` with the Write-Back Cache feature.



## 1. Understanding the Write-Back Cache Feature of VMware

Write-Back Cache is designed to improve the performance of VMs by providing a temporary storage for write operations. When changes are made to a non-persistent VM (like installing software or modifying settings), these changes are written to the Write-Back Cache. This improves performance because writing to the cache is faster than writing to the base storage location.   

Below is a summary of the trade-offs of using Write-Back Cache:

- **Advantages of Using Write-Back Cache:** 
    - **Enhanced Performance**: Improves write operation speeds, beneficial for write-intensive tasks.
    - **Reduced Load on the Base Storage**: Decreases the demand on the base storage by handling write operations locally.
    - **Improved User Experience**: Can lead to faster application response times and overall smoother user interactions.

- **Disadvantages of Using Write-Back Cache:** 
    - **Additional Cost and Complexity**: Requires extra storage space, potentially increasing costs and complexity in storage manangement.
    - **Data Non-Persistence**: Data in the cache is not retained after a VM reset, which might not suit environments needing data persistence.



## 2. Understanding the Concise Script using Write-Back Cache Feature

To enable the Write-Back Cache feature, the  **New-ProvScheme** cmdlet requires the configuration of five key parameters: **CleanOnBoot**, **UseWriteBackCache**, **WriteBackCacheDiskSize**, **WriteBackCacheMemorySize**, and **WriteBackCacheDriveLetter**. These parameters are essential for activating and customizing the Write-Back Cache functionality as detailed below.

```powershell
New-ProvScheme `
    -ProvisioningSchemeName "MyMachineCatalog" `
    # Additional  Parameters... `
    -CleanOnBoot `
    -UseWriteBackCache `
    -WriteBackCacheDiskSize 128 `
    -WriteBackCacheMemorySize 256 `
    -WriteBackCacheDriveLetter "W"
```


## 3. Example Full Scripts Utilizing Write-Back Cache.

1. [Creation of a Machine Catalog with Write-Back Cache](../../SampleAdminScenarios/Add%20Machine%20Catalog/Add-MachineCatalog-WriteBackCache.ps1)



## 4. Reference Documents

For comprehensive information and further reading, the following resources are recommended. These include CVAD SDK documentation and other relevant references (as applicable):

1. [Selecting the write cache destination for standard virtual disk images](https://docs.citrix.com/en-us/provisioning/current-release/manage/managing-vdisks/write-cache.html)


