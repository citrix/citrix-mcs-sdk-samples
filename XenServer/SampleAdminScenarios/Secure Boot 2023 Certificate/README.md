# Secure Boot 2023 Certificate

> **Note**: The scripts provided here are **reference scripts** intended as examples to assist administrators.

## Problem

Microsoft is transitioning from the **Windows UEFI CA 2011** certificate to the **Windows UEFI CA 2023** certificate. The 2011 certificate expires in 2026, and newer Windows bootloaders are being signed with the 2023 certificate.

VMs with Secure Boot enabled may only have the 2011 certificate in their Secure Boot database. When an MCS catalog update applies a 2023-signed bootloader, these VMs fail to boot with **"No Boot Media"** because their Secure Boot DB does not trust the 2023 certificate.

## Solutions

Two scripts are available:

* **[Fix Boot Failure - Disable Secure Boot](./Fix%20Boot%20Failure%20-%20Disable%20Secure%20Boot/README.md)**

    Disables Secure Boot on all VMs in a machine catalog using the XenServer PowerShell Module. With Secure Boot disabled, VMs boot without checking the bootloader's certificate signature. This is a quick fix but removes a security layer.

* **[Prevent Boot Failure - Deploy Certificate](./Prevent%20Boot%20Failure%20-%20Deploy%20Certificate/README.md)**

    Uses the native XenServer API to mark VMs for certificate update on their next reboot. This deploys the 2023 certificate into the Secure Boot database while keeping Secure Boot enabled.
