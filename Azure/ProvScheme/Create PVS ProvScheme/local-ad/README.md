# PVS Catalog Creation with MCS Provisioning (Local AD)

This section explains how to create a **Citrix Provisioning Services (PVS) Provisioning Scheme (ProvScheme)** in **Citrix Virtual Apps and Desktops (CVAD)** for **local Active Directory–joined** catalogs.

The script [`Create-PvsProvScheme-LocalAD.ps1`](./Create-PvsProvScheme-LocalAD.ps1) provides an example of how to use `New-ProvScheme` to provision PVS catalogs.

To create a PVS provisioning scheme, use the script available at:  
[`Create-PvsProvScheme-LocalAD.ps1`](../Create%20PVS%20ProvScheme/local-ad/Create-PvsProvScheme-LocalAD.ps1).

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

> Reference:  
> Citrix Provisioning catalog in Studio (2402 LTSR):  
> https://docs.citrix.com/en-us/provisioning/2402-ltsr/configure/citrix-provisioning-catalog-in-studio.html  

---

## 2. Key Steps

Follow these key steps to create a PVS catalog. Each step below expands into the concrete configuration actions required in a Citrix Provisioning + CVAD / DaaS environment.

---

### 1. Set up the PVS server

Install and configure the **Citrix Provisioning Services (PVS) server** that will host your PVS farm and stream vDisks to target devices.

> Reference:  
> Install Citrix Provisioning software components:  
> https://docs.citrix.com/en-us/provisioning/2402-ltsr/install.html  

#### 1.1 Prepare infrastructure

- Ensure:
  - Supported Windows Server OS for the PVS server.
  - Network connectivity to:
    - SQL Server (for the PVS database)
    - Active Directory domain controllers
    - Hypervisor / Azure networks where targets will run
  - Required firewall ports are open (PVS streaming, SOAP, SQL, etc.).

#### 1.2 Install PVS server components

1. Mount or extract the **Citrix Provisioning** installation media.
2. Run the **Citrix Provisioning Server** setup.
3. Install:
   - **Provisioning Services** (server)
   - **Console** (optional but recommended on at least one admin machine)
4. Provide:
   - SQL Server name / instance and credentials (or Windows auth)
   - Database name (new or existing)
5. Complete the installation and reboot if prompted.

---

## 2. Create the Master Image

This step covers preparing the **master target device** (golden image) that will be captured into a vDisk and streamed by PVS.

A **vDisk** is built from this master image and later streamed to one or more target devices.

> **Important**  
> Citrix Provisioning only supports **automated vDisk capture**. The recommended capture method is the **Imaging Wizard**.

> Reference:  
> Preparing the master target device & Imaging Wizard overview:  
> https://docs.citrix.com/en-us/provisioning/2402-ltsr/install/target-device.html  

---

### 2.1 Plan the vDisk and image

Before building the image:

- Ensure sufficient free space on the PVS server or shared storage that will hold the vDisk.
- The volume that stores vDisks must be:
  - **NTFS** – maximum VHDX size ≈ **2 TB**
  - **FAT** – maximum VHDX size ≈ **4,096 MB**
- Plan the lifecycle:
  - Build and test the vDisk as a **Private Image**.
  - Convert to **Standard Image** for production, shared use.

---

### 2.2 Prepare the master target device

The master target device is the **golden image** source for the vDisk.

1. **Install the OS and base configuration**
   - Install a supported Windows OS (Server or Desktop) on a physical or virtual machine.
   - Apply:
     - Latest OS updates and patches.
     - Required language / regional settings.
   - Configure system settings (time zone, security baseline, etc.).
   - Install **Citrix VDA**. 

2. **Install required applications**
   - Install all applications that must be in the base image:
     - Line‑of‑business applications.
     - Productivity tools.
     - Security / monitoring agents.
   - Configure application settings as needed.

3. **Install Citrix Provisioning Target Device software**
   - Log on as a domain admin or a user with local install rights.
   - Run the **Citrix Provisioning Target Device** installer.
   - Accept defaults unless you have specific requirements.
   - Reboot the master device when prompted.

---

## 3. Create the Base vDisk

This step covers creating the **base vDisk** that will hold the captured master image.

A vDisk is stored as:

- A **VHDX base image** file  
- A `.pvp` properties file  
- Optionally, one or more differencing disks (`.avhdx`) if vDisk versioning is used  

A vDisk can be:

- **Standard Image** – shared by many target devices  
- **Private Image** – dedicated to a single target device  

> **Important**  
> The **Cache on hard disk** option currently appears in the product but **does not function**.

> Reference:  
> Create and configure vDisks:  
> https://docs.citrix.com/en-us/provisioning/2402-ltsr/configure/configure-vdisks/vdisk-create  

---

### 3.1 Create the base vDisk (recommended: Imaging Wizard)

The **Imaging Wizard** is the recommended method for creating a base vDisk.

1. **Ensure the master target device is ready**
   - OS, drivers, and apps installed.
   - PVS Target Device software installed.
   - (Optional) Device Guard enabled if required.

2. **Run the Imaging Wizard**
   - Log on to the master target device.
   - Launch the **Citrix Provisioning Imaging Wizard**.
   - Connect to the PVS farm:
     - Specify the PVS server.
     - Select the **Farm**, **Site**, and **Store** where the new vDisk will reside.

3. **Create the vDisk file**
   - The wizard automatically:
     - Creates a new **VHDX vDisk** file in the selected store.
     - Registers the vDisk with the chosen site/store.

4. **Capture the master image**
   - In the wizard:
     - Select the local system disk to capture (typically `C:`).
     - Start the imaging process.
   - The wizard:
     - Copies the contents of the master disk into the vDisk.
     - Configures the target device to boot from this vDisk.

5. **Validate and convert to Standard Image**
   - Boot the master device from the new vDisk in **Private Image** mode.
   - Validate:
     - OS boots correctly.
     - Applications work as expected.
   - In the PVS console:
     - Change the vDisk **Access Mode** from **Private** to **Standard Image** when ready to share.
     - Configure the desired **cache type** (for example, cache on device hard disk or cache in RAM, depending on your design).

> Reference:  
> Using the Imaging Wizard to create a virtual disk:  
> https://docs.citrix.com/en-us/provisioning/2402-ltsr/configure/configure-vdisks/using-the-imaging-wizard-to-create-a-virtual-disk.html  

---

### 3.2 (Optional) Manually create and then image a vDisk

If you need more control over vDisk creation, you can manually create the vDisk file and then capture the master image into it.

> Reference:  
> Manual vDisk creation workflow:  
> https://docs.citrix.com/en-us/provisioning/2402-ltsr/configure/configure-vdisks/vdisk-create  

#### 3.2.1 Manually create the vDisk file

1. In the **Citrix Provisioning Console**:
   - Right‑click the **vDisk Pool** (under the site) or the **Store**, and select **Create vDisk** (or **Create new vDisk**).

2. In the **Create vDisk** dialog:
   - If opened from the site:
     - Select the **Store** where the vDisk will reside.
   - If opened from the store:
     - Select the **Site** that will use this vDisk.

3. Select the **Server used to create the vDisk**.
4. Enter:
   - **vDisk file name**
   - Optional **description**

5. Choose the **Size**:
   - Up to ~2 TB on NTFS
   - Up to 4,096 MB on FAT

6. Configure **VHDX Format**:
   - **Fixed** or **Dynamic**
   - For Dynamic, select block size:
     - 2 MB or 16 MB
   - Size limits:
     - Up to 2,040 GB for VHDX (SCSI)
     - Up to 127 GB for VHDX (IDE)

7. Click **Create vDisk**:
   - Wait for the vDisk to be created.
   - The new vDisk appears in the console.

8. **Mount and format the vDisk**:
   - Right‑click the vDisk → **Mount vDisk**.
   - When mounted (orange arrow icon), format it (NTFS recommended) and assign a drive letter.
   - Unmount the vDisk when formatting is complete.

> A vDisk cannot be assigned to or booted by a target device until that target device exists in the PVS database and is configured to use the vDisk.

#### 3.2.2 Capture the master image into the manual vDisk

1. Confirm the **master target device** is fully prepared (OS, apps, PVS Target Device installed).
2. Use the **Citrix Provisioning imaging utility** (Imaging Wizard or P2PVS) to:
   - Capture the master target device’s system disk.
   - Write the captured image into the manually created vDisk file.

After imaging:

- Boot the master device from the new vDisk in **Private Image** mode.
- Validate functionality.
- Switch the vDisk to **Standard Image** mode when ready for multi‑device use.

---

## 4. Create an Azure Hosting Connection

Set up an **Azure hosting connection and hosting unit** in Studio / Web Studio, just as you would for an MCS catalog in Citrix Virtual Apps and Desktops (CVAD). This connection will allow the provisioning of virtual machines in Azure.

> Reference:  
> Create and manage connections and resources (CVAD):  
> https://docs.citrix.com/en-us/citrix-virtual-apps-desktops/install-configure/machine-identities-and-connections.html  

---

## 5. Run the PVS Configuration Wizard

Run the **PVS Configuration Wizard** to register your PVS site with the Citrix Cloud or CVAD site. This integration enables seamless communication and management between the two environments.

> Reference:  
> Join Citrix Cloud or Citrix Virtual Apps and Desktops site:  
> https://docs.citrix.com/en-us/provisioning/2402-ltsr/configure/farm-configure-new#join-citrix-cloud-or-citrix-virtual-apps-and-desktops-site  

---

## 3. How to Retrieve PVS Site Details

Follow these steps to get the required details for your PVS site:

1. **Get the Site and Farm IDs**:  
   Use the `Get-HypPvsSite` command to retrieve the **Site ID** and the associated **Farm ID**.

2. **Get Store Details**:  
   Use the `Get-HypPvsStore` command to retrieve information about the PVS store, including its configuration and details.

3. **Retrieve vDisk Details**:  
   Using the **Farm ID**, **Store ID**, and **Site ID** obtained in the previous steps, use the `Get-HypPvsDiskInfo` command to retrieve detailed information about the vDisks available in the PVS site.

> Reference:  
> PVS PowerShell integration (DaaS/CVAD):  
> https://docs.citrix.com/en-us/citrix-daas/reference/powershell/get-hyppvssite.html  
> https://docs.citrix.com/en-us/citrix-daas/reference/powershell/get-hyppvsdiskinfo.html  

---

## 4. Limitations for Azure

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

> Reference:  
> Citrix Provisioning catalog in Studio (limitations for Azure):  
> https://docs.citrix.com/en-us/provisioning/2402-ltsr/configure/citrix-provisioning-catalog-in-studio.html  
