# Search Machine Profile Inventory

> Part of [XenServer Inventory Search](../README.md) — see it for common end-to-end workflows.

## Minimum version requirement

- **On-premises (CVAD):** Citrix Virtual Apps and Desktops **2611** or later.
- **Citrix DaaS (Cloud):** first shipped in Citrix DaaS release **131**. Citrix DaaS is updated
  continuously by Citrix, so Cloud tenants receive the feature automatically — there is no release
  number to install or check. Just keep your
  [Remote PowerShell SDK](https://docs.citrix.com/en-us/citrix-daas/sdk-api.html) up to date.

## Overview

Searches for machine-profile sources on a XenServer hosting connection using server-side name filtering and continuation-token pagination, via [`Search-HypMachineProfileInventory`](https://developer-docs.citrix.com/en-us/citrix-daas-sdk/hostservice/search-hypmachineprofileinventory). On XenServer, a machine profile can be sourced from a **VM**, a **template**, or a **snapshot** — the hardware settings captured from the chosen source are applied to provisioned machines.

The hosting connection must advertise the `SupportsFilteredMachineProfileInventory` capability; XenServer connections do.

## Output

Each call returns a single object with `Items`, `TotalItems`, and `ContinuationToken`. Each item exposes `Name`, `ItemType` (`vm`, `template`, or `snapshot`), `Id`, `RelativePath`, `IsContainer`, and `AdditionalExtensionData`.

## How sources are returned (read this first)

Machine-profile sources on XenServer are VMs, templates, and snapshots, but they are not all returned at the same level:

- **A root call (no `-Subpath`) returns VMs and TEMPLATES only.** Snapshots are *not* listed at the root.
- **Snapshots are nested under a VM** and are returned only when the search is scoped to that VM with `-Subpath`. A single `-Subpath` call returns only the **first level**; walk each snapshot's `RelativePath` back into `-Subpath` to reach deeper levels.

Unlike `Search-HypGoldenImageInventory`, this cmdlet *does* return VMs at the root, so the VM path for `-Subpath` is available directly from its own root results (no second cmdlet needed).

## Examples

The examples below run against the fictional connection **`XS-Pool-01`** (UID `9b7c1f3e-2a4d-4c6b-8e1f-0d5a6b7c8d9e`). Its root-level sources (VMs + templates):

| Name | ItemType | RelativePath |
| --- | --- | --- |
| win11-2507vda | vm | /win11-2507vda.vm |
| WEB-01 | vm | /WEB-01.vm |
| WIN11-GOLD-TMPL | template | /WIN11-GOLD-TMPL.template |
| WIN10-GOLD-TMPL | template | /WIN10-GOLD-TMPL.template |

Snapshots live under VMs (see [Working with snapshots](#working-with-snapshots)), e.g. under `/win11-2507vda.vm`.

### `-HypervisorConnectionName` — root call (VMs + templates)

```powershell
$r = Search-HypMachineProfileInventory -HypervisorConnectionName "XS-Pool-01"
$r.Items | Select-Object Name, ItemType, RelativePath
# win11-2507vda     vm        /win11-2507vda.vm
# WEB-01            vm        /WEB-01.vm
# WIN11-GOLD-TMPL   template  /WIN11-GOLD-TMPL.template
# WIN10-GOLD-TMPL   template  /WIN10-GOLD-TMPL.template
```

### `-HypervisorConnectionUid` — select the connection by UID

```powershell
Search-HypMachineProfileInventory -HypervisorConnectionUid "9b7c1f3e-2a4d-4c6b-8e1f-0d5a6b7c8d9e"
```

### `-NameContains` — filter by name substring

```powershell
(Search-HypMachineProfileInventory -HypervisorConnectionName "XS-Pool-01" -NameContains "win11").Items |
    Select-Object Name, ItemType
# win11-2507vda     vm
# WIN11-GOLD-TMPL   template
```

### `-SortBy` / `-SortOrder`

```powershell
(Search-HypMachineProfileInventory -HypervisorConnectionName "XS-Pool-01" `
    -SortBy Name -SortOrder Descending).Items | Select-Object Name, ItemType
# win11-2507vda     vm
# WIN11-GOLD-TMPL   template
# WIN10-GOLD-TMPL   template
# WEB-01            vm
```

### `-MaxRecordCount` and `-ContinuationToken` — paging

```powershell
$page1 = Search-HypMachineProfileInventory -HypervisorConnectionName "XS-Pool-01" -MaxRecordCount 2
$page1.Items | Select-Object Name          # win11-2507vda, WEB-01
$page2 = Search-HypMachineProfileInventory -HypervisorConnectionName "XS-Pool-01" -MaxRecordCount 2 `
            -ContinuationToken $page1.ContinuationToken
$page2.Items | Select-Object Name          # WIN11-GOLD-TMPL, WIN10-GOLD-TMPL
```

### `-MaxRecordCount 0` — count-only query

```powershell
(Search-HypMachineProfileInventory -HypervisorConnectionName "XS-Pool-01" -NameContains "win" -MaxRecordCount 0).TotalItems
# 3   (win11-2507vda, WIN11-GOLD-TMPL, WIN10-GOLD-TMPL)
```

### `-Subpath` — list a VM's snapshots as profile sources

```powershell
(Search-HypMachineProfileInventory -HypervisorConnectionName "XS-Pool-01" -Subpath "/win11-2507vda.vm").Items |
    Select-Object Name, ItemType, RelativePath
# win11-2507vda-snap   snapshot  /win11-2507vda.vm/win11-2507vda-snap.snapshot   (first level only)
```

### `-IncludeProvisionedResources` and `-AdminAddress`

```powershell
# Include MCS-provisioned resources (excluded by default):
Search-HypMachineProfileInventory -HypervisorConnectionName "XS-Pool-01" -IncludeProvisionedResources

# Target a specific on-prem Delivery Controller:
Search-HypMachineProfileInventory -HypervisorConnectionName "XS-Pool-01" -AdminAddress "ddc01.contoso.local"
```

### Parameters accepted but ignored on XenServer

```powershell
# -Tags is honored only by Search-HypGoldenImageInventory; ignored here.
Search-HypMachineProfileInventory -HypervisorConnectionName "XS-Pool-01" -Tags "gold"

# -RequireHibernationSupport: XenServer exposes no hibernation metadata, so this never filters.
Search-HypMachineProfileInventory -HypervisorConnectionName "XS-Pool-01" -RequireHibernationSupport
```

## Combined scenarios

### Windows profile sources, sorted, first page

```powershell
$page = Search-HypMachineProfileInventory -HypervisorConnectionName "XS-Pool-01" `
    -NameContains "win" -SortBy Name -SortOrder Ascending -MaxRecordCount 50
$page.Items | Select-Object Name, ItemType
# WIN10-GOLD-TMPL   template
# WIN11-GOLD-TMPL   template
# win11-2507vda     vm
```

### Count first, then fetch (splatted shared parameters)

```powershell
$common = @{
    HypervisorConnectionName = "XS-Pool-01"
    NameContains             = "win"
    SortBy                   = "Name"
}
$total = (Search-HypMachineProfileInventory @common -MaxRecordCount 0).TotalItems   # 3
$first = Search-HypMachineProfileInventory @common -MaxRecordCount 50
Write-Host "Showing $($first.Items.Count) of $total matching sources"               # Showing 3 of 3 matching sources
```

### Pick a VM from the root, then list its snapshots

Because the root already returns VMs, carry a VM's `RelativePath` straight into `-Subpath`.

```powershell
$root   = Search-HypMachineProfileInventory -HypervisorConnectionName "XS-Pool-01"
$vmPath = ($root.Items | Where-Object { $_.ItemType -eq 'vm' -and $_.Name -eq 'win11-2507vda' }).RelativePath
$snaps  = Search-HypMachineProfileInventory -HypervisorConnectionName "XS-Pool-01" -Subpath $vmPath
$snaps.Items | Select-Object Name, ItemType, RelativePath
# win11-2507vda-snap   snapshot  /win11-2507vda.vm/win11-2507vda-snap.snapshot
```

## Working with snapshots

A single `-Subpath` call returns only the first level of a VM's snapshots. To enumerate every level, walk each snapshot's `RelativePath` back into `-Subpath`. `-OutVariable` collects into an array, hence the `[0]` when reading `.Items`.

```powershell
function Get-XenMachineProfileSnapshotTree {
    param($ConnectionName, $Path, $Level = 1)

    $page = $null
    try {
        Search-HypMachineProfileInventory -HypervisorConnectionName $ConnectionName `
            -Subpath $Path -OutVariable page -ErrorAction Stop | Out-Null
    } catch { }

    if ($page -and $page[0] -and $page[0].Items) {
        foreach ($item in $page[0].Items) {
            if ($item.ItemType -eq 'snapshot') {
                $item | Add-Member -NotePropertyName Level -NotePropertyValue $Level -Force -PassThru
                Get-XenMachineProfileSnapshotTree -ConnectionName $ConnectionName -Path $item.RelativePath -Level ($Level + 1)
            }
        }
    }
}

Get-XenMachineProfileSnapshotTree -ConnectionName "XS-Pool-01" -Path "/win11-2507vda.vm" |
    Format-Table Level, Name, ItemType, RelativePath
```

## Using the sample script

`Search-MachineProfileInventory.ps1` wraps the cmdlet, handles the forward-paging loop, and exposes the XenServer-relevant parameters. See its comment-based help (`Get-Help .\Search-MachineProfileInventory.ps1 -Full`) for the full example set.

```powershell
# VMs + templates (root):
.\Search-MachineProfileInventory.ps1 -ConnectionName "XS-Pool-01"

# Windows sources only:
.\Search-MachineProfileInventory.ps1 -ConnectionName "XS-Pool-01" -NameContains "win"

# First level of a VM's snapshots:
.\Search-MachineProfileInventory.ps1 -ConnectionName "XS-Pool-01" -Subpath "/win11-2507vda.vm"
```
