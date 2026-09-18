# VMware Inventory Search

Server-side, paginated, name-filtered inventory search for VMware (vCenter) hosting connections, so you can locate VMs without loading the full inventory.

| Cmdlet | Use | Folder |
| --- | --- | --- |
| [`Search-HypVirtualMachineInventory`](./Search%20VM%20Inventory/README.md) | Find VMs (e.g. for power-managed catalogs) | `Search VM Inventory/` |

This cmdlet is additive — it doesn't change `Get-HypInventoryItem` or the `XDHyp:\` provider.

## Core concepts

- **One resource type per call.** This cmdlet returns virtual machines; there is no single mixed-type search.
- **Filters and shape.** `-NameContains`, `-SortBy`/`-SortOrder`, forward-only `-ContinuationToken` paging, and `-MaxRecordCount 0` for a count-only query. Every call returns `{ Items, TotalItems, ContinuationToken }`.
- **Recursive subtree scoping.** `-Subpath` scopes the search to a datacenter or cluster and its descendants — the VM collection is recursive from that path down.
- **Hibernation filtering.** `-RequireHibernationSupport` returns only VMs that report **VMware Tools installed** (the metadata MCS uses as the hibernation-capable proxy).

## Common workflow — find a VM by name

A flat, name-filtered VM list (for example, when importing VMs for power-managed catalogs). One cmdlet, root call.

```powershell
$page = Search-HypVirtualMachineInventory -HypervisorConnectionName "vCenter-Prod" `
    -NameContains "web" -SortBy Name -MaxRecordCount 50
$page.Items | Select-Object Name, RelativePath
```

See [Search VM Inventory](./Search%20VM%20Inventory/README.md) for the full parameter reference, examples, and the `Search-VMInventory.ps1` sample script.

## Notes and limitations

- **One connection per call.** `-HypervisorConnectionName` or `-HypervisorConnectionUid` is required; a single call searches one hosting connection.
- **Forward-only pagination.** Continuation-token paging moves forward only — it cannot jump to an arbitrary page. Fetch a batch, page within it in your application, then fetch the next batch with the previous call's `ContinuationToken`.
- **Page size.** Default `-MaxRecordCount` is 250 (maximum 1000). `-MaxRecordCount 0` returns `TotalItems` only.
- **Sorting.** Default is alphabetical by name; use `-SortBy`/`-SortOrder` to change it.
- **Recursive `-Subpath`.** Scoping to a datacenter or cluster returns every matching VM beneath it, not just the immediate children.
- **`-Tags` is not supported for VM search.** Tag filtering is honored only by `Search-HypGoldenImageInventory`; VMware supports filtered VM inventory but not tag-based filtering, so passing `-Tags` to the VM search fails with `FilteredInventoryTagsNotSupported`.
