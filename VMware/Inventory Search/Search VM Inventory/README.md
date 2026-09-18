# Search VM Inventory

> Part of [VMware Inventory Search](../README.md) — see it for common end-to-end workflows.

## Minimum version requirement

These scripts require **Citrix Virtual Apps and Desktops (CVAD) 2611** or **Citrix DaaS 131** or later.

## Overview

Searches for virtual machines on a VMware (vCenter) hosting connection using server-side name filtering and continuation-token pagination via [`Search-HypVirtualMachineInventory`](https://developer-docs.citrix.com/en-us/citrix-daas-sdk/hostservice/search-hypvirtualmachineinventory). Unlike browsing the `XDHyp:\` provider path, this cmdlet accepts a hosting connection name (or UID) directly and filters on the server, so large vCenter inventories no longer need to be loaded in full. This is useful when selecting power-managed machines during imported catalog creation.

The hosting connection must advertise the `SupportsFilteredVirtualMachineInventory` capability; VMware (vCenter) connections do.

## Output

Each call to the cmdlet returns a single object with three properties:

- `Items` — the matched virtual machines for the current page (`Name`, `ItemType`, `Id`, `RelativePath`, `IsContainer`, `AdditionalExtensionData`).
- `TotalItems` — total count matching the filter across all pages.
- `ContinuationToken` — token to pass on the next call; null/empty when there are no further pages.

## Scope and pagination

- **One connection per call.** `-HypervisorConnectionName` or `-HypervisorConnectionUid` is required; a single call searches one hosting connection.
- **Default view.** With no `-NameContains`, the call returns every VM on the connection that MCS did not provision (up to the page size); add `-IncludeProvisionedResources` to include MCS-provisioned VMs.
- **Empty match.** A search with no matches returns `Items.Count = 0` and `TotalItems = 0`.
- **Paging.** Fetch a batch in one call (default `-MaxRecordCount` is 250, maximum 1000), page within it in your application, then fetch the next batch with the previous call's `ContinuationToken`. Paging is forward-only — there is no random jump to an arbitrary page.

## Examples

The examples below all run against the same fictional VMware connection **`vCenter-Prod`** (UID `7d4e9a21-6c3b-4f8a-b2d1-3e5f9a0c1b2d`) holding five VMs across a datacenter's cluster tree. The **VMware Tools** column reflects whether the guest reports VMware Tools installed — the metadata `-RequireHibernationSupport` filters on:

| Name | Id | RelativePath | VMware Tools |
| --- | --- | --- | --- |
| WIN11-GOLD | 3f2504e0-4f89-41d3-9a0c-0305e82c3301 | /DC-East.datacenter/Images.cluster/WIN11-GOLD.vm | Installed |
| WEB-01 | a8098c1a-f86e-11da-bd1a-00112444be1e | /DC-East.datacenter/Production.cluster/WEB-01.vm | Installed |
| WEB-02 | b1e7f2c4-1a2b-4c3d-9e5f-6a7b8c9d0e1f | /DC-East.datacenter/Production.cluster/WEB-02.vm | Installed |
| SQL-PROD-01 | c2f8a3d5-2b3c-5d4e-af60-7b8c9d0e1f20 | /DC-East.datacenter/Production.cluster/SQL-PROD-01.vm | Installed |
| DEV-SANDBOX | d3a9b4e6-3c4d-6e5f-b071-8c9d0e1f2031 | /DC-East.datacenter/Dev.cluster/DEV-SANDBOX.vm | Not installed |

Before running any example, authenticate the SDK and load the snap-ins:

```powershell
# DaaS (Remote PowerShell SDK) — run once per session:
Get-XdAuthentication
# On-prem CVAD:
Add-PSSnapin citrix*
```

### `-HypervisorConnectionName` — select the connection by name (default parameter set)

```powershell
$result = Search-HypVirtualMachineInventory -HypervisorConnectionName "vCenter-Prod"
$result.Items | Select-Object Name, RelativePath
# Returns all 5 VMs (WIN11-GOLD, WEB-01, WEB-02, SQL-PROD-01, DEV-SANDBOX); TotalItems = 5.
```

### `-HypervisorConnectionUid` — select the connection by UID

Useful when connection names are duplicated or when you already hold the UID from `Get-HypHypervisorConnection`.

```powershell
Search-HypVirtualMachineInventory -HypervisorConnectionUid "7d4e9a21-6c3b-4f8a-b2d1-3e5f9a0c1b2d"
# Same 5 VMs as the ByName example.
```

### `-NameContains` — filter by name substring (case-insensitive)

```powershell
(Search-HypVirtualMachineInventory -HypervisorConnectionName "vCenter-Prod" -NameContains "web").Items | Select-Object Name
# WEB-01
# WEB-02

(Search-HypVirtualMachineInventory -HypervisorConnectionName "vCenter-Prod" -NameContains "PROD").Items | Select-Object Name
# SQL-PROD-01   (matching is case-insensitive)
```

### `-SortBy` and `-SortOrder` — order the results

`-SortBy` accepts `Name` (default) or `Path`; `-SortOrder` accepts `Ascending` (default) or `Descending`. Changing the sort order restarts pagination at page 1.

```powershell
(Search-HypVirtualMachineInventory -HypervisorConnectionName "vCenter-Prod" `
    -SortBy Name -SortOrder Descending).Items | Select-Object Name
# WIN11-GOLD
# WEB-02
# WEB-01
# SQL-PROD-01
# DEV-SANDBOX
```

### `-MaxRecordCount` — page size (batch)

Caps how many items come back in one call. Default is 250; the server hard cap is 1000. When more items match than fit in one page, a `ContinuationToken` is returned.

```powershell
$page = Search-HypVirtualMachineInventory -HypervisorConnectionName "vCenter-Prod" -MaxRecordCount 2
$page.Items | Select-Object Name          # DEV-SANDBOX, SQL-PROD-01 (first 2, sorted by name)
$page.TotalItems                          # 5
$page.ContinuationToken                   # non-empty — more pages remain
```

### `-ContinuationToken` — walk forward through pages

Pagination is forward-only: feed the previous call's token into the next call. Omit it entirely for page 1 — the cmdlet rejects a null or empty `-ContinuationToken`.

```powershell
# Manual, two calls:
$page1 = Search-HypVirtualMachineInventory -HypervisorConnectionName "vCenter-Prod" -MaxRecordCount 2
$page2 = Search-HypVirtualMachineInventory -HypervisorConnectionName "vCenter-Prod" -MaxRecordCount 2 `
            -ContinuationToken $page1.ContinuationToken
$page2.Items | Select-Object Name          # WEB-01, WEB-02

# Loop until every page is consumed. The cmdlet rejects a null/empty -ContinuationToken,
# so build the arguments in a splat and add the token only once page 1 returns one:
$params = @{ HypervisorConnectionName = "vCenter-Prod"; MaxRecordCount = 2 }
do {
    $r = Search-HypVirtualMachineInventory @params
    $r.Items | Select-Object Name, RelativePath
    $params['ContinuationToken'] = $r.ContinuationToken
} while ($r.ContinuationToken)
```

### `-MaxRecordCount 0` — count-only query

Returns `TotalItems` with an empty `Items` set — a cheap way to get the total without fetching rows.

```powershell
(Search-HypVirtualMachineInventory -HypervisorConnectionName "vCenter-Prod" `
    -NameContains "web" -MaxRecordCount 0).TotalItems
# 2
```

### `-Subpath` — restrict the search to an inventory subtree (recursive)

Scopes results to a sub-path of the connection's inventory (maps to the request `Path`). The path uses the same `Name.type` notation as an item's `RelativePath`. On VMware the search is **recursive**: it returns every VM at or below the given datacenter or cluster, not just the immediate children.

```powershell
# Everything under the datacenter — all 5 VMs, across the Images, Production, and Dev clusters:
(Search-HypVirtualMachineInventory -HypervisorConnectionName "vCenter-Prod" `
    -Subpath "/DC-East.datacenter").Items | Select-Object Name

# Just the Production cluster subtree:
(Search-HypVirtualMachineInventory -HypervisorConnectionName "vCenter-Prod" `
    -Subpath "/DC-East.datacenter/Production.cluster").Items | Select-Object Name
# WEB-01
# WEB-02
# SQL-PROD-01
```

### `-RequireHibernationSupport` — only VMs that can hibernate

On VMware this is an **effective filter**. MCS uses "VMware Tools installed" as the proxy for hibernation capability, so the switch returns only VMs whose guest reports VMware Tools installed and drops any VM reporting tools *not installed*.

```powershell
(Search-HypVirtualMachineInventory -HypervisorConnectionName "vCenter-Prod" `
    -RequireHibernationSupport).Items | Select-Object Name
# WIN11-GOLD
# WEB-01
# WEB-02
# SQL-PROD-01
# (DEV-SANDBOX is excluded — VMware Tools not installed.)
```

### `-IncludeProvisionedResources` — include MCS-provisioned VMs

By default, VMs that MCS provisioned (tagged `XdProvisioned=true`) are excluded. Add this switch to include them.

```powershell
Search-HypVirtualMachineInventory -HypervisorConnectionName "vCenter-Prod" -IncludeProvisionedResources
# Returns the 5 imported VMs plus any MCS-provisioned VMs on the connection.
```

### `-AdminAddress` — target a specific Delivery Controller (on-prem CVAD)

```powershell
Search-HypVirtualMachineInventory -HypervisorConnectionName "vCenter-Prod" -AdminAddress "ddc01.contoso.local"
```

### `-Tags` — not supported for VM search on VMware

`-Tags` filtering is honored only by `Search-HypGoldenImageInventory`. VMware supports filtered VM inventory but not tag-based filtering, so passing `-Tags` to the VM search fails rather than returning results; use `Search-HypGoldenImageInventory` when you need tag-based filtering.

```powershell
Search-HypVirtualMachineInventory -HypervisorConnectionName "vCenter-Prod" -Tags "gold"
# Fails: "The hypervisor connection does not support tag-based filtering for this inventory search."
# (FullyQualifiedErrorId: Citrix.XDPowerShell.HostStatus.FilteredInventoryTagsNotSupported)
```

## Combined scenarios

Real admin tasks combine several parameters. These mixes run against the same `vCenter-Prod` inventory.

### First page, alphabetical

Show everything, sort by name, take a page, and keep the token for the next page.

```powershell
$page = Search-HypVirtualMachineInventory -HypervisorConnectionName "vCenter-Prod" `
    -SortBy Name -SortOrder Ascending -MaxRecordCount 3
$page.Items | Select-Object Name, RelativePath
# DEV-SANDBOX   /DC-East.datacenter/Dev.cluster/DEV-SANDBOX.vm
# SQL-PROD-01   /DC-East.datacenter/Production.cluster/SQL-PROD-01.vm
# WEB-01        /DC-East.datacenter/Production.cluster/WEB-01.vm
$page.TotalItems          # 5
$page.ContinuationToken   # non-empty -> 2 more VMs available
```

### Count first, then fetch (splatting shared parameters)

Size the UI with a cheap count-only call, then pull the first page — reusing one parameter set via splatting so the filter/sort stay identical across both calls.

```powershell
$common = @{
    HypervisorConnectionName = "vCenter-Prod"
    NameContains             = "web"
    SortBy                   = "Name"
    SortOrder                = "Ascending"
}
$total = (Search-HypVirtualMachineInventory @common -MaxRecordCount 0).TotalItems   # 2
$first = Search-HypVirtualMachineInventory @common -MaxRecordCount 50
Write-Host "Showing $($first.Items.Count) of $total matching VMs"                   # Showing 2 of 2 matching VMs
```

### Filter + sort + page through every match

Page one VM at a time through the "web" VMs in descending (Z-to-A) relative-path order — combining `-NameContains`, `-SortBy Path`, `-SortOrder Descending`, `-MaxRecordCount`, and `-ContinuationToken`.

```powershell
$params = @{
    HypervisorConnectionName = "vCenter-Prod"
    NameContains             = "web"
    SortBy                   = "Path"
    SortOrder                = "Descending"
    MaxRecordCount           = 1
}
do {
    $r = Search-HypVirtualMachineInventory @params
    $r.Items | Select-Object Name, RelativePath
    $params['ContinuationToken'] = $r.ContinuationToken   # on the last page this is empty and the loop exits before it is reused
} while ($r.ContinuationToken)
# WEB-02   /DC-East.datacenter/Production.cluster/WEB-02.vm
# WEB-01   /DC-East.datacenter/Production.cluster/WEB-01.vm
```

### Scoped, hibernation-capable search by connection UID

Select the connection by UID, restrict to a datacenter subtree (recursive), keep only hibernation-capable VMs, and filter by name — a targeted lookup that ignores the rest of the inventory.

```powershell
Search-HypVirtualMachineInventory `
    -HypervisorConnectionUid "7d4e9a21-6c3b-4f8a-b2d1-3e5f9a0c1b2d" `
    -Subpath "/DC-East.datacenter" `
    -NameContains "web" `
    -RequireHibernationSupport `
    -MaxRecordCount 50
# Returns 'web' VMs with VMware Tools installed found anywhere under /DC-East.datacenter.
```

### On-prem targeted lookup

Same filter/sort against a specific Delivery Controller (on-prem CVAD).

```powershell
Search-HypVirtualMachineInventory -HypervisorConnectionName "vCenter-Prod" `
    -NameContains "sql" -SortBy Name -MaxRecordCount 50 `
    -AdminAddress "ddc01.contoso.local"
# SQL-PROD-01
```

## Using the sample script

`Search-VMInventory.ps1` wraps the cmdlet, handles the forward-paging loop, and exposes the VMware-relevant parameters. See its comment-based help (`Get-Help .\Search-VMInventory.ps1 -Full`) for the full example set.

```powershell
# All VMs, 50 per page:
.\Search-VMInventory.ps1 -ConnectionName "vCenter-Prod"

# Name-filtered, sorted, small pages:
.\Search-VMInventory.ps1 -ConnectionName "vCenter-Prod" -NameContains "web" -SortOrder Descending -PageSize 2

# Only hibernation-capable (VMware Tools installed) VMs:
.\Search-VMInventory.ps1 -ConnectionName "vCenter-Prod" -RequireHibernationSupport

# Count only:
.\Search-VMInventory.ps1 -ConnectionName "vCenter-Prod" -NameContains "win11" -CountOnly
```
