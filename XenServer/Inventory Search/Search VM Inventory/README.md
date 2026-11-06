# Search VM Inventory

> Part of [XenServer Inventory Search](../README.md) — see it for common end-to-end workflows.

## Minimum version requirement

- **On-premises (CVAD):** Citrix Virtual Apps and Desktops **2611** or later.
- **Citrix DaaS (Cloud):** first shipped in Citrix DaaS release **131**. Citrix DaaS is updated
  continuously by Citrix, so Cloud tenants receive the feature automatically — there is no release
  number to install or check. Just keep your
  [Remote PowerShell SDK](https://docs.citrix.com/en-us/citrix-daas/sdk-api.html) up to date.

## Overview

Searches for virtual machines on a XenServer hosting connection using server-side name filtering and continuation-token pagination via [`Search-HypVirtualMachineInventory`](https://developer-docs.citrix.com/en-us/citrix-daas-sdk/hostservice/search-hypvirtualmachineinventory). Unlike browsing the `XDHyp:\` provider path, this cmdlet accepts a hosting connection name (or UID) directly and filters on the server, so large inventories no longer need to be loaded in full. This is useful when selecting power-managed machines during imported catalog creation.

The hosting connection must advertise the `SupportsFilteredVirtualMachineInventory` capability; XenServer connections do.

## Output

Each call to the cmdlet returns a single object with three properties:

- `Items` — the matched virtual machines for the current page (`Name`, `ItemType`, `Id`, `RelativePath`, `IsContainer`, `AdditionalExtensionData`).
- `TotalItems` — total count matching the filter across all pages.
- `ContinuationToken` — token to pass on the next call; null/empty when there are no further pages.

## Scope and pagination

- **One connection per call.** `-HypervisorConnectionName` or `-HypervisorConnectionUid` is required; a single call searches one hosting connection.
- **Default view.** With no `-NameContains`, the call returns every VM on the connection (up to the page size).
- **Empty match.** A search with no matches returns `Items.Count = 0` and `TotalItems = 0`.
- **Paging.** Fetch a batch in one call (default `-MaxRecordCount` is 250, maximum 1000), page within it in your application, then fetch the next batch with the previous call's `ContinuationToken`. Paging is forward-only — there is no random jump to an arbitrary page.

## Examples

The examples below all run against the same fictional XenServer connection **`XS-Pool-01`** (UID `9b7c1f3e-2a4d-4c6b-8e1f-0d5a6b7c8d9e`) holding five VMs:

| Name | Id | RelativePath | PowerState |
| --- | --- | --- | --- |
| WIN11-GOLD | 3f2504e0-4f89-41d3-9a0c-0305e82c3301 | /WIN11-GOLD.vm | Off |
| WEB-01 | a8098c1a-f86e-11da-bd1a-00112444be1e | /WEB-01.vm | On |
| WEB-02 | b1e7f2c4-1a2b-4c3d-9e5f-6a7b8c9d0e1f | /WEB-02.vm | On |
| SQL-PROD-01 | c2f8a3d5-2b3c-5d4e-af60-7b8c9d0e1f20 | /SQL-PROD-01.vm | On |
| DEV-SANDBOX | d3a9b4e6-3c4d-6e5f-b071-8c9d0e1f2031 | /DEV-SANDBOX.vm | Off |

Before running any example, authenticate the SDK and load the snap-ins:

```powershell
# DaaS (Remote PowerShell SDK) — run once per session:
Get-XdAuthentication
# On-prem CVAD:
Add-PSSnapin citrix*
```

### `-HypervisorConnectionName` — select the connection by name (default parameter set)

```powershell
$result = Search-HypVirtualMachineInventory -HypervisorConnectionName "XS-Pool-01"
$result.Items | Select-Object Name, RelativePath
# Returns all 5 VMs (WIN11-GOLD, WEB-01, WEB-02, SQL-PROD-01, DEV-SANDBOX); TotalItems = 5.
```

### `-HypervisorConnectionUid` — select the connection by UID

Useful when connection names are duplicated or when you already hold the UID from `Get-HypHypervisorConnection`.

```powershell
Search-HypVirtualMachineInventory -HypervisorConnectionUid "9b7c1f3e-2a4d-4c6b-8e1f-0d5a6b7c8d9e"
# Same 5 VMs as the ByName example.
```

### `-NameContains` — filter by name substring (case-insensitive)

```powershell
(Search-HypVirtualMachineInventory -HypervisorConnectionName "XS-Pool-01" -NameContains "web").Items | Select-Object Name
# WEB-01
# WEB-02

(Search-HypVirtualMachineInventory -HypervisorConnectionName "XS-Pool-01" -NameContains "PROD").Items | Select-Object Name
# SQL-PROD-01   (matching is case-insensitive)
```

### `-SortBy` and `-SortOrder` — order the results

`-SortBy` accepts `Name` (default) or `Path`; `-SortOrder` accepts `Ascending` (default) or `Descending`. Changing the sort order restarts pagination at page 1.

```powershell
(Search-HypVirtualMachineInventory -HypervisorConnectionName "XS-Pool-01" `
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
$page = Search-HypVirtualMachineInventory -HypervisorConnectionName "XS-Pool-01" -MaxRecordCount 2
$page.Items | Select-Object Name          # WIN11-GOLD, DEV-SANDBOX (first 2, sorted by name)
$page.TotalItems                          # 5
$page.ContinuationToken                   # non-empty — more pages remain
```

### `-ContinuationToken` — walk forward through pages

Pagination is forward-only: feed the previous call's token into the next call. Omit it (or pass `$null`) for page 1.

```powershell
# Manual, two calls:
$page1 = Search-HypVirtualMachineInventory -HypervisorConnectionName "XS-Pool-01" -MaxRecordCount 2
$page2 = Search-HypVirtualMachineInventory -HypervisorConnectionName "XS-Pool-01" -MaxRecordCount 2 `
            -ContinuationToken $page1.ContinuationToken
$page2.Items | Select-Object Name          # SQL-PROD-01, WEB-01

# Loop until every page is consumed:
$token = $null
do {
    $r = Search-HypVirtualMachineInventory -HypervisorConnectionName "XS-Pool-01" `
            -MaxRecordCount 2 -ContinuationToken $token
    $r.Items | Select-Object Name, RelativePath
    $token = $r.ContinuationToken
} while ($token)
```

### `-MaxRecordCount 0` — count-only query

Returns `TotalItems` with an empty `Items` set — a cheap way to get the total without fetching rows.

```powershell
(Search-HypVirtualMachineInventory -HypervisorConnectionName "XS-Pool-01" `
    -NameContains "web" -MaxRecordCount 0).TotalItems
# 2
```

### `-Subpath` — restrict the search to an inventory subtree

Scopes results to a sub-path of the connection's inventory (maps to the request `Path`). The path uses the same `Name.type` notation as an item's `RelativePath`.

```powershell
Search-HypVirtualMachineInventory -HypervisorConnectionName "XS-Pool-01" -Subpath "/Production.folder"
```

> On XenServer, snapshots are nested under their parent VM, so `-Subpath` is mainly how snapshots are surfaced for the golden-image and machine-profile cmdlets. For VM search, `-Subpath` scopes the results to the given inventory subtree.

### `-IncludeProvisionedResources` — include MCS-provisioned VMs

By default, VMs that MCS provisioned (tagged `XdProvisioned=true`) are excluded. Add this switch to include them.

```powershell
Search-HypVirtualMachineInventory -HypervisorConnectionName "XS-Pool-01" -IncludeProvisionedResources
# Returns the 5 imported VMs plus any MCS-provisioned VMs on the connection.
```

### `-AdminAddress` — target a specific Delivery Controller (on-prem CVAD)

```powershell
Search-HypVirtualMachineInventory -HypervisorConnectionName "XS-Pool-01" -AdminAddress "ddc01.contoso.local"
```

### Parameters accepted but ignored on XenServer

Both parameters below exist for cross-hypervisor script portability but do **not** change results on XenServer:

```powershell
# -RequireHibernationSupport: XenServer exposes no hibernation metadata, so this never filters.
Search-HypVirtualMachineInventory -HypervisorConnectionName "XS-Pool-01" -RequireHibernationSupport

# -Tags: honored only by Search-HypGoldenImageInventory; ignored by the VM cmdlet.
Search-HypVirtualMachineInventory -HypervisorConnectionName "XS-Pool-01" -Tags "gold"
```

## Combined scenarios

Real admin tasks combine several parameters. These mixes run against the same `XS-Pool-01` inventory.

### First page, alphabetical

Show everything, sort by name, take a page, and keep the token for the next page.

```powershell
$page = Search-HypVirtualMachineInventory -HypervisorConnectionName "XS-Pool-01" `
    -SortBy Name -SortOrder Ascending -MaxRecordCount 3
$page.Items | Select-Object Name, RelativePath
# DEV-SANDBOX   /DEV-SANDBOX.vm
# SQL-PROD-01   /SQL-PROD-01.vm
# WEB-01        /WEB-01.vm
$page.TotalItems          # 5
$page.ContinuationToken   # non-empty -> 2 more VMs available
```

### Count first, then fetch (splatting shared parameters)

Size the UI with a cheap count-only call, then pull the first page — reusing one parameter set via splatting so the filter/sort stay identical across both calls.

```powershell
$common = @{
    HypervisorConnectionName = "XS-Pool-01"
    NameContains             = "web"
    SortBy                   = "Name"
    SortOrder                = "Ascending"
}
$total = (Search-HypVirtualMachineInventory @common -MaxRecordCount 0).TotalItems   # 2
$first = Search-HypVirtualMachineInventory @common -MaxRecordCount 50
Write-Host "Showing $($first.Items.Count) of $total matching VMs"                   # Showing 2 of 2 matching VMs
```

### Filter + sort + page through every match

Page one VM at a time through the "web" VMs, newest path first — combining `-NameContains`, `-SortBy Path`, `-SortOrder Descending`, `-MaxRecordCount`, and `-ContinuationToken`.

```powershell
$token = $null
do {
    $r = Search-HypVirtualMachineInventory -HypervisorConnectionName "XS-Pool-01" `
        -NameContains "web" -SortBy Path -SortOrder Descending `
        -MaxRecordCount 1 -ContinuationToken $token
    $r.Items | Select-Object Name, RelativePath
    $token = $r.ContinuationToken
} while ($token)
# WEB-02   /WEB-02.vm
# WEB-01   /WEB-01.vm
```

### Scoped, provisioned-inclusive search by connection UID

Select the connection by UID, restrict to a subtree, include MCS-provisioned VMs, and filter by name — a targeted lookup that ignores the rest of the inventory.

```powershell
Search-HypVirtualMachineInventory `
    -HypervisorConnectionUid "9b7c1f3e-2a4d-4c6b-8e1f-0d5a6b7c8d9e" `
    -Subpath "/Production.folder" `
    -NameContains "app" `
    -IncludeProvisionedResources `
    -MaxRecordCount 50
# Returns 'app' VMs (imported + MCS-provisioned) found only under /Production.folder.
```

### On-prem targeted lookup

Same filter/sort against a specific Delivery Controller (on-prem CVAD).

```powershell
Search-HypVirtualMachineInventory -HypervisorConnectionName "XS-Pool-01" `
    -NameContains "sql" -SortBy Name -MaxRecordCount 50 `
    -AdminAddress "ddc01.contoso.local"
# SQL-PROD-01
```

## Using the sample script

`Search-VMInventory.ps1` wraps the cmdlet, handles the forward-paging loop, and exposes the XenServer-relevant parameters. See its comment-based help (`Get-Help .\Search-VMInventory.ps1 -Full`) for the full example set.

```powershell
# All VMs, 50 per page:
.\Search-VMInventory.ps1 -ConnectionName "XS-Pool-01"

# Name-filtered, sorted, small pages:
.\Search-VMInventory.ps1 -ConnectionName "XS-Pool-01" -NameContains "web" -SortOrder Descending -PageSize 2

# Count only:
.\Search-VMInventory.ps1 -ConnectionName "XS-Pool-01" -NameContains "win11" -CountOnly
```
