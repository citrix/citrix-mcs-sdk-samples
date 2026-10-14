# Get Virtual Machine Details on SCVMM

## Overview

`Get-ProvVMDetails` reports the Machine Creation Services (MCS) view of an existing SCVMM/Hyper-V virtual machine.
It combines recorded MCS properties with hypervisor details in six JSON sections: `VMInfo`, `SecurityInfo`,
`DiskInfo`, `MCSIOInfo`, `NetworkInfo`, and `ImageAndTemplateInfo`.

Use this view to inspect a provisioned VM's disks, security settings, host placement, and image assignment.
For the catalog's provisioning configuration, use the
[Get-ProvSchemeDetails sample](../../ProvScheme/Get%20ProvSchemeDetails/README.md).

## Requirements and Availability

- An existing SCVMM MCS provisioning scheme and VM, and a Citrix SDK exposing `Get-ProvVMDetails`.
- A Windows PowerShell session with the Citrix Machine Creation snap-in installed and authenticated to the site.
  For DaaS, establish the Remote PowerShell SDK session before running the sample. For on-premises use,
  add `-AdminAddress "controller.example.com"` to the query when not using the default controller.
- Citrix administrative read access to the target provisioning scheme and VM. The hosting connection's SCVMM
  account must be able to read the target VM and the associated host and virtual disk information.
  Follow the [SCVMM hosting connection guidance][connection-guidance] for configuring that account.

The script does not connect directly to SCVMM or request additional credentials. The Citrix service uses the
existing hosting connection. No new role assignment is performed by this sample. See the
[hosting account permission checklist](../../ProvScheme/Get%20ProvSchemeDetails/README.md#hosting-account-permissions)
for the disk, version, and Hyper-V vTPM read paths. Additional minimum-role requirements still need live validation.

## Script

[Get-ProvVMDetails.ps1](Get-ProvVMDetails.ps1) is a read-only, display-oriented sample.
Set these variables near the top of the script:

1. `$provisioningSchemeName`: the MCS provisioning scheme name, passed to `-ProvisioningSchemeName`.
2. `$vmName`: the provisioned VM name, passed to `-VMName`, not its VM ID or domain-qualified account name.

Use the names shown by `Get-ProvScheme` and `Get-ProvVM`. Query one specific VM at a time.
The scheme name and VM name are both required; a scheme Uid can replace the scheme name:

```powershell
Get-ProvVMDetails -ProvisioningSchemeUid "9a9b1e6f-2d3c-4f8a-b1e2-7c4d5a6b8e90" -VMName "demo-vm"
```

The sample displays selected top-level properties and parses each section independently. The reference below
also covers properties available on the cmdlet result but not displayed by the sample. It reports blank sections,
JSON `null`, and empty objects (`{}`) without treating them as valid security or disk measurements.
Malformed JSON and query errors stop execution. A query returning no VM also stops with a descriptive error.
For automation, use the cmdlet result directly rather than consuming the sample's formatted output.

## Output Reference

The cmdlet returns a `Citrix.MachineCreation.Sdk.VMDetailsFull` object. Top-level properties are typed values;
the six section properties are JSON strings. Available fields vary with the deployed version and stored VM data.

### Top-Level Properties

| Property | Meaning |
| --- | --- |
| `Name` | Provisioned VM name. |
| `ProvisioningSchemeName`, `ProvisioningSchemeUid` | MCS provisioning scheme identity. |
| `ProvisioningSchemeVersion` | Scheme version recorded for this VM. |
| `CpuCount`, `MemoryMB` | Recorded CPU count and memory in MB; not live utilization. |
| `Persistent` | Whether the VM is persistent. |
| `IdentityType`, `DeviceManagementType` | Recorded identity and device-management configuration. |
| `Identities`, `ADAccountSid` | Identity domain information and the associated AD account SID, when applicable. |
| `WindowsActivationType` | Windows activation method recorded by MCS. |
| `ProvVMConfigurationVersion` | VM configuration version, when present. |
| `LastBootTime`, `ImageOutOfDate` | Recorded boot time and whether the VM's image is out of date. |
| `UseWriteBackCache` | Whether MCS write-back cache is configured. |
| `WriteBackCacheDiskSize` | Configured write-back cache disk size in GB. |
| `WriteBackCacheMemorySize` | Configured write-back cache memory size in MB. |
| `WriteBackCacheDriveLetter` | Write-back cache drive letter, when assigned. |
| `AssignedImageVersionSpecUid` | Assigned image-version specification Uid for image-managed VMs; otherwise null. |
| `BootedImageVersionSpecUid` | Booted image-version specification Uid for image-managed VMs; otherwise null. |

### VMInfo

| Field | Meaning and source |
| --- | --- |
| `ProvisioningSchemeType` | Scheme type recorded by MCS. |
| `UseFullDiskCloneProvisioning` | Full-disk clone setting recorded by MCS. |
| `VMId` | Hypervisor VM identifier recorded by MCS. |
| `OperatingSystemType`, `OperatingSystem` | OS type and full name from MCS image runtime information, when available. |
| `Generation` | Hyper-V VM generation from SCVMM, falling back to stored metadata when the VM cannot be read. |
| `NestedHVEnabled` | Nested virtualization setting from SCVMM, with a stored-metadata fallback. |
| `Host` | SCVMM host name; the fallback derives it from the recorded OS disk storage identifier. |
| `Cluster`, `HostGroup` | Cluster and host group from SCVMM host information, when available. |

### SecurityInfo

| Field | Meaning |
| --- | --- |
| `EnableSecureBoot` | Secure boot setting; reported as false for Generation 1 VMs. |
| `EnablevTPM` | Virtual Trusted Platform Module (vTPM) setting. |

The service uses stored metadata when it cannot read the VM. A failed vTPM query can also use metadata,
or false when metadata is unavailable. The response does not identify which values came from a fallback.
Do not use this view alone as proof of the VM's current security configuration.
Unlike the scheme view, the SCVMM VM view does not publish `HasKeyProtector`.

### DiskInfo

| Field | Meaning |
| --- | --- |
| `OSDiskStorageName` | OS disk storage identifier recorded by MCS. |
| `IdentityDiskStorageName` | Identity disk storage identifier recorded by MCS. |
| `WriteBackCacheDiskStorageName` | Temporary/write-back cache storage identifier recorded by MCS. |
| `TemporaryDiskStorageName` | Alias containing the same value as `WriteBackCacheDiskStorageName`. |
| `OSDiskName`, `OSDiskSize` | OS virtual disk name and maximum virtual capacity in whole GiB. |
| `IdentityDiskName`, `IdentityDiskSize` | Identity virtual disk name and maximum virtual capacity in whole GiB. |
| `WBCDiskName`, `WBCDiskSize` | Write-back cache virtual disk name and maximum virtual capacity in whole GiB. |

Disk names and sizes come from SCVMM's attached virtual hard disks, not filesystem usage.
Sizes are truncated to whole GiB, so a readable disk smaller than 1 GiB can report zero.
Roles for which no disk is resolved retain an empty name and zero size; other readable disks can still be reported.
Identity disk resolution first matches `_IdentityDisk` in the disk name or location filename, then falls back
to disk index 1. If the actual identity disk is unreadable, that fallback can report another disk's name and size.
Check the attached disk layout in SCVMM before relying on identity disk values during a read failure.
An empty write-back cache name is not sufficient to distinguish a VM without a cache disk from a failed disk read.
Additional data disks are not listed by this SCVMM view.

### MCSIOInfo

SCVMM currently contributes an empty object (`{}`) to this section.
Read the top-level `UseWriteBackCache`, `WriteBackCacheDiskSize`, `WriteBackCacheMemorySize`, and
`WriteBackCacheDriveLetter` properties instead. Do not infer that caching is disabled from an empty section.

### NetworkInfo

`NetworkMaps` contains the MCS-recorded network mappings as a nested JSON string.
It is not a live inventory of every network adapter. Parse it separately only after checking that it is present.
The scheme view's `NetworkInterfaceIds` array is not published by this VM view.

### ImageAndTemplateInfo

| Field | Meaning |
| --- | --- |
| `MachineProfile` | Machine profile recorded by MCS, or an empty string. |
| `AssignedImage` | Image assigned to the VM. For a path-based disk ID, SCVMM reports its final filename. |
| `BootedImage` | Image the VM last booted. For a path-based disk ID, SCVMM reports its final filename. |

Non-path image identifiers, such as `template:<guid>`, are retained. Values can be blank when unavailable.
Filenames alone need not uniquely identify an image: retain the top-level image-version specification Uids
and `ImageOutOfDate` when inspecting image-managed VMs.

## Reading a Section

This example preserves a reported false value and distinguishes a missing field from a disabled setting:

```powershell
$details = Get-ProvVMDetails -ProvisioningSchemeName "demo-provScheme" -VMName "demo-vm" -ErrorAction Stop

if ([string]::IsNullOrWhiteSpace($details.SecurityInfo)) {
    Write-Output "SecurityInfo is unavailable."
} else {
    $security = $details.SecurityInfo | ConvertFrom-Json -ErrorAction Stop
    if ($null -ne $security -and $null -ne $security.PSObject.Properties["EnableSecureBoot"]) {
        Write-Output ("Reported secure boot: {0}" -f $security.EnableSecureBoot)
    } else {
        Write-Output "Secure boot was not reported."
    }
}
```

## Leading Practices

- Treat missing fields as unknown, not false, zero, or evidence that a feature is unsupported.
- Keep the top-level MCS configuration separate from live SCVMM observations and possible metadata fallbacks.
- Compare the VM view with the scheme view when investigating differences between a VM and its catalog configuration.
- Keep queries scoped to a named VM. Each query can require hypervisor calls.
- Redact VM names, host names, storage paths, and identity information before sharing captured output.

## Common Error Scenarios

| Symptom | Checks |
| --- | --- |
| Cmdlet or snap-in not found | Verify the installed Citrix SDK, Windows PowerShell session, and deployment support. |
| No VM details returned | Verify the scheme/VM names and that the VM is an MCS-managed VM visible to the caller. |
| Permission denied | Check Citrix read permissions and the hosting connection account's SCVMM resource access. |
| Unexpected empty or partial sections | Except for the expected empty `MCSIOInfo`, check SCVMM, VM, host, and disk access. |
| Empty disk name or zero size | Check the disk in SCVMM; consider unreadable disks and whole-GiB rounding. |
| Unexpected security settings | Check the live VM in SCVMM/Hyper-V; the returned values may be metadata fallbacks. |
| Invalid JSON | Retain a redacted response and investigate the service output; do not replace it with false values. |

For persistent partial results, collect Citrix Machine Creation and Host Service diagnostic traces for the query
time and check SCVMM errors. Some service/connection failures can terminate the query instead of returning partial data.
Use the shared [trace-collection steps and diagnostic messages](../../ProvScheme/Get%20ProvSchemeDetails/README.md#troubleshooting-and-trace-collection)
to distinguish metadata fallback, disk indexing/read failures, and Hyper-V vTPM access failures.

[Get-ProvVMDetails SDK reference](https://developer-docs.citrix.com/en-us/citrix-virtual-apps-desktops-sdk/current-release/machinecreation/get-provvmdetails)

[connection-guidance]: https://docs.citrix.com/en-us/citrix-daas/install-configure/connections/connection-mscvmm
