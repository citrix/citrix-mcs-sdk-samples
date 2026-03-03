# Create PVS Catalogs using MCS for Azure

This repository contains example PowerShell scripts and documentation for creating **Citrix Provisioning (PVS)**–backed Machine Catalogs in **Azure**, using two identity models:

- **Local / On‑prem Active Directory (AD)**
- **Hybrid Azure AD joined** (on‑prem AD + Azure AD)

The scripts automate creation of:

- A **PVS Provisioning Scheme** (`New-ProvScheme`) for Azure‑hosted target VMs.
- A **Machine Catalog** (`New-BrokerCatalog`) that appears in Citrix Studio / Web Studio.

> These examples are intended as **reference implementations**. Always validate and adapt them for your own environment, security policies, and CVAD/DaaS version.

## Repository structure

```text
/Create PVS ProvScheme/
  local-ad/
    Create-PvsProvScheme-LocalAD.ps1
    README.md

  hybrid-azure-ad/
    Create-PvsProvScheme-HybridAzureAD.ps1
    README.md

   ```
## `local-ad/` – MCS PVS Catalogs with Local / On‑prem AD

This folder contains scripts and documentation for creating **PVS‑backed MCS Catalogs** where machines are:

- Joined to a **traditional on‑premises Active Directory domain** only.
- Managed via Citrix Studio / Web Studio using **domain‑joined** identities.

### When to use

Use `local-ad/` if:

- Azure is used only as the **compute platform**, and
- Identity and device management are **on‑prem AD–centric**.

## `hybrid-azure-ad/` – MCS PVS Catalogs with Hybrid Azure AD Join

This folder contains scripts and documentation for creating **PVS‑backed MCS Catalogs** where machines are:

- Joined to **on‑prem AD** (for traditional domain services), and  
- Registered as **Hybrid Azure AD joined** devices in **Azure AD**.

### When to use

Use `hybrid-azure-ad/` if you want:

- Machines to be **domain‑joined** for:
  - GPOs
  - Legacy apps
  - File/print services
- And also **Hybrid Azure AD joined** for:
  - Conditional Access
  - Intune device management
  - Modern authentication and device‑based access controls