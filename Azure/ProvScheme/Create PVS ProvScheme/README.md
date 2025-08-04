# PVS Catalog Creation with MCS Provisioning

This section explains how to create a **Citrix Provisioning Services (PVS) Provisioning Scheme (ProvScheme)** in **Citrix Virtual Apps and Desktops (CVAD)** using the `New-ProvScheme` PowerShell cmdlet.

The script [Create-PvsProvScheme.ps1](./Create-PvsProvScheme.ps1) provides an example of how to use `New-ProvScheme` to provision PVS catalogs.

To create a PVS provisioning scheme, use the script available at [Create-PvsProvScheme.ps1](../Create%20PVS%20ProvScheme/Create-PvsProvScheme.ps1).

## 1. Requirements for Azure

For **Citrix Virtual Apps and Desktops (CVAD)** users deploying on **Azure**, the following minimum versions are required:

| **Component**                             | **Supported Version** |
|------------------------------------------|-----------------------|
| CVAD Release for Studio UI               | 2402 and later        |
| CVAD Release for PowerShell              | 2402 and later        |
| Citrix Provisioning                      | 2402 and later        |

## 2. Key Steps

Follow these key steps to create a PVS catalog:

1. **Set up the PVS server**:  
   Install and configure the **Citrix Provisioning Services (PVS) server** to manage your provisioning infrastructure. Ensure all necessary components are installed and properly configured.

2. **Create a master target device**:  
   Set up a master target device, which will serve as the template for creating virtual machines for the catalog.

3. **Create a vDisk using the Imaging Wizard**:  
   Use the **Imaging Wizard** to create a virtual disk (vDisk) that stores the master image of your target device. This vDisk will be used to provision virtual machines.

4. **Create an Azure hosting connection**:  
   Set up an **Azure hosting connection** and hosting unit, just like you would for any MCS catalog in Citrix Virtual Apps and Desktops (CVAD). This connection will allow the provisioning of virtual machines in Azure.

5. **Run the PVS Configuration Wizard**:  
   Execute the **PVS Configuration Wizard** to register your PVS site with the CVAD site. This integration enables seamless communication and management between the two environments.


## 3. How to Retrieve PVS Site Details

Follow these steps to get the required details for your PVS site:

1. **Get the Site and Farm IDs**:  
   Use the `Get-HypPvsSite` command to retrieve the **Site ID** and the associated **Farm ID**.

2. **Get Store Details**:  
   Use the `Get-HypPvsStore` command to retrieve information about the PVS store, including its configuration and details.

3. **Retrieve vDisk Details**:  
   Using the **Farm ID**, **Store ID**, and **Site ID** obtained in the previous steps, use the `Get-HypPvsDiskInfo` command to retrieve detailed information about the vDisks available in the PVS site.

## 4. How to Use the `New-ProvScheme` PowerShell Command to Create a PVS ProvScheme

To create a PVS provisioning scheme, use the `New-ProvScheme` cmdlet with the appropriate parameters. Below is an example of how to specify the required parameters such as `-ProvisioningSchemeType`, `-PVSSite`, `-PVSvDisk`, `-MachineProfile`, and WriteBackCache settings:

```powershell
New-ProvScheme -CleanOnBoot:$isCleanOnBoot `
               -ProvisioningSchemeName $provisioningSchemeName `
               -ProvisioningSchemeType PVS `
               -PVSSite $pvsSite `
               -PVSvDisk $pvsVDisk `
               -HostingUnitName $hostingUnitName `
               -IdentityPoolName $identityPoolName `
               -InitialBatchSizeHint $numberOfVms `
               -MasterImageVM $masterImagePath `
               -NetworkMapping $networkMapping `
               -ServiceOffering $serviceOffering `
               -CustomProperties $sampleCustomProperties `
               -MachineProfile $sampleMachineProfilePath `
               -UseWriteBackCache `
               -WriteBackCacheDiskSize 32 `
               -WriteBackCacheDriveLetter "0" `
               -WriteBackCacheMemorySize 0
```

**Note**: For the correct syntax and more detailed examples, refer to the script [Create-PvsProvScheme.ps1](./Create-PvsProvScheme.ps1)

  
## 5. Limitations for Azure

When using **Azure** for Citrix Virtual Apps and Desktops (CVAD), the following limitations apply:

- Only **Generation 2 (Gen 2)** virtual machines (VMs) are supported.
- A catalog can only be created using a **machine profile**.
- **Hibernation** must **not** be enabled in the machine profile input.
- The following **custom properties cannot be set** when creating the catalog:
  - `StorageType`
  - `OsType`
  - `MachinesPerStorageAccount`
  - `StorageAccountsPerResourceGroup`
  - `UseSharedImageGallery`
  - `SharedImageGalleryReplicaRatio`
  - `SharedImageGalleryReplicaMaximum`
  - `UseEphemeralOsDisk`
  - `UseManagedDisks`
  - `StorageTypeAtShutdown`

Documentation:  
https://docs.citrix.com/en-us/provisioning/2402-ltsr/configure/citrix-provisioning-catalog-in-studio.html
