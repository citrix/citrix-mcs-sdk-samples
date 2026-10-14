# Get Provisioning Scheme Details

## Requirements and Availability

Use an SDK and deployment that support the SCVMM fields described below.

Use Windows PowerShell with the Citrix Machine Creation snap-in installed and a Citrix account authorized
to read the target scheme. Establish a Remote PowerShell SDK session for DaaS, or use `-AdminAddress`
with the controller address for an on-premises site when needed.

## Overview
The `Get-ProvSchemeDetails` cmdlet reports the hardware configuration a machine catalog provisions with on SCVMM/Hyper-V — compute, security, disks, write-back cache, networking and the master image. It answers questions `Get-ProvScheme` cannot, such as whether a catalog provisions secure-boot machines or which OS-tier storage is available to its hosting unit.

A provisioning scheme is identified either by name or by Uid:

```powershell
Get-ProvSchemeDetails -ProvisioningSchemeName "MyCatalog"

Get-ProvSchemeDetails -ProvisioningSchemeUid "9a9b1e6f-2d3c-4f8a-b1e2-7c4d5a6b8e90"
```

The result carries the scheme identity plus six sections:

```powershell
Get-ProvSchemeDetails -ProvisioningSchemeName "MyCatalog"

ProvisioningSchemeUid     : 9a9b1e6f-2d3c-4f8a-b1e2-7c4d5a6b8e90
ProvisioningSchemeName    : MyCatalog
ProvisioningSchemeVersion : 1
SchemeInfo                : {"ProvisioningSchemeType":"MCS","OperatingSystemType":"Windows","Generation":2,...}
SecurityInfo              : {"EnableSecureBoot":true,"EnablevTPM":true,"HasKeyProtector":true}
DiskInfo                  : {"TargetOsDiskSizeInGB":127,"OSDiskStorageNames":["HV-HOST-01:C$\\ClusterStorage\\Volume1"]}
MCSIOInfo                 : {"UseWriteBackCache":true,"WriteBackCacheDiskSize":20,...}
NetworkInfo               : {"NetworkMaps":"[...]","NetworkInterfaceIds":["nic0:vlan100:synthetic"]}
ImageAndTemplateInfo      : {"MachineProfile":"","CurrentImage":"XDHyp:\\HostingUnits\\Demo\\mastervm1.vm\\snap1.snapshot"}
```

### Reading a section

**Every section is a JSON string, not an object.** Check that the section is present before converting it:

```powershell
$details = Get-ProvSchemeDetails -ProvisioningSchemeName "MyCatalog"

if ([string]::IsNullOrWhiteSpace($details.SchemeInfo)) {
    Write-Output "SchemeInfo is unavailable for '$($details.ProvisioningSchemeName)'."
} else {
    $schemeInfo = $details.SchemeInfo | ConvertFrom-Json
    $schemeInfo.Generation
}
```

Unavailable plugin fields can be omitted. MCS-seeded fields can instead contain null or empty values,
and a section can be an empty object (`{}`). Test for both the section and the field before depending on it.

### What each section reports

| Section | Reports |
| --- | --- |
| `SchemeInfo` | Hyper-V generation, CPU count, memory, dynamic memory range, nested virtualization, host group or cluster, SCVMM server version |
| `SecurityInfo` | Secure boot, vTPM, whether a key protector exists |
| `DiskInfo` | Recorded target OS disk size and available hosting-unit OS-tier storage |
| `MCSIOInfo` | Write-back cache on/off, disk and memory size, drive letter, temporary storage |
| `NetworkInfo` | Recorded network mappings and provisioned NIC descriptions in `NetworkInterfaceIds` |
| `ImageAndTemplateInfo` | Current master image, and the machine profile when the catalog uses one |

### Output Field Reference

The result is a `Citrix.MachineCreation.Sdk.ProvisioningSchemeDetailsFull` object.
`ProvisioningSchemeUid` is a Guid, `ProvisioningSchemeName` is a string, and `ProvisioningSchemeVersion`
is an integer. The remaining six properties are JSON strings.

| Section | Fields | Meaning and source |
| --- | --- | --- |
| `SchemeInfo` | `ProvisioningSchemeType` | Scheme type recorded by MCS. |
| `SchemeInfo` | `OperatingSystemType`, `OperatingSystem` | OS type and full name from recorded image runtime information; can be null. |
| `SchemeInfo` | `CpuCount`, `MemoryMB` | Configured processor count and startup memory in MB from the scheme. |
| `SchemeInfo` | `Generation` | Recorded Hyper-V generation; an unset generation is reported as 1. |
| `SchemeInfo` | `NestedHVEnabled` | Nested virtualization setting from stored template metadata. |
| `SchemeInfo` | `DynamicMemoryEnabled` | Recorded setting, disabled when the hosting connection disables dynamic memory. |
| `SchemeInfo` | `DynamicMemoryMinimumMB`, `DynamicMemoryMaximumMB` | Effective dynamic memory limits in MB; included only when dynamic memory is enabled. The maximum accommodates the configured startup memory. |
| `SchemeInfo` | `ScvmmServerVersion` | Version from the existing SCVMM connection, when available. |
| `SchemeInfo` | `Host`, `HostGroup`, `Cluster` | The matching hosting-unit root placement name; these are not an inventory of every possible destination. |
| `SecurityInfo` | `EnableSecureBoot` | Recorded secure boot setting, false for Generation 1. |
| `SecurityInfo` | `EnablevTPM` | Recorded virtual Trusted Platform Module (vTPM) setting. |
| `SecurityInfo` | `HasKeyProtector` | Whether recorded metadata contains a key protector, never the protector value. |
| `DiskInfo` | `TargetOsDiskSizeInGB` | Target OS disk size recorded by MCS; not a measurement of a provisioned disk. |
| `DiskInfo` | `OSDiskStorageNames` | Available, non-superseded OS-tier storage for the hosting unit, resolved as `host:path`; an unresolved entry can retain its raw ID. Not proof that an image replica exists on every entry. |
| `MCSIOInfo` | `UseWriteBackCache` | Whether write-back cache is configured on the scheme. |
| `MCSIOInfo` | `WriteBackCacheDiskSize`, `WriteBackCacheMemorySize` | Configured cache disk size in GB and cache memory size in MB. |
| `MCSIOInfo` | `WriteBackCacheDriveLetter` | Assigned alphabetic drive letter, present only when caching is enabled and a letter is assigned. |
| `MCSIOInfo` | `TemporaryStorageNames` | Non-superseded temporary/cache-tier storage, resolved as `host:path` or retained as a raw ID. |
| `NetworkInfo` | `NetworkMaps` | MCS-recorded mappings as a nested JSON string; parse separately. `[]` means no explicit mappings, while a missing value can indicate a lookup failure. |
| `NetworkInfo` | `NetworkInterfaceIds` | Flat string descriptions of template NICs selected by the scheme mappings. Omitted when the NIC count cannot be determined. |
| `ImageAndTemplateInfo` | `MachineProfile` | Recorded machine profile, or an empty string. |
| `ImageAndTemplateInfo` | `ImageDefinitionName`, `ImageVersionNumber` | Recorded image-management definition and version strings; empty when not set. |
| `ImageAndTemplateInfo` | `CurrentImage` | Recorded master-image path, when available. |

Hardware and security describe the stored provisioning configuration, not a fresh inspection of a master VM
or every provisioned VM. The view also resolves placement/storage through the hosting connection.
It does not label individual values with their age or source. Use the
[VM details view](../../ProvVm/Get%20ProvVMDetails/README.md) to inspect one provisioned machine.

### Checking the security posture of a catalog

```powershell
$details = Get-ProvSchemeDetails -ProvisioningSchemeName "MyCatalog"

if ([string]::IsNullOrWhiteSpace($details.SecurityInfo)) {
    Write-Output "SecurityInfo is unavailable for '$($details.ProvisioningSchemeName)'."
} else {
    $details.SecurityInfo | ConvertFrom-Json
}

EnableSecureBoot EnablevTPM HasKeyProtector
---------------- ---------- ---------------
            True       True            True
```

`EnableSecureBoot` is always `False` on Generation 1 VMs — secure boot is a Generation 2 feature, so the value is reported as false there regardless of what the catalog recorded.

`HasKeyProtector` reports only whether a key protector exists. The protector itself is a secret and is never returned.

### Auditing every catalog in the site

```powershell
Get-ProvScheme | ForEach-Object {
    $details = Get-ProvSchemeDetails -ProvisioningSchemeName $_.ProvisioningSchemeName

    if ([string]::IsNullOrWhiteSpace($details.SecurityInfo)) {
        [PSCustomObject]@{
            Name       = $details.ProvisioningSchemeName
            SecureBoot = "Unavailable"
            vTPM       = "Unavailable"
        }
    } else {
        $security = $details.SecurityInfo | ConvertFrom-Json

        [PSCustomObject]@{
            Name       = $details.ProvisioningSchemeName
            SecureBoot = $security.EnableSecureBoot
            vTPM       = $security.EnablevTPM
        }
    }
} | Format-Table

Name      SecureBoot vTPM
----      ---------- ----
CatalogA        True True
CatalogB       False False
CatalogC Unavailable Unavailable
```

### Listing Available OS-Tier Storage

```powershell
$details = Get-ProvSchemeDetails -ProvisioningSchemeName "MyCatalog"

if ([string]::IsNullOrWhiteSpace($details.DiskInfo)) {
    Write-Output "DiskInfo is unavailable for '$($details.ProvisioningSchemeName)'."
} else {
    ($details.DiskInfo | ConvertFrom-Json).OSDiskStorageNames
}

HV-HOST-01:C$\ClusterStorage\Volume1
HV-HOST-02:C$\ClusterStorage\Volume2
```

### Listing the network adapters

```powershell
$details = Get-ProvSchemeDetails -ProvisioningSchemeName "MyCatalog"

if ([string]::IsNullOrWhiteSpace($details.NetworkInfo)) {
    Write-Output "NetworkInfo is unavailable for '$($details.ProvisioningSchemeName)'."
} else {
    ($details.NetworkInfo | ConvertFrom-Json).NetworkInterfaceIds
}

nic0:vlan100:synthetic
```

`NetworkInterfaceIds` is an array of strings in `nic<slot>:<vlan>:<adapter>` format.
The VLAN component is `vlan<id>` or `untagged`; the adapter is `synthetic` or `emulated`.
It describes the template NICs selected by the scheme's network mappings, not live VM adapters.
The template VLAN is not proof of the applied VM VLAN, which also depends on `New-ProvVM -AutoAssignVLAN`.

Section-building failures can return partial information. This does not guarantee every query succeeds:
SDK, authorization, and service failures can still terminate the command. Treat missing data as unknown,
not as false or evidence that a feature is disabled.

## Hosting Account Permissions

The SDK caller needs Citrix read access. Hypervisor queries use the existing hosting connection account,
not the caller's interactive SCVMM session. These samples do not change roles or request new credentials.
Follow the [Citrix SCVMM resource-location prerequisites][scvmm-prerequisites]: the connection account
must have the documented VMM administrator or delegated-administrator access to the relevant hosts,
with local administrator membership on Hyper-V hosts for the supported VM lifecycle configuration.
The guidance also warns that delegated-administrator scope can affect storage visibility.
This baseline is not a claim that full administrator access is the minimum required for a details query.

| Read path | Access to verify with the hosting connection account |
| --- | --- |
| Scheme placement and storage | Hosting-unit root, host group/cluster, and OS/temporary storage in the account's scope. |
| SCVMM server version | The established VMM connection and its `ProductVersion`; the view uses cached connection metadata rather than a separate version-query cmdlet. |
| VM placement and disk details | The target VM, its host information, and attached `VirtualDiskDrives`/`VirtualHardDisk` properties. Disk size is read from the VM object, not by opening guest files. |
| VM vTPM | The Hyper-V host connection and the existing vTPM/key-protector read operation. A VMM inventory read succeeding does not prove this access succeeds. |

The implementation adds no role assignment or distinct disk/version permission grant. A supported-version,
least-privilege validation is still required before asserting that no additional permissions are needed.
Validate both details cmdlets with the intended account scope, including readable disks, version data,
and a Gen2 VM with vTPM. Retain the exact access-denied error and missing field when a read fails.
Do not broaden permissions merely to turn an empty section into output, and never collect key-protector values.

## Troubleshooting and Trace Collection

1. Record the SDK/service and SCVMM versions, scheme name/Uid/version, hosting connection, query time and time zone.
    For a VM query, include the VM name and hypervisor ID. Keep identifiers in an access-controlled support record.
2. Capture Citrix Diagnostic Facility (CDF) traces for Machine Creation Service, Host Service, and the process
    hosting the SCVMM Hypervisor Communication Library (HCL) plugin. Include the remote HCL host when that deployment
    uses one. Start tracing before a single named query and stop immediately afterward.
3. Retain the command, its error record, and raw section JSON. Correlate that interval with SCVMM and Hyper-V errors.
    Follow your deployment's supported CDF collection procedure; provider selection and process location vary.
4. Use the message fragments below to locate the failed stage. A returned object alone does not prove every read worked.
5. Redact VM/host names, paths, account identifiers, and other customer information before sharing outside the support case.
    Do not export credentials, raw VM metadata, or key-protector material.

| Missing or unexpected data | Diagnostic message fragments and checks |
| --- | --- |
| Most plugin fields absent | `Failed to resolve hosting/capabilities for provisioning scheme details` or `Failed to get provisioning scheme details from hypervisor`; check deployment support and hosting access. |
| Scheme hardware/security absent | `no VMMetadata on the scheme` or `Unable to parse VMMetadata`; recorded metadata is missing or unreadable, not evidence of disabled security. |
| One scheme section incomplete | `Failed to build SchemeDetails.` followed by the section name and exception. |
| Scheme NIC descriptions absent | `Failed to get provisioning scheme NetworkMaps from DB` or `Unable to parse NetworkMaps`; distinguish unavailable mappings from valid `[]`. |
| Storage names are raw IDs | `Failed to resolve storage`; verify the account's scope and storage availability. |
| VM data falls back to recorded values | `Failed to get VM with vmId`, `Falling back to last known configuration`, or `GetVmInfoFallback failed`. |
| VM disk names/sizes absent | `Unable to index the VM's disk drives`, `Unable to read disk at index`, or `Failed to build VMDetails.DiskInfo`; check attached VHD visibility and role assignment. |
| Unexpected VM vTPM value | `Failed to get vtpm information`; check Hyper-V connectivity and access. Metadata or false can be returned after this failure. |
| Empty VM `MCSIOInfo` | Expected for SCVMM. Use top-level cache settings; this alone is not a failed read. |

## Leading Practices

- Query a named scheme or VM first; an all-catalog audit makes repeated hosting queries.
- Preserve false values but treat missing/null fields as unknown.
- Compare scheme configuration with individual VM observations without assuming they describe the same point in time.
- Investigate empty sections before using their contents for a security or capacity decision.

[Get-ProvSchemeDetails Documentation](https://developer-docs.citrix.com/en-us/citrix-virtual-apps-desktops-sdk/current-release/machinecreation/get-provschemedetails)

[scvmm-prerequisites]: https://docs.citrix.com/en-us/citrix-daas/install-configure/resource-location/msscvmm
