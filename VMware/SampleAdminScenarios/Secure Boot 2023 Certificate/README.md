# Secure Boot 2023 Certificate

> **Note**: The scripts provided here are **reference scripts** intended as examples to assist administrators.

## Problem

Microsoft is transitioning from the **Windows UEFI CA 2011** certificate to the **Windows UEFI CA 2023** certificate. The 2011 certificate expires in 2026, and newer Windows bootloaders are being signed with the 2023 certificate.

VMs originally created on **ESXi 8.0.0** only have the 2011 certificate in their Secure Boot database. After the ESXi host is upgraded to 8.0.3, an MCS catalog update applies a 2023-signed bootloader to these VMs. The VMs fail to boot with **"No Boot Media"** because their Secure Boot DB does not trust the 2023 certificate.

**Key points:**
- The VM's NVRAM (firmware storage) contains the Secure Boot database — a list of trusted certificates.
- ESXi 8.0.3 includes both 2011 and 2023 certificates when creating **new** VMs, but does not update existing VMs.
- MCS catalog updates replace the OS disk (including the bootloader) but do not touch the VM's NVRAM.
- This creates a mismatch: the bootloader on disk is signed with 2023, but the NVRAM only trusts 2011.

## Solutions

Three scripts are available depending on the current state of the VMs:

* **[Fix Boot Failure - Reset NVRAM](./Fix%20Boot%20Failure%20-%20Reset%20NVRAM/README.md)**

    For VMs that are **already broken** and stuck at "No Boot Media". The script runs from an admin machine with PowerCLI and deletes the VM's NVRAM file from the VMware datastore. ESXi 8.0.3+ regenerates the NVRAM on next boot with both the 2011 and 2023 certificates.

* **[Fix Boot Failure - Disable Secure Boot](./Fix%20Boot%20Failure%20-%20Disable%20Secure%20Boot/README.md)**

    For VMs that are **broken or at risk**. The script runs from an admin machine with PowerCLI and disables Secure Boot on all VMs in a machine catalog. With Secure Boot disabled, VMs boot without checking the bootloader's certificate signature. This is a quick fix but removes a security layer.

* **[Prevent Boot Failure - Deploy Certificate](./Prevent%20Boot%20Failure%20-%20Deploy%20Certificate/README.md)**

    For VMs that **can still boot** into Windows. Deployed as a **GPO Immediate Scheduled Task** that runs inside each VM and deploys the 2023 certificate into the Secure Boot database using Microsoft's built-in servicing mechanism. This prepares VMs before a catalog update applies a 2023-signed bootloader.
