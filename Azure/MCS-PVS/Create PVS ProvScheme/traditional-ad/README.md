# PVS Catalog Creation with MCS Provisioning (Traditional AD)

This section explains how to create a **Citrix Provisioning Services (PVS) Provisioning Scheme (ProvScheme)** in **Citrix Virtual Apps and Desktops (CVAD)** for **local Active Directory–joined** catalogs.

The script [`Create-PvsProvScheme-TraditionalAD.ps1`](./Create-PvsProvScheme-TraditionalAD.ps1) provides an example of how to use `New-ProvScheme` to provision PVS catalogs.

To create a PVS provisioning scheme, use the script available at:  
[`Create-PvsProvScheme-TraditionalAD.ps1`](./Create-PvsProvScheme-TraditionalAD.ps1).

---

## 1. Requirements for Azure

For **Citrix Virtual Apps and Desktops (CVAD) / on‑premises** and **Citrix DaaS (Citrix Cloud)** deployments on **Azure**, the minimum supported versions are **CVAD 2402 and later** and **Citrix Provisioning (PVS) 2402 and later**.

> Reference:  
> Citrix Provisioning catalog in Studio (2402 LTSR):  
> https://docs.citrix.com/en-us/provisioning/2402-ltsr/configure/citrix-provisioning-catalog-in-studio.html  

---

## 2. Key Steps

Follow these key steps to create a PVS catalog. Each step below expands into the concrete configuration actions required in a Citrix Provisioning + CVAD / DaaS environment.

1. Set up the PVS server  
2. Create the master image and base vDisk  
3. Create an Azure hosting connection and hosting unit  
4. Run the PVS Configuration Wizard to join CVAD/DaaS  
5. Retrieve PVS site details  
6. Review limitations for Azure  

---

## 2.1 Set up the PVS server

Install and configure the **Citrix Provisioning Services (PVS) server** that will host your PVS farm and stream vDisks to target devices.

> Reference:  
> Install Citrix Provisioning software components:  
> https://docs.citrix.com/en-us/provisioning/2402-ltsr/install.html  

### 2.1.1 Prepare infrastructure

- Ensure:
  - Supported Windows Server OS for the PVS server.
  - Network connectivity to:
    - SQL Server (for the PVS database)
    - Active Directory domain controllers
    - Hypervisor / Azure networks where targets will run
  - Required firewall ports are open (PVS streaming, SOAP, SQL, etc.).

### 2.1.2 Install PVS server components

1. Mount or extract the **Citrix Provisioning** installation media.
2. Run the **Citrix Provisioning Server** setup.
3. Install:
   - **Provisioning Services** (server)
4. Provide:
   - SQL Server name / instance and credentials (or Windows auth)
   - Database name (new or existing)
5. Complete the installation and reboot if prompted.

### 2.1.3 Install the PVS console

Install the **Citrix Provisioning Console** on the PVS server and/or an admin workstation so that PVS can be managed remotely.

---

## 2.2 Create the Master Image and Base vDisk

Prepare the **master target device** (golden image) and capture it into a **vDisk** that will be streamed by PVS.

- Ensure sufficient storage on the PVS vDisk volume (respect NTFS/FAT size limits).
- Install a supported Windows OS, apply updates, and configure basic settings.
- Install **Citrix VDA**, required applications, and **Citrix Provisioning Target Device** software.
- Use the **Imaging Wizard** to capture the master device into a vDisk.

> References:  
> - Preparing the master target device:  
>   https://docs.citrix.com/en-us/provisioning/2402-ltsr/install/target-image-prepare  
> - Create and configure vDisks:  
>   https://docs.citrix.com/en-us/provisioning/2402-ltsr/configure/configure-vdisks/vdisk-create  
> - Using the Imaging Wizard:  
>   https://docs.citrix.com/en-us/provisioning/current-release/install/vdisks-image-wizard.html  

---

## 2.3 Create an Azure Hosting Connection and Hosting Unit

Set up an **Azure hosting connection and hosting unit** in Studio / Web Studio, just as you would for an MCS catalog in Citrix Virtual Apps and Desktops (CVAD). This connection will allow the provisioning of virtual machines in Azure.

> Reference:  
> Create and manage connections and resources (CVAD):  
> https://docs.citrix.com/en-us/citrix-virtual-apps-desktops/install-configure/connections/connection-azure-local

---

## 2.4 Run the PVS Configuration Wizard to join PVS farm to CVAD/DaaS

Run the PVS Configuration Wizard on every PVS Server in the farm to join the PVS farm to a CVAD/Citrix DaaS site. This step:

- Registers the PVS farm with CVAD/DaaS.
- Enables Studio / Web Studio to discover the PVS farm, sites, stores, and vDisks.

> Reference:  
> Join Citrix Cloud or Citrix Virtual Apps and Desktops site:  
> https://docs.citrix.com/en-us/provisioning/2402-ltsr/configure/farm-configure-new#join-citrix-cloud-or-citrix-virtual-apps-and-desktops-site  

---

## 2.5 How to Retrieve PVS Site Details

Use the CVAD/DaaS PowerShell SDK to retrieve PVS details that are required when creating the PVS catalog. The PVS site and VDisk information is required in the script [`Create-PvsProvScheme-TraditionalAD.ps1`](./Create-PvsProvScheme-TraditionalAD.ps1)

1. **Get the Site and Farm IDs**  
   Use `Get-HypPvsSite` to retrieve the **Site ID** and associated **Farm ID**.

2. **Get Store Details**  
   Use `Get-HypPvsStore` to retrieve PVS store information (configuration and IDs).

3. **Retrieve vDisk Details**  
   Using the **Farm ID**, **Store ID**, and **Site ID**, use `Get-HypPvsDiskInfo` to retrieve detailed information about vDisks.

> References:  
> https://developer-docs.citrix.com/en-us/citrix-virtual-apps-desktops-sdk/2402/hostservice/get-hyppvssite  
> https://developer-docs.citrix.com/en-us/citrix-virtual-apps-desktops-sdk/2402/HostService/Get-HypPvsStore.html  
> https://developer-docs.citrix.com/en-us/citrix-virtual-apps-desktops-sdk/2402/hostservice/get-hyppvsdiskinfo  

---

## 2.6 Limitations for Azure

When using **Azure** for Citrix Virtual Apps and Desktops (CVAD) / DaaS with PVS catalogs:

- Only **Generation 2 (Gen 2)** virtual machines (VMs) are supported.
- A catalog can only be created using a **machine profile**.
> The machine profile is used only to define the Azure hardware configuration, such as the VM size, vCPU/RAM allocation, NIC configuration, and related settings. When the VM boots, the operating system is streamed from the PVS vDisk, with the machine starting through the BDM (Boot Device Manager) disk.
- **Hibernation** must **not** be enabled in the machine profile input.
- The following **custom properties cannot be set** when creating the catalog:
  - `StorageType`
  > By default, the storage type used for the identity disk and OS disk (BDM disk) in an MCS PVS catalog is Standard SSD. This is configured at the lowest possible cost in Azure for such small disks.
  - `OsType`
  - `MachinesPerStorageAccount`
  - `StorageAccountsPerResourceGroup`
  - `UseSharedImageGallery`
  - `SharedImageGalleryReplicaRatio`
  - `SharedImageGalleryReplicaMaximum`
  - `UseEphemeralOsDisk`
  - `UseManagedDisks`
  - `StorageTypeAtShutdown`

> Reference:  
> Citrix Provisioning catalog in Studio (limitations for Azure):  
> https://docs.citrix.com/en-us/provisioning/2402-ltsr/configure/citrix-provisioning-catalog-in-studio.html  
