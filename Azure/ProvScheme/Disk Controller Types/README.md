## Disk Controller Types

Azure VMs use either SCSI or NVMe as the disk storage interface. Older VM generations use SCSI; newer generations (Da/Ea/Fav6 and newer) support NVMe only. Some generations (such as Ebsv5) support both SCSI and NVMe, with the active interface determined by the machine profile.

For background on NVMe, see [General FAQ for NVMe](https://learn.microsoft.com/en-us/azure/virtual-machines/enable-nvme-faqs).

---

### Before you begin

To provision a catalog with the correct disk controller type, three things must be compatible with each other: the master image, the service offering (VM size), and the machine profile VM's disk controller type. The sections below explain each requirement.

---

### Step 1 — Check your master image's disk controller types

To check what disk controller types your master image supports, run:

```powershell
(Get-Item XDHyp:\HostingUnits\mynetwork\image.folder\abc.resourcegroup\deg-snapshot.snapshot).AdditionalData
```

Look for `SupportedDiskControllerTypes`. For NVMe provisioning, the value must include `NVMe` (for example, `SCSI, NVMe`).

A list of Azure Marketplace images that support NVMe can be found at [Supported OS images for remote NVMe](https://learn.microsoft.com/en-us/azure/virtual-machines/enable-nvme-interface).

---

### Step 2 — Choose your service offering and machine profile VM setting

> **What is the machine profile VM's Disk Controller Type?**
> The VM resource in an ARM template has a `storageProfile.diskControllerType` field. This tells Azure which storage interface to use for the VM. MCS reads this field from your machine profile.

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
| SCSI, NVMe | NVMe | NVMe |
| NVMe only | *(not set — omit the parameter)* | NVMe |
| NVMe only | NVMe | NVMe |
| NVMe only | SCSI | ❌ Not supported |

> **Note:** For VM sizes that support both SCSI and NVMe (Ebsv5), you must explicitly set the machine profile VM `DiskControllerType` to `NVMe` to enable NVMe. Omitting it defaults to SCSI.

---

### Modify existing persistent VMs

The disk controller type cannot be changed on a VM after it is created. To change it, update the provisioning scheme to a new machine size (service offering) with `Set-ProvScheme`, then schedule the update for existing VMs using `Set-ProvVmUpdateTimeWindow`. See [Set-DiskControllerType.ps1](Set-DiskControllerType.ps1).

> For sizes that support both SCSI and NVMe (Ebsv5), you can instead switch the interface by changing the machine profile VM DiskControllerType.

Whether redeployment is required depends on the change:
   - **SCSI → SCSI** or **NVMe → NVMe:** No redeployment required.
   - **SCSI → NVMe** or **NVMe → SCSI:** Redeploy and recreate the VM.

---

### Example scripts

**Create**

Each script below represents a valid configuration where the master image, machine profile VM Disk Controller Type, and service offering are aligned.

The **Machine Profile VM Disk Controller Type** column refers to `storageProfile.diskControllerType` on the machine profile VM resource.

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