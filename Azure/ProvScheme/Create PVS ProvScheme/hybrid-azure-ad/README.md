# PVS Catalog Creation with MCS Provisioning (Hybrid Azure AD)

This folder contains example scripts and guidance for creating **Hybrid Azure AD joined** Machine Catalogs using **Citrix Provisioning (PVS)** and **MCS** in Azure.

A **Hybrid Azure AD joined catalog** provides:

- Traditional **on‑premises Active Directory (AD)** computer accounts, and  
- **Hybrid Azure AD join** to Microsoft Entra ID (Azure AD) for modern authentication, Conditional Access, and Intune device management.

---

## Key steps (high‑level)

To create a PVS‑backed Hybrid Azure AD joined catalog:

1. **Set up a Hybrid Azure AD environment**
2. **Set up Citrix Provisioning**
3. **Join the PVS farm with Citrix Cloud or a CVAD site**
4. **Create and prepare a master target device**
5. **Run the Imaging Wizard to create a vDisk (with Hybrid AAD optimization)**
6. **Create a Hybrid Azure AD joined catalog**
   - Using **Citrix Virtual Desktops Setup Wizard**, or
   - Using **MCS provisioning** (Studio UI or PowerShell)

The PowerShell automation for MCS provisioning is provided in:

- [`Create-PvsProvScheme-HybridAzureAD.ps1`](./Create-PvsProvScheme-HybridAzureAD.ps1)

---

## 1. Set up Hybrid Azure AD

Before creating the catalog, configure **Hybrid Azure AD** in your environment:

- Enable **Microsoft Entra hybrid join** using **Microsoft Entra Connect Sync** on the domain controller.
- Ensure:
  - On‑prem AD is synchronized to Azure AD.
  - Devices in the target OU can become **Hybrid Azure AD joined**.

Reference (Microsoft): *Configure Microsoft Entra hybrid join*.

---

## 2. Set up Citrix Provisioning

Install and configure Citrix Provisioning:

- Deploy PVS servers, farm, sites, and stores.
- Verify that:
  - PVS servers are online.
  - vDisks and stores are accessible.

For more information, see: *Install Citrix Provisioning software components*.

---

## 3. Join the PVS farm with Citrix Cloud or CVAD site

To create a Hybrid Azure AD joined catalog using the **Studio UI** or **PowerShell**, you must:

- Run the **Citrix Provisioning Configuration Wizard**.
- Join the PVS farm to either:
  - **Citrix Cloud (DaaS)**, or
  - An on‑prem **Citrix Virtual Apps and Desktops (CVAD)** site.

This registration allows Studio / Web Studio and PowerShell to see PVS sites and vDisks.

Reference: *Join Citrix Cloud or Citrix Virtual Apps and Desktops site*.

---

## 4. Create and prepare the master target device

1. Create a **master target device** (physical or virtual):
   - Install a supported Windows OS and all required applications.
   - Install the **Citrix Provisioning Target Device** software.
   - Install the **Citrix VDA**

2. If the device is already Hybrid Azure AD joined:
   - Run:
     ```powershell
     dsregcmd /leave
     ```
   - This ensures the master image is **not** pre‑joined to Azure AD before capture.

---

## 5. Run the Imaging Wizard to create a vDisk

Use the **Imaging Wizard** on the master target device to create the vDisk:

1. Start the **Imaging Wizard**.
2. Connect to the PVS farm and select the target **Site** and **Store**.
3. When the **Edit Optimization Settings** dialog appears:
   - Select **Prepare for Hybrid Azure AD join**.
   - This optimization ensures the vDisk and resulting VMs are correctly prepared for Hybrid Azure AD join.
4. Complete the imaging process to create the base vDisk.

Reference: *Using the Imaging Wizard to create a virtual disk*.

---

## 6. Create a Hybrid Azure AD joined catalog

You can create a Hybrid Azure AD joined catalog using:

- The **Citrix Virtual Desktops Setup Wizard** in the PVS Console, or  
- **MCS provisioning** (Studio UI or PowerShell).

This folder focuses on **MCS provisioning with PowerShell**. The full automation example is in:

- [`Create-PvsProvScheme-HybridAzureAD.ps1`](./Create-PvsProvScheme-HybridAzureAD.ps1)


#### Supported versions (on‑prem CVAD)

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


## 7. Creating the catalog using Studio UI

If using Studio UI (DaaS or supported CVAD builds):

1. Create a Citrix Provisioning catalog using the Studio UI.  
   Reference: *Create a Citrix Provisioning catalog using the Citrix Studio interface*.

2. On the **Machine Identities** page:
   - Select **Hybrid Azure Active Directory joined**.

> **Note**  
> The **Hybrid Azure Active Directory joined** option is available for Citrix Virtual Apps and Desktops customers from **2402 LTSR CU3**.

---

## 8. Creating the catalog using PowerShell

Use the PowerShell script in this folder to automate creation of a PVS‑backed Hybrid Azure AD joined catalog:

- [`Create-PvsProvScheme-HybridAzureAD.ps1`](./Create-PvsProvScheme-HybridAzureAD.ps1)

This script performs the following high‑level actions:

1. Creates a **Hybrid Azure AD Identity Pool** (`New-AcctIdentityPool` with `-IdentityType HybridAzureAD`).
2. Creates **AD accounts** (`New-AcctADAccount`).
3. Sets the **userCertificate** attribute for AD accounts (`Set-AcctAdAccountUserCert`).
4. Creates a **PVS Provisioning Scheme** (`New-ProvScheme`) referencing the PVS site and vDisk.
5. Creates a **Broker Catalog** (`New-BrokerCatalog`) that uses the PVS provisioning scheme.
6. Optionally, adds VMs to the catalog (via Studio / Web Studio or additional PowerShell commands).

Review and update the script variables to match your environment (domain, OU, hosting unit, resource group, PVS site/vDisk, etc.) before running it.

---

## References

- **Create Hybrid Azure AD joined catalogs** (Citrix Provisioning 2402 LTSR)  
  https://docs.citrix.com/en-us/provisioning/2402-ltsr/configure/create-hybrid-azure-ad-joined-catalogs.html

- **Citrix Provisioning catalog in Studio (PVS + MCS)**  
  https://docs.citrix.com/en-us/provisioning/2402-ltsr/configure/citrix-provisioning-catalog-in-studio.html

- **Citrix DaaS PowerShell SDK**  
  https://docs.citrix.com/en-us/citrix-daas/reference/powershell/sdk-overview.html

- **Citrix Provisioning documentation (2402 LTSR)**  
  https://docs.citrix.com/en-us/provisioning/2402-ltsr.html
