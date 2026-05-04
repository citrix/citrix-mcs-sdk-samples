# Create PVS Catalogs using MCS for Azure

This repository contains example PowerShell scripts and documentation for creating **Citrix Provisioning (PVS)**–backed Machine Catalogs in **Azure**, using two identity models:

- **Local / On‑prem Active Directory (AD)**
- **Hybrid Entra joined** (on‑prem AD + Azure AD)

The scripts automate creation of:

- A **PVS Provisioning Scheme** (`New-ProvScheme`) for Azure‑hosted target VMs.
- A **Machine Catalog** (`New-BrokerCatalog`) that appears in Citrix Studio / Web Studio.

> These examples are intended as **reference implementations**. Always validate and adapt them for your own environment, security policies, and CVAD/DaaS version.

## Repository structure

```text
/Create PVS ProvScheme/
  traditional-ad/
    Create-PvsProvScheme-TraditionalAD.ps1
    README.md

  hybrid-entra-joined/
    Create-PvsProvScheme-HybridEntraJoined.ps1
    README.md

   ```
## `traditional-ad/` – MCS PVS Catalogs with Traditional AD

This folder contains scripts and documentation for creating **PVS‑backed MCS Catalogs** where machines are:

- Joined to a **traditional on‑premises Active Directory domain** only.
- Managed via Citrix Studio / Web Studio using **domain‑joined** identities.

### When to use

Use `traditional-ad/` if:

- Azure is used only as the **compute platform**, and
- Identity and device management are **on‑prem AD–centric**.

## `hybrid-entra-joined/` – MCS PVS Catalogs with Hybrid Entra join

This folder contains scripts and documentation for creating **PVS‑backed MCS Catalogs** where machines are:

- Joined to **on‑prem AD** (for traditional domain services), and  
- Registered as **Hybrid Entra joined** devices in **Azure AD**.

### When to use

Use `hybrid-entra-joined/` if you want:

- Machines to be **domain‑joined** for:
  - GPOs
  - Legacy apps
  - File/print services
- And also **Hybrid Entra joined** for:
  - Conditional Access
  - Intune device management
  - Modern authentication and device‑based access controls