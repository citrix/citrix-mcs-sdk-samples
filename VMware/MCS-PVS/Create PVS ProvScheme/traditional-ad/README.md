# PVS Catalog Creation with MCS Provisioning (Traditional AD)

This section explains how to create a **Citrix Provisioning Services (PVS) Provisioning Scheme (ProvScheme)** in **Citrix Virtual Apps and Desktops (CVAD)** for **local Active Directory-joined** catalogs hosted on **VMware**.

The script [`Create-PvsProvScheme-TraditionalAD.ps1`](./Create-PvsProvScheme-TraditionalAD.ps1) provides an example of how to use `New-ProvScheme` to provision PVS catalogs.

To create a PVS provisioning scheme, use the script available at:
[`Create-PvsProvScheme-TraditionalAD.ps1`](./Create-PvsProvScheme-TraditionalAD.ps1).

---

## 1. Requirements for VMware

For **Citrix Virtual Apps and Desktops (CVAD) / on-premises** and **Citrix DaaS (Citrix Cloud)** deployments on **VMware**, the minimum supported versions are **CVAD 2402 and later** and **Citrix Provisioning (PVS) 2402 and later**.

> Reference:
> Citrix Provisioning catalog in Studio (2402 LTSR):
> https://docs.citrix.com/en-us/provisioning/2402-ltsr/configure/citrix-provisioning-catalog-in-studio.html

---

## 2. Key Steps

Follow these key steps to create a PVS catalog. Each step below expands into the concrete configuration actions required in a Citrix Provisioning + CVAD / DaaS environment.

1. Set up the PVS server
2. Create the master image and base vDisk
3. Create a VMware hosting connection and hosting unit
4. Run the PVS Configuration Wizard to join PVS farm to CVAD/DaaS
5. Retrieve PVS site details
6. Prepare the machine profile (VM snapshot) used for catalog hardware settings

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
    - VMware vCenter and VM networks where targets will run
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

- Ensure sufficient storage on the PVS vDisk volume.
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

## 2.3 Create a VMware Hosting Connection and Hosting Unit

Set up a **VMware hosting connection and hosting unit** in Studio / Web Studio, just as you would for an MCS catalog in Citrix Virtual Apps and Desktops (CVAD). This connection will allow the provisioning of virtual machines on VMware.

Use the VMware-specific starter scripts in this repository for those prerequisites:

- [`Hosting Connection`](../../../Hosting%20Connection/README.md)
- [`Hosting Unit`](../../../Hosting%20Unit/README.md)

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

Use the CVAD/DaaS PowerShell SDK to retrieve PVS details that are required when creating the PVS catalog. The PVS site and vDisk information is required in the script [`Create-PvsProvScheme-TraditionalAD.ps1`](./Create-PvsProvScheme-TraditionalAD.ps1).

1. **Get the Site and Farm IDs**
   Use `Get-HypPvsSite` to retrieve the **Site ID** and associated **Farm ID**.

2. **Get Store Details**
   Use `Get-HypPvsStore` to retrieve PVS store information.

3. **Retrieve vDisk Details**
   Using the **Farm ID**, **Store ID**, and **Site ID**, use `Get-HypPvsDiskInfo` to retrieve detailed information about vDisks.

> References:
> https://developer-docs.citrix.com/en-us/citrix-virtual-apps-desktops-sdk/2402/hostservice/get-hyppvssite
> https://developer-docs.citrix.com/en-us/citrix-virtual-apps-desktops-sdk/2402/HostService/Get-HypPvsStore.html
> https://developer-docs.citrix.com/en-us/citrix-virtual-apps-desktops-sdk/2402/hostservice/get-hyppvsdiskinfo

---

## 2.6 Prepare the Machine Profile

For VMware, the PVS provisioning scheme requires a **machine profile** so MCS can derive the VM hardware configuration (CPU, memory, NIC layout, etc.) for the catalog.

- The machine profile must be a **VM snapshot** that exists in the same hosting unit.
- Make sure the path is valid under `XDHyp:\HostingUnits\<HostingUnitName>`.
- The machine profile is used **only** to define hardware characteristics; the operating system is streamed from the PVS vDisk.

An example machine profile path:

```powershell
XDHyp:\HostingUnits\MyHostingUnit\pvstemplate.template
```

An example network mapping:

```powershell
@{
    "0" = "XDHyp:\HostingUnits\MyHostingUnit\MyNetwork.network"
}
```

---

## 2.7 Example `New-ProvScheme` Pattern for VMware PVS

```powershell
New-ProvScheme -CleanOnBoot:$isCleanOnBoot `
    -ProvisioningSchemeName $provisioningSchemeName `
    -ProvisioningSchemeType PVS `
    -PVSSite $pvsSite `
    -PVSvDisk $pvsVDisk `
    -HostingUnitName $hostingUnitName `
    -IdentityPoolName $identityPoolName `
    -InitialBatchSizeHint $numberOfVms `
    -MachineProfile $machineProfilePath `
    -NetworkMapping $networkMapping `
    -CustomProperties $sampleCustomProperties `
    -VMCpuCount $vmCpuCount `
    -VMMemoryMB $vmMemoryMB `
    -UseWriteBackCache -WriteBackCacheDiskSize $writeBackCacheDiskSizeGB
```

For the complete example, refer to [`Create-PvsProvScheme-TraditionalAD.ps1`](./Create-PvsProvScheme-TraditionalAD.ps1).
