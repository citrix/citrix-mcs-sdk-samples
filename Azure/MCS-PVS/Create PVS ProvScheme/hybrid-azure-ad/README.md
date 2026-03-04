# PVS Catalog Creation with MCS Provisioning (Hybrid Azure AD)

This section explains how to create a **Citrix Provisioning Services (PVS) Provisioning Scheme (ProvScheme)** in **Citrix Virtual Apps and Desktops (CVAD)** / **Citrix DaaS** for **Hybrid Azure AD–joined** catalogs hosted in **Azure**.

A **Hybrid Azure AD joined catalog** provides:

- Traditional **on‑premises Active Directory (AD)** computer accounts, and  
- **Hybrid Azure AD join** to Microsoft Entra ID (Azure AD) for modern authentication, Conditional Access, and Intune device management.

The script [`Create-PvsProvScheme-HybridAzureAD.ps1`](./Create-PvsProvScheme-HybridAzureAD.ps1) provides an example of how to use `New-ProvScheme` and related MCS cmdlets to provision PVS‑backed Hybrid Azure AD joined catalogs.

To create a PVS provisioning scheme, use the script available at:  
[`Create-PvsProvScheme-HybridAzureAD.ps1`](./Create-PvsProvScheme-HybridAzureAD.ps1).

---

## 1. Requirements for Azure

For **Citrix Virtual Apps and Desktops (CVAD)** on‑premises users deploying on **Azure**, the following minimum versions are required:

| **Component**                             | **Supported Version** |
|------------------------------------------|-----------------------|
| CVAD Release for Studio UI               | 2402 and later        |
| CVAD Release for PowerShell              | 2402 and later        |
| Citrix Provisioning                      | 2402 and later        |

For **Citrix DaaS (Citrix Cloud)** users deploying on Azure, the following minimum versions are required:

| **Component**                             | **Supported Version** |
|------------------------------------------|-----------------------|
| Citrix Provisioning                      | 2402 and later        |

See the PVS catalog creation and Azure support/limitations sections in the Citrix Provisioning catalog in Studio documentation.

---

## 2. Key Steps

Follow these key steps to create a **Hybrid Azure AD joined** PVS catalog. Each step below expands into the concrete configuration actions required in a Citrix Provisioning + CVAD / DaaS environment.

1. **Set up Hybrid Azure AD (Microsoft Entra hybrid join)**
2. **Set up Citrix Provisioning**
3. **Create and prepare the master target device**
4. **Run the Imaging Wizard to create a vDisk (Hybrid Azure AD optimized)**
5. **Run the PVS Configuration Wizard (join PVS to CVAD / DaaS)**
6. **Create an Azure hosting connection**
7. **Retrieve PVS site, store, and vDisk details (PowerShell)**
8. **Create a Hybrid Azure AD joined catalog (Studio UI or PowerShell)**

---

## 3. Set up Hybrid Azure AD

Before creating the catalog, configure **Hybrid Azure AD** in your environment.

At a high level:

- Enable **Microsoft Entra hybrid join** using **Microsoft Entra Connect Sync** on a server joined to your on‑prem AD.
- Ensure:
  - On‑prem AD is synchronized to Azure AD.
  - Devices in the target OU can become **Hybrid Azure AD joined** (proper OU scoping, sync rules, etc.).
  - Required Microsoft Entra endpoints are reachable from the VMs.

Hybrid Azure AD joined catalog prerequisites and environment details are described in the **Create Hybrid Azure AD joined catalogs** documentation.

---

## 4. Set up Citrix Provisioning

Install and configure the **Citrix Provisioning Services (PVS) server** that will host your PVS farm and stream vDisks to target devices.

At a minimum:

- Deploy PVS servers and the PVS console.
- Configure the PVS database (SQL), sites, and stores.
- Ensure connectivity to:
  - SQL Server
  - Active Directory domain controllers
  - Azure vNet(s) where targets will run
- Open required firewall ports (PVS streaming, SOAP, SQL, etc.).

Detailed installation and configuration steps are available in the **Citrix Provisioning 2402 LTSR** documentation.

---

## 5. Create and Prepare the Master Image

This step covers preparing the **master target device** (golden image) that will be captured into a vDisk and streamed by PVS, with **Hybrid Azure AD join** in mind.

A **vDisk** is built from this master image and later streamed to one or more target devices.

> **Important**  
> Citrix Provisioning only supports **automated vDisk capture**. The recommended capture method is the **Imaging Wizard**.

### 5.1 Plan the vDisk and image

Before building the image:

- Ensure sufficient free space on the PVS server or shared storage that will hold the vDisk.
- The volume that stores vDisks must be:
  - **NTFS** – maximum VHDX size ≈ **2 TB**
  - **FAT** – maximum VHDX size ≈ **4,096 MB**
- Plan the lifecycle:
  - Build and test the vDisk as a **Private Image**.
  - Convert to **Standard Image** for production, shared use.

### 5.2 Prepare the master target device

The master target device is the **golden image** source for the vDisk.

1. **Install the OS and base configuration**
   - Install a supported Windows OS (Server or Desktop) on a physical or virtual machine.
   - Apply:
     - Latest OS updates and patches.
     - Required language / regional settings.
   - Configure system settings (time zone, security baseline, etc.).

2. **Install required components**
   - Install **Citrix VDA** (supported version for CVAD/DaaS + Azure + Hybrid join).
   - Install **Citrix Provisioning Target Device** software and reboot when prompted.

3. **Install required applications**
   - Install all applications that must be in the base image:
     - Line‑of‑business applications.
     - Productivity tools.
     - Security / monitoring agents.
   - Configure application settings as needed.

4. **Ensure the master is not pre‑joined to Azure AD**
   - If the device is already Azure AD or Hybrid Azure AD joined, run:
     ```powershell
     dsregcmd /leave
     ```
   - This ensures the master image is **not** pre‑joined to Azure AD before capture; the Hybrid join will be performed on the provisioned VMs.

Hybrid‑specific master image requirements and general target image preparation are described in the **Create Hybrid Azure AD joined catalogs** and **Install** sections of the Citrix Provisioning documentation.

---

## 6. Create the Base vDisk (Hybrid Azure AD Optimized)

This step covers creating the **base vDisk** that will hold the captured master image, with settings optimized for Hybrid Azure AD join.

A vDisk is stored as:

- A **VHDX base image** file  
- A `.pvp` properties file  
- Optionally, one or more differencing disks (`.avhdx`) if vDisk versioning is used  

A vDisk can be:

- **Standard Image** – shared by many target devices  
- **Private Image** – dedicated to a single target device  

> **Important**  
> The **Cache on hard disk** option currently appears in the product but **does not function**.

### 6.1 Create the base vDisk (recommended: Imaging Wizard)

The **Imaging Wizard** is the recommended method for creating a base vDisk and includes an option to optimize for Hybrid Azure AD join.

1. **Ensure the master target device is ready**
   - OS, drivers, and apps installed.
   - PVS Target Device software installed.
   - Device is **not** currently Hybrid Azure AD joined (`dsregcmd /status`).

2. **Run the Imaging Wizard**
   - Log on to the master target device.
   - Launch the **Citrix Provisioning Imaging Wizard**.
   - Connect to the PVS farm:
     - Specify the PVS server.
     - Select the **Farm**, **Site**, and **Store** where the new vDisk will reside.

3. **Enable Hybrid Azure AD optimization**
   - When the **Edit Optimization Settings** dialog appears:
     - Select **Prepare for Hybrid Azure AD join**.
   - This optimization ensures the vDisk and resulting VMs are correctly prepared for Hybrid Azure AD join.

4. **Create the vDisk file**
   - The wizard automatically:
     - Creates a new **VHDX vDisk** file in the selected store.
     - Registers the vDisk with the chosen site/store.

5. **Capture the master image**
   - In the wizard:
     - Select the local system disk to capture (typically `C:`).
     - Start the imaging process.
   - The wizard:
     - Copies the contents of the master disk into the vDisk.
     - Configures the target device to boot from this vDisk.

6. **Validate and convert to Standard Image**
   - Boot the master device from the new vDisk in **Private Image** mode.
   - Validate:
     - OS boots correctly.
     - Applications work as expected.
   - In the PVS console:
     - Change the vDisk **Access Mode** from **Private** to **Standard Image** when ready to share.
     - Configure the desired **cache type** (for example, cache on device hard disk or cache in RAM, depending on your design).

The Hybrid‑specific Imaging Wizard flow and vDisk configuration are described in the **Create Hybrid Azure AD joined catalogs** documentation.

---

## 7. Run the PVS Configuration Wizard

Run the **PVS Configuration Wizard** to register your PVS site with Citrix Cloud (DaaS) or a CVAD site. This integration enables Studio / Web Studio and PowerShell to discover PVS sites, stores, and vDisks.

The farm configuration and integration steps are documented in the Citrix Provisioning 2402 LTSR product documentation.

---

## 8. Create an Azure Hosting Connection

Set up an **Azure hosting connection and hosting unit** in Studio / Web Studio, just as you would for an MCS catalog in Citrix Virtual Apps and Desktops (CVAD). This connection will allow the provisioning of virtual machines in Azure.

- Configure:
  - Subscription, resource group(s), and region.
  - Virtual network and subnet.
  - Machine profile (Gen2 VM, correct OS, no hibernation).

The hosting connection and PVS catalog creation workflow in Studio are described in the **Citrix Provisioning catalog in Studio** documentation.

---

## 9. How to Retrieve PVS Site Details (for MCS / PowerShell)

When automating catalog creation (for example, in `Create-PvsProvScheme-HybridAzureAD.ps1`), you need PVS site, store, and vDisk details.

Typical steps (using Citrix DaaS / CVAD PowerShell SDK):

1. **Get the PVS Site and Farm IDs**  
   Use `Get-HypPvsSite` to retrieve the **Site ID** and the associated **Farm ID**.

2. **Get Store Details**  
   Use `Get-HypPvsStore` to retrieve information about the PVS store, including its configuration and details.

3. **Retrieve vDisk Details**  
   Using the **Farm ID**, **Store ID**, and **Site ID** obtained in the previous steps, use `Get-HypPvsDiskInfo` to retrieve detailed information about the vDisks available in the PVS site.

These cmdlets are part of the Citrix DaaS / CVAD PowerShell SDK and are used consistently for both Local AD and Hybrid Azure AD PVS catalogs.

---

## 10. Create a Hybrid Azure AD Joined Catalog

Once the PVS farm is registered, the Azure hosting connection is configured, and the vDisk is ready, you can create a **Hybrid Azure AD joined** PVS catalog using:

- The **Citrix Provisioning catalog workflow in Studio**, or  
- **PowerShell** (as in `Create-PvsProvScheme-HybridAzureAD.ps1`).

### 10.1 Creating the catalog using Studio UI

If using Studio UI (DaaS or supported CVAD builds):

1. In Studio / Web Studio, start the **Create Catalog** wizard and choose **Citrix Provisioning** as the provisioning type.  
2. Follow the workflow to:
   - Select the PVS site, store, and vDisk.
   - Select the Azure hosting connection and machine profile.
3. On the **Machine Identities** page:
   - Select **Hybrid Azure Active Directory joined**.

> **Note**  
> The **Hybrid Azure Active Directory joined** option is available for Citrix Virtual Apps and Desktops customers from **2402 LTSR CU3** (and corresponding supported DaaS builds).

The PVS catalog creation flow and Hybrid Azure AD identity option are documented in the **Citrix Provisioning catalog in Studio** article.

### 10.2 Creating the catalog using PowerShell

Use the PowerShell script in this folder to automate creation of a PVS‑backed Hybrid Azure AD joined catalog:

- [`Create-PvsProvScheme-HybridAzureAD.ps1`](./Create-PvsProvScheme-HybridAzureAD.ps1)

This script typically performs the following high‑level actions:

1. Creates a **Hybrid Azure AD Identity Pool**  
   - `New-AcctIdentityPool -IdentityType HybridAzureAD`
2. Creates **AD accounts** (backed by on‑prem AD)  
   - `New-AcctADAccount`
3. Sets the **userCertificate** attribute for AD accounts (required for Hybrid Azure AD join)  
   - `Set-AcctAdAccountUserCert`
4. Creates a **PVS Provisioning Scheme**  
   - `New-ProvScheme` referencing:
     - PVS site
     - PVS store
     - vDisk
     - Azure hosting unit / machine profile
5. Creates a **Broker Catalog**  
   - `New-BrokerCatalog` that uses the PVS provisioning scheme

Before running the script, review and update variables to match your environment:

- Domain and OU for computer accounts
- Hybrid Azure AD / Entra configuration (tenant, sync, etc.)
- Hosting connection and hosting unit
- Azure resource group, network, and machine profile
- PVS farm, site, store, and vDisk

The end‑to‑end Hybrid Azure AD joined catalog workflow and automation concepts are covered in the **Create Hybrid Azure AD joined catalogs** documentation.

---

## 11. Limitations for Azure

When using **Azure** for Citrix Virtual Apps and Desktops (CVAD) or DaaS with PVS catalogs, the following limitations apply:

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

These limitations are documented in the **Citrix Provisioning catalog in Studio** article.

---

## References

- **Create Hybrid Azure AD joined catalogs** (Citrix Provisioning 2402 LTSR)  
  https://docs.citrix.com/en-us/provisioning/2402-ltsr/configure/create-hybrid-joined-catalogs  

- **Citrix Provisioning catalog in Studio (PVS + MCS)**  
  https://docs.citrix.com/en-us/provisioning/2402-ltsr/configure/citrix-provisioning-catalog-in-studio.html  

- **Citrix Provisioning documentation (2402 LTSR)**  
  https://docs.citrix.com/en-us/provisioning/2402-ltsr.html  
