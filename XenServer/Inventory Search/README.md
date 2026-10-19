# XenServer Inventory Search

Server-side, paginated, name/tag-filtered inventory search for XenServer hosting connections, so you can locate VMs, master images, and machine profiles without loading the full inventory.

Three cmdlets, one resource type each:

| Cmdlet | Use | Folder |
| --- | --- | --- |
| [`Search-HypVirtualMachineInventory`](./Search%20VM%20Inventory/README.md) | Find VMs (e.g. for power-managed catalogs) | `Search VM Inventory/` |
| [`Search-HypGoldenImageInventory`](./Search%20Golden%20Image%20Inventory/README.md) | Find master images (templates + snapshots) | `Search Golden Image Inventory/` |
| [`Search-HypMachineProfileInventory`](./Search%20Machine%20Profile%20Inventory/README.md) | Find machine-profile sources | `Search Machine Profile Inventory/` |

These cmdlets are additive — they don't change `Get-HypInventoryItem` or the `XDHyp:\` provider.

## Core concepts (all three)

- **One resource type per call.** Call the cmdlet for the resource type you need; there is no single mixed-type search.
- **Root vs. nested items.** VMs and templates are returned at the root. **Snapshots are nested under a VM** and are returned only when you scope the search to that VM with `-Subpath`. A single `-Subpath` call returns only the *first* level; walk each item's `RelativePath` back into `-Subpath` for deeper levels.
- **Navigating a tree.** To expand a node, pass its `RelativePath` as `-Subpath`. Carry the value through unchanged (don't hand-build paths). The same rule drives VM→snapshot and snapshot→snapshot.
- **Filters and shape.** `-NameContains` (all three), `-Tags` (**golden image only**), `-SortBy`/`-SortOrder`, forward-only `-ContinuationToken` paging, and `-MaxRecordCount 0` for a count-only query. Every call returns `{ Items, TotalItems, ContinuationToken }`.

### What each cmdlet returns

| Cmdlet | Root-level items | Under `-Subpath <VM>` | `-Tags` |
| --- | --- | --- | --- |
| `Search-HypVirtualMachineInventory` | VMs | — | ignored |
| `Search-HypGoldenImageInventory` | **Templates only** | first level of that VM's snapshots | **honored** |
| `Search-HypMachineProfileInventory` | **VMs + Templates** | first level of that VM's snapshots | ignored |

Golden Image never returns VMs; Machine Profile does. That difference decides how many cmdlets a tree needs (below).

## Common workflows

### 1. Find a VM by name

A flat, name-filtered VM list (for example, when importing VMs for power-managed catalogs). One cmdlet, root call.

```powershell
$page = Search-HypVirtualMachineInventory -HypervisorConnectionName "XS-Pool-01" `
    -NameContains "web" -SortBy Name -MaxRecordCount 50
$page.Items | Select-Object Name, RelativePath
```

See [Search VM Inventory](./Search%20VM%20Inventory/README.md).

### 2. Find a master image (template or snapshot)

Snapshots are not at the root, so listing a VM's snapshots needs the VM path — and the golden-image cmdlet never returns VMs, so the VM path comes from `Search-HypVirtualMachineInventory`.

```powershell
# a) Templates (root call):
$templates = Search-HypGoldenImageInventory -HypervisorConnectionName "XS-Pool-01"
$templates.Items | Select-Object Name, ItemType, RelativePath

# b) VMs — the source of the path:
$vms = Search-HypVirtualMachineInventory -HypervisorConnectionName "XS-Pool-01"

# c) A chosen VM's snapshots — feed its RelativePath into -Subpath:
$vmPath = ($vms.Items | Where-Object Name -eq "win11-2507vda").RelativePath
$snaps  = Search-HypGoldenImageInventory -HypervisorConnectionName "XS-Pool-01" -Subpath $vmPath
$snaps.Items | Where-Object ItemType -eq 'snapshot' | Select-Object Name, RelativePath
```

For every snapshot level, use the recursive helper in [Search Golden Image Inventory](./Search%20Golden%20Image%20Inventory/README.md#working-with-snapshots).

### 3. Find a machine profile

Machine-profile sources are VM + template + snapshot, and the root already returns VMs + templates, so one cmdlet is enough: root for the top level, `-Subpath` to expand a VM into its snapshots.

```powershell
$root = Search-HypMachineProfileInventory -HypervisorConnectionName "XS-Pool-01"
$root.Items | Select-Object Name, ItemType, RelativePath

$vmPath = ($root.Items | Where-Object { $_.ItemType -eq 'vm' -and $_.Name -eq 'win11-2507vda' }).RelativePath
$snaps  = Search-HypMachineProfileInventory -HypervisorConnectionName "XS-Pool-01" -Subpath $vmPath
$snaps.Items | Select-Object Name, ItemType, RelativePath
```

See [Search Machine Profile Inventory](./Search%20Machine%20Profile%20Inventory/README.md).

## Building a tree view

The cmdlets return a flat, filterable list at each level. To present a tree, expand each node with one `-Subpath` call using the node's `RelativePath`. Name/tag/sort filters apply at whichever level you query. Snapshots exist only under a VM, so they appear only when you expand that VM.

## Notes and limitations

- **One connection per call.** `-HypervisorConnectionName` or `-HypervisorConnectionUid` is required; a single call searches one hosting connection.
- **Forward-only pagination.** Continuation-token paging moves forward only — it cannot jump to an arbitrary page. Fetch a batch, page within it in your application, then fetch the next batch with the previous call's `ContinuationToken`.
- **Page size.** Default `-MaxRecordCount` is 250 (maximum 1000). `-MaxRecordCount 0` returns `TotalItems` only.
- **Sorting.** Default is alphabetical by name; use `-SortBy`/`-SortOrder` to change it.
- **Snapshots are per-VM.** There is no single flat list of all snapshots across a connection; scope to a VM with `-Subpath`.
- **Hibernation.** `-RequireHibernationSupport` has no effect on XenServer (it is kept for cross-hypervisor script portability).
