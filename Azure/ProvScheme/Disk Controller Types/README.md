## Disk Controller Types

Azure VMs use either SCSI or NVMe as the disk storage interface. Older VM generations use SCSI; newer generations (Da/Ea/Fav6 and newer) support NVMe only. Some generations (such as Ebsv5) support both SCSI and NVMe, with the active interface determined by the machine profile.

For background on NVMe, see [General FAQ for NVMe](https://learn.microsoft.com/en-us/azure/virtual-machines/enable-nvme-faqs).

---

### Before you begin

To provision a catalog with the correct disk controller type, three things must be compatible with each other: the master image, the machine profile, and the service offering (VM size). The sections below explain each requirement.

---

### Step 1 — Check your master image's disk controller types

To check what disk controller types your master image supports, run:

```powershell
(Get-Item XDHyp:\HostingUnits\mynetwork\image.folder\abc.resourcegroup\deg-snapshot.snapshot).AdditionalData
```

Look for `SupportedDiskControllerTypes`. For NVMe provisioning, the value must include `NVMe` (for example, `SCSI, NVMe`). The value also determines what your machine profile OS disk must declare — see Step 2.

A list of Azure Marketplace images that support NVMe can be found at [Supported OS images for remote NVMe](https://learn.microsoft.com/en-us/azure/virtual-machines/enable-nvme-interface).

---

### Step 2 — Check your machine profile's OS disk (if applicable)

> **What is the machine profile's OS disk's Disk Controller Type?**
> When you export a VM as an ARM template, the OS disk resource contains a `supportedCapabilities.diskControllerTypes` field. This tells Azure which storage interfaces the OS disk supports. MCS reads this field from your machine profile.

Example OS disk section in an ARM template:
```json
{
  "type": "Microsoft.Compute/disks",
  "properties": {
    "supportedCapabilities": {
      "diskControllerTypes": "SCSI, NVMe"
    }
  }
}
```

If your machine profile's OS disk has `diskControllerTypes` set explicitly, it **must match** the master image's `SupportedDiskControllerTypes`. If it is not set, the base disk automatically inherits the master image's value — this is always safe.

> **Why this matters:** The OS disk `diskControllerTypes` field overrides the master image's `SupportedDiskControllerTypes` on the MCS-prepared base disk. This is a side effect of how Azure handles OS disk capabilities. If the values do not match exactly, MCS will fail to provision the catalog.

**If there is a mismatch, MCS will fail to provision the catalog.**

| Master Image | OS Disk Controller Type (Machine Profile) | Result |
|---|---|---|
| SCSI | *(not set)* | ✅ Inherits SCSI from master image |
| SCSI | SCSI | ✅ |
| SCSI | SCSI, NVMe | ❌ Mismatch — provisioning fails |
| SCSI, NVMe | *(not set)* | ✅ Inherits SCSI, NVMe from master image |
| SCSI, NVMe | SCSI, NVMe | ✅ |
| SCSI, NVMe | SCSI | ❌ Mismatch — provisioning fails |
| SCSI, NVMe | NVMe | ❌ Mismatch — provisioning fails |

> **Tip:** If you are unsure, leave the OS disk `diskControllerTypes` unset in your machine profile. MCS will use the master image's value automatically.

> **Note:** A preflight check that enforces this rule is being added to MCS in an upcoming release.

#### How to fix a mismatch

If provisioning fails with a disk controller type mismatch error, the fix depends on your machine profile source type.

**If your machine profile is a VM:**
The OS disk properties of an existing Azure VM cannot typically be edited in-place. Instead, select a different VM as your machine profile — one whose OS disk does not have `supportedCapabilities.diskControllerTypes` set, or one whose `diskControllerTypes` exactly matches the master image's `SupportedDiskControllerTypes`. If the field is absent, MCS automatically inherits the value from the master image, which is always safe.

**If your machine profile is a template spec:**
Edit the template spec version directly and remove the `supportedCapabilities.diskControllerTypes` property from the OS disk resource. Once removed, MCS will inherit the value from the master image automatically. Alternatively, update the value to exactly match the master image's `SupportedDiskControllerTypes`.

---

### Step 3 — Choose your service offering and machine profile VM setting

> **What is the machine profile VM's Disk Controller Type?**
> Separately from the OS disk, the VM resource in an ARM template has a `storageProfile.diskControllerType` field. This tells Azure which storage interface to use for the VM itself. MCS reads this field from your machine profile.

Example VM section in an ARM template:
```json
{
  "type": "Microsoft.Compute/virtualMachines",
  "properties": {
    "storageProfile": {
      "diskControllerType": "NVMe"
    }
  }
}
```

How NVMe is enabled depends on the combination of your service offering (VM size) and this VM-level setting:

| Service Offering | Machine Profile VM DiskControllerType | Result |
|---|---|---|
| SCSI only | *(not set — omit the parameter)* | SCSI |
| SCSI only | SCSI | SCSI |
| SCSI only | NVMe | ❌ Not supported |
| SCSI, NVMe | *(not set — omit the parameter)* | SCSI (default) |
| SCSI, NVMe | SCSI | SCSI |
| SCSI, NVMe | NVMe | ✅ NVMe enabled |
| NVMe only | *(not set — omit the parameter)* | ✅ NVMe enabled |
| NVMe only | NVMe | ✅ NVMe enabled |
| NVMe only | SCSI | ❌ Not supported |

> **Note:** For VM sizes that support both SCSI and NVMe, you must explicitly set the machine profile VM `DiskControllerType` to `NVMe` to enable NVMe. Omitting it defaults to SCSI.

---

### Modify existing persistent VMs

The disk controller type cannot be changed on a VM after it is created. To change it, update the provisioning scheme with a new machine profile using `Set-ProvScheme`, then schedule a redeployment for existing VMs using `Set-ProvVmUpdateTimeWindow`.

Whether redeployment is required depends on the change:
   - **SCSI → SCSI** or **NVMe → NVMe:** No redeployment required.
   - **SCSI → NVMe** or **NVMe → SCSI:** Redeploy and recreate the VM.

---

### Example scripts

**Create**

Each script below represents a valid, fully compatible configuration — master image, machine profile OS disk, machine profile VM Disk Controller Type, and service offering are all aligned. If your provisioning failed with a mismatch error, see the [How to fix a mismatch](#how-to-fix-a-mismatch) section in Step 2 above.

The **Machine Profile VM Disk Controller Type** column refers to `storageProfile.diskControllerType` on the machine profile VM resource — not the OS disk. See Step 2 for OS disk compatibility requirements.

| Script | Size family | Machine Profile VM Disk Controller Type | Result |
|---|---|---|---|
| [Create-DsV5-SCSI.ps1](Create-DsV5-SCSI.ps1) | Dsv5 (SCSI only) | *(N/A — size is SCSI only)* | SCSI |
| [Create-EbsV5-SCSI.ps1](Create-EbsV5-SCSI.ps1) | Ebsv5 (SCSI + NVMe) | SCSI | SCSI |
| [Create-EbsV5-NVMe.ps1](Create-EbsV5-NVMe.ps1) | Ebsv5 (SCSI + NVMe) | NVMe | NVMe |
| [Create-DsV6-NVMe.ps1](Create-DsV6-NVMe.ps1) | Dsv6 (NVMe only) | NVMe | NVMe |
| [Create-DsV6-NVMeDefault.ps1](Create-DsV6-NVMeDefault.ps1) | Dsv6 (NVMe only) | *(not set)* | NVMe |

**Update**

| Script | Description |
|---|---|
| [Set-DiskControllerType.ps1](Set-DiskControllerType.ps1) | Updates the disk controller type on an existing provisioning scheme |

To update provisioning scheme settings or apply changes to individual VMs, see:

- [Update ProvScheme](../Update%20ProvScheme/README.md) — scheme-level updates using `Set-ProvScheme`
- [Update ProvVM](../../ProvVm/Update%20ProvVM/README.md) — per-VM overrides using `Set-ProvVM`
