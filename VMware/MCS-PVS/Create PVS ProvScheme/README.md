# Create PVS Catalogs using MCS for VMware

This repository contains example PowerShell scripts and documentation for creating **Citrix Provisioning (PVS)**-backed Machine Catalogs on **VMware**.

The scripts automate creation of:

- A **PVS Provisioning Scheme** (`New-ProvScheme`) for VMware-hosted target VMs.
- A **Machine Catalog** (`New-BrokerCatalog`) that appears in Citrix Studio / Web Studio.

These examples are intended as **reference implementations**. Always validate and adapt them for your own environment, security policies, and CVAD/DaaS version.

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

## `local-ad/` - MCS PVS Catalogs with Local / On-prem AD

This folder contains scripts and documentation for creating **PVS-backed MCS Catalogs** where machines are:

- Joined to a **traditional on-premises Active Directory domain** only.
- Hosted on **VMware**.
- Managed via Citrix Studio / Web Studio using **domain-joined** identities.

### When to use

Use `local-ad/` if:

- VMware is the compute platform for the catalog, and
- Machine identities are managed through **local / on-prem Active Directory**.

## `hybrid-azure-ad/` - MCS PVS Catalogs with Hybrid Azure AD Join

This folder contains scripts and documentation for creating **PVS-backed MCS Catalogs** where machines are:

- Joined to **on-prem AD** (for traditional domain services), and
- Registered as **Hybrid Azure AD joined** devices in **Azure AD**.

### When to use

Use `hybrid-azure-ad/` if:

- VMware is the compute platform for the catalog, and
- Machine identities need both **on-prem AD** and **Azure AD** (Conditional Access, Intune, etc.).
