# Search Golden Image Inventory

> Part of [XenServer Inventory Search](../README.md) — see it for common end-to-end workflows.

## Minimum version requirement

- **On-premises (CVAD):** Citrix Virtual Apps and Desktops **2611** or later.
- **Citrix DaaS (Cloud):** first shipped in Citrix DaaS release **131**. Citrix DaaS is updated
  continuously by Citrix, so Cloud tenants receive the feature automatically — there is no release
  number to install or check. Just keep your
  [Remote PowerShell SDK](https://docs.citrix.com/en-us/citrix-daas/sdk-api.html) up to date.

## Overview

Searches for golden images (master images) on a XenServer hosting connection using server-side name and tag filtering with continuation-token pagination, via [`Search-HypGoldenImageInventory`](https://developer-docs.citrix.com/en-us/citrix-daas-sdk/hostservice/search-hypgoldenimageinventory). On XenServer a golden image can be a **template** or a **snapshot** — both are valid master images for catalog creation, and this cmdlet returns both.

The hosting connection must advertise the `SupportsFilteredGoldenImageInventory` capability; XenServer connections do.

## Output

Each call returns a single object with `Items`, `TotalItems`, and `ContinuationToken`. Each item exposes `Name`, `ItemType` (`template` or `snapshot`), `Id`, `RelativePath`, `IsContainer`, and `AdditionalExtensionData`.

## How templates and snapshots are returned (read this first)

This is the most important thing to understand about golden images on XenServer:

- **A root call (no `-Subpath`) returns TEMPLATES only.** Snapshots are *not* listed at the root.
- **Snapshots are nested under a VM.** They are returned only when the search is scoped to that VM with `-Subpath`. A single `-Subpath` call returns only the **first level** of that VM's snapshots — walk each snapshot's `RelativePath` back into `-Subpath` to reach deeper levels (snapshot chains can be many levels deep).
- **This cmdlet never returns VMs.** Its filter is templates + snapshots only. The VM path you feed into `-Subpath` comes from [`Search-HypVirtualMachineInventory`](../Search%20VM%20Inventory/README.md) — carry its `RelativePath` through unchanged; do not hand-build paths. The same handle works for VM→snapshot and snapshot→snapshot.

To list snapshots, scope the search to a specific VM with `-Subpath`. A single call cannot return a flat list of all snapshots across every VM on the connection.

## Examples

The examples below run against the fictional connection **`XS-Pool-01`** (UID `9b7c1f3e-2a4d-4c6b-8e1f-0d5a6b7c8d9e`). Its templates (root-level results):

| Name | ItemType | RelativePath | Tags |
| --- | --- | --- | --- |
| WIN11-GOLD-TMPL | template | /WIN11-GOLD-TMPL.template | gold, approved |
| WIN10-GOLD-TMPL | template | /WIN10-GOLD-TMPL.template | gold |
| UBUNTU-BASE-TMPL | template | /UBUNTU-BASE-TMPL.template | _(none)_ |

Snapshots live under VMs (see the [Working with snapshots](#working-with-snapshots) section), e.g. under `/win11-2507vda.vm`.

### `-HypervisorConnectionName` — root call (templates only)

```powershell
$r = Search-HypGoldenImageInventory -HypervisorConnectionName "XS-Pool-01"
$r.Items | Select-Object Name, ItemType, RelativePath
# WIN11-GOLD-TMPL   template  /WIN11-GOLD-TMPL.template
# WIN10-GOLD-TMPL   template  /WIN10-GOLD-TMPL.template
# UBUNTU-BASE-TMPL  template  /UBUNTU-BASE-TMPL.template
```

### `-HypervisorConnectionUid` — select the connection by UID

```powershell
Search-HypGoldenImageInventory -HypervisorConnectionUid "9b7c1f3e-2a4d-4c6b-8e1f-0d5a6b7c8d9e"
```

### `-NameContains` — filter by name substring

```powershell
(Search-HypGoldenImageInventory -HypervisorConnectionName "XS-Pool-01" -NameContains "win11").Items |
    Select-Object Name, ItemType
# WIN11-GOLD-TMPL   template
```

### `-Tags` — filter by tag (case-insensitive, any-match)

Tags are honored for golden images (unlike the VM and machine-profile cmdlets).

```powershell
(Search-HypGoldenImageInventory -HypervisorConnectionName "XS-Pool-01" -Tags "approved").Items |
    Select-Object Name
# WIN11-GOLD-TMPL             (only the template tagged "approved")

(Search-HypGoldenImageInventory -HypervisorConnectionName "XS-Pool-01" -Tags "gold","approved").Items |
    Select-Object Name
# WIN11-GOLD-TMPL             (any-match: carries "gold" or "approved")
# WIN10-GOLD-TMPL
```

### `-SortBy` / `-SortOrder`

```powershell
(Search-HypGoldenImageInventory -HypervisorConnectionName "XS-Pool-01" `
    -SortBy Name -SortOrder Descending).Items | Select-Object Name
# WIN11-GOLD-TMPL
# WIN10-GOLD-TMPL
# UBUNTU-BASE-TMPL
```

### `-MaxRecordCount` and `-ContinuationToken` — paging

```powershell
$page1 = Search-HypGoldenImageInventory -HypervisorConnectionName "XS-Pool-01" -MaxRecordCount 2
$page1.Items | Select-Object Name          # WIN11-GOLD-TMPL, WIN10-GOLD-TMPL
$page2 = Search-HypGoldenImageInventory -HypervisorConnectionName "XS-Pool-01" -MaxRecordCount 2 `
            -ContinuationToken $page1.ContinuationToken
$page2.Items | Select-Object Name          # UBUNTU-BASE-TMPL
```

### `-MaxRecordCount 0` — count-only query

```powershell
(Search-HypGoldenImageInventory -HypervisorConnectionName "XS-Pool-01" -Tags "gold" -MaxRecordCount 0).TotalItems
# 2
```

### `-Subpath` — list a VM's snapshots

See [Working with snapshots](#working-with-snapshots) below for the full flow.

```powershell
(Search-HypGoldenImageInventory -HypervisorConnectionName "XS-Pool-01" -Subpath "/win11-2507vda.vm").Items |
    Select-Object Name, ItemType, RelativePath
# win11-2507vda-snap   snapshot  /win11-2507vda.vm/win11-2507vda-snap.snapshot   (first level only)
```

### `-IncludeProvisionedResources` and `-AdminAddress`

```powershell
# Include MCS-provisioned resources (excluded by default):
Search-HypGoldenImageInventory -HypervisorConnectionName "XS-Pool-01" -IncludeProvisionedResources

# Target a specific on-prem Delivery Controller:
Search-HypGoldenImageInventory -HypervisorConnectionName "XS-Pool-01" -AdminAddress "ddc01.contoso.local"
```

## Combined scenarios

### Approved Windows images, sorted, first page

```powershell
$page = Search-HypGoldenImageInventory -HypervisorConnectionName "XS-Pool-01" `
    -NameContains "win" -Tags "approved" -SortBy Name -SortOrder Ascending -MaxRecordCount 50
$page.Items | Select-Object Name, ItemType
# WIN11-GOLD-TMPL   template
```

### Count first, then fetch (splatted shared parameters)

```powershell
$common = @{
    HypervisorConnectionName = "XS-Pool-01"
    Tags                     = "gold"
    SortBy                   = "Name"
}
$total = (Search-HypGoldenImageInventory @common -MaxRecordCount 0).TotalItems   # 2
$first = Search-HypGoldenImageInventory @common -MaxRecordCount 50
Write-Host "Showing $($first.Items.Count) of $total gold-tagged images"          # Showing 2 of 2 gold-tagged images
```

## Working with snapshots

On XenServer, snapshots surface only when you scope the search to a specific VM. Because this cmdlet never returns VMs, the flow uses **two cmdlets**: `Search-HypVirtualMachineInventory` provides the VM path, and `Search-HypGoldenImageInventory -Subpath <thatPath>` lists its snapshots.

### 1. Templates (root call)

```powershell
$r = Search-HypGoldenImageInventory -HypervisorConnectionName "XS-Pool-01"
$r.Items | Select-Object Name, ItemType, RelativePath      # templates only
```

### 2. VMs — where the path comes from

```powershell
$vms = Search-HypVirtualMachineInventory -HypervisorConnectionName "XS-Pool-01"
$vms.Items | Select-Object Name, RelativePath
# win11-2507vda   /win11-2507vda.vm
```

### 3. First level of a VM's snapshots — feed its `RelativePath` into `-Subpath`

```powershell
$vmPath = ($vms.Items | Where-Object Name -eq "win11-2507vda").RelativePath   # /win11-2507vda.vm
$snaps  = Search-HypGoldenImageInventory -HypervisorConnectionName "XS-Pool-01" -Subpath $vmPath
$snaps.Items | Select-Object Name, ItemType, RelativePath
# win11-2507vda-snap   snapshot   /win11-2507vda.vm/win11-2507vda-snap.snapshot
```

### 4. All snapshot levels — recursive helper

A single `-Subpath` call returns only the first level, so walk each snapshot's `RelativePath` back into `-Subpath`. `-OutVariable` collects into an array, hence the `[0]` when reading `.Items`.

```powershell
function Get-XenSnapshotTree {
    param($ConnectionName, $Path, $Level = 1)

    $page = $null
    try {
        Search-HypGoldenImageInventory -HypervisorConnectionName $ConnectionName `
            -Subpath $Path -OutVariable page -ErrorAction Stop | Out-Null
    } catch { }

    if ($page -and $page[0] -and $page[0].Items) {
        foreach ($item in $page[0].Items) {
            if ($item.ItemType -eq 'snapshot') {
                $item | Add-Member -NotePropertyName Level -NotePropertyValue $Level -Force -PassThru
                Get-XenSnapshotTree -ConnectionName $ConnectionName -Path $item.RelativePath -Level ($Level + 1)
            }
        }
    }
}

Get-XenSnapshotTree -ConnectionName "XS-Pool-01" -Path "/win11-2507vda.vm" |
    Format-Table Level, Name, ItemType, RelativePath

# Level Name                 ItemType RelativePath
# ----- ----                 -------- ------------
#     1 win11-2507vda-snap   snapshot /win11-2507vda.vm/win11-2507vda-snap.snapshot
#     2 win11-2507vda-snap2  snapshot /win11-2507vda.vm/.../win11-2507vda-snap2.snapshot
#     3 win11-2507vda-snap3  snapshot /win11-2507vda.vm/.../win11-2507vda-snap3.snapshot
#     4 win11-2507vda-base   snapshot .../...
```

A VM can have a multi-level snapshot chain. The same "carry the parent's `RelativePath` into the child's `-Subpath`" rule drives both VM→snapshot and snapshot→snapshot navigation.

## Using the sample script

`Search-GoldenImageInventory.ps1` wraps the cmdlet, handles the forward-paging loop, and exposes the XenServer-relevant parameters (including `-Tags` and `-Subpath`). See its comment-based help (`Get-Help .\Search-GoldenImageInventory.ps1 -Full`) for the full example set.

```powershell
# Templates (root):
.\Search-GoldenImageInventory.ps1 -ConnectionName "XS-Pool-01"

# Approved Windows images:
.\Search-GoldenImageInventory.ps1 -ConnectionName "XS-Pool-01" -NameContains "win" -Tags "approved"

# First level of a VM's snapshots:
.\Search-GoldenImageInventory.ps1 -ConnectionName "XS-Pool-01" -Subpath "/win11-2507vda.vm"
```
