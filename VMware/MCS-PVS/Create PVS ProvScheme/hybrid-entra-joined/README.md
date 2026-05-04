# PVS Catalog Creation with MCS Provisioning (Hybrid Entra joined)

This folder contains an example PowerShell script for creating a **Citrix Provisioning Services (PVS)**-backed catalog in **Citrix Virtual Apps and Desktops (CVAD)** / **Citrix DaaS** where machines are **Hybrid Entra joined** and hosted on **VMware**.

- Script: [`Create-PvsProvScheme-HybridEntraJoined.ps1`](./Create-PvsProvScheme-HybridEntraJoined.ps1)
- Base flow (PVS setup, vDisk, VMware hosting connection, PVS → CVAD/DaaS registration, etc.) is the same as [`Traditional AD`](../traditional-ad/README.md)

This README only covers **extra requirements and differences** for **Hybrid Entra joined**.

---

## 1. Requirements for VMware

For **CVAD / on-premises** and **Citrix DaaS (Citrix Cloud)** deployments on **VMware**, the minimum supported versions are **CVAD / DaaS 2402 and later** and **Citrix Provisioning (PVS) 2402 and later**.

> Hybrid Entra joined catalogs:
> https://docs.citrix.com/en-us/provisioning/2402-ltsr/configure/create-hybrid-joined-catalogs
> PVS catalog creation:
> https://docs.citrix.com/en-us/provisioning/2402-ltsr/configure/citrix-provisioning-catalog-in-studio.html

---

## 2. Hybrid Entra joined Differences (vs. Traditional AD)

In addition to the standard **Traditional AD** PVS catalog flow, Hybrid Entra joined introduces extra requirements around sync, image prep, and identity so VMs can use both **on-prem AD** and **Azure AD**:

- **Hybrid join & sync prerequisites**
  - Configure **Microsoft Entra Connect Sync** so on-prem AD computer accounts in the target OUs are synchronized and in scope for **Hybrid Entra join**.
  - Ensure Azure AD / Microsoft Entra endpoints are reachable from the VMware-hosted VMs (network, proxy, firewall).
  - Confirm your tenant and licensing support **Hybrid Entra joined Windows devices**.

- **Master image and Imaging Wizard behavior**
  - Build the master image (to be used for vDisk creation) as for Traditional AD (base OS, VDA, PVS Target Device, apps), but keep it **joined only to on-prem AD**. Do **not** Azure AD-join or Hybrid-join the master; Hybrid join occurs later on the **provisioned catalog VMs**.
  - When running the **PVS Imaging Wizard** to create the vDisk, select **Prepare for Hybrid Entra join** in **Edit Optimization Settings** so the image is optimized for Hybrid join.

- **Identity and computer account handling**
  - Catalogs still use **on-prem AD computer accounts**, but these must be configured for Hybrid join, including correct handling of the **`userCertificate`** attribute used by Azure AD for device registration.
  - Use a **Hybrid Entra joined identity pool** (instead of a Traditional AD identity pool) so created accounts are automatically in scope for sync and Hybrid Entra join.

All other catalog creation steps follow [`Traditional AD`](../traditional-ad/README.md).

> Additional guidance:
> - Hybrid Entra joined catalogs:
>   https://docs.citrix.com/en-us/provisioning/2402-ltsr/configure/create-hybrid-joined-catalogs
> - Target image preparation:
>   https://docs.citrix.com/en-us/provisioning/2402-ltsr/install/target-image-prepare
> - PVS catalog creation:
>   https://docs.citrix.com/en-us/provisioning/2402-ltsr/configure/citrix-provisioning-catalog-in-studio.html
