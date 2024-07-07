# Using Fast Clone and Full Clone Features of VMware for Machine Catalog Creation

This page describes the use of VMware's Full Clone feature while creating a ProvScheme in Citrix Virtual Apps and Desktops (CVAD). The script `Create-ProvScheme-FullClone.ps1` shows an example usage of `New-ProvScheme` with the Full Clone feature.



## 1. Understanding the Fast Clone and Full Clone Features

When setting up a static desktop on a dedicated virtual machine with local disk changes saved, Machine Creation Service (MCS) offers two disk types: partially cloned disk (so-called Fast Clone) and fully cloned disk (so-called Full Clone). 

- **Fast Clone:**
    - **Desription:** MCS creates a difference disk for each VM. Write operations are directed to this difference disk. However, the base disk is shared among all VMs, meaning that all read operations are conducted on this common base disk. The figure below illustrates the architecture. 

    <img src="https://support.citrix.com/files/public/support/article/CTX224040/images/0EM600000001XgN.png" width="500" height="300"> 

    - **Trade-Offs:** This approach leads to more efficient storage utilization and quicker machine creation times. Because the base disk is shared, there could be potential performance impacts due to disk IO contention.


- **Full Clone:**
    - **Desription:** This is a complete copy of the base disk. Every read and write operation by the Virtual Machine (VM) is directed to this fully cloned disk, ensuring independent disk operations. The figure below illustrates the architecture. 

    <img src="https://support.citrix.com/files/public/support/article/CTX224040/images/0EM600000001Xgc.png" width="500" height="300"> 
    
    - **Trade-Offs:** Provides enhanced performance due to the absence of shared base disks, minimizing potential resource contention and resulting in better Input/Output Operations Per Second (IOPS). However, as each VM requires a full copy of all data, it will consueme more storage space and take longer time to create and deploy each VM.



## 2. Understanding the Concise Script using Full Clone Feature

To enable Full Clone, set the **UseFullDiskCloneProvisoning** parameter in the **New-ProvScheme** cmdlet as shown below:

```powershell
New-ProvScheme `
    -ProvisioningSchemeName "MyMachineCatalog" `
    # Additional  Parameters... `
    -UseFullDiskCloneProvisoning
```

**UseFullDiskCloneProvisioning** indicates whether VMs should be created using the dedicated full disk clone feature. By default, the Fast Clone approach is used unless this parameter is explicitly set to enable Full Clone.



## 3. Example Full Scripts Utilizing Full Clone.

1. [Creation of a Machine Catalog with Full Clone](../../SampleAdminScenarios/Add%20Machine%20Catalog/Add-MachineCatalog-FullClone.ps1)



## 4. Reference Documents

For comprehensive information and further reading, the following resources are recommended. These include CVAD SDK documentation and other relevant references (as applicable):

1. [Difference between Fast Clone and Full Clone
](https://support.citrix.com/article/CTX224040/difference-between-fast-clone-and-full-clone)

