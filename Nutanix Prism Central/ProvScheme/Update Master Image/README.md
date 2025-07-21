# Update Master Image

Update-MasterImage.ps1 updates the master image of a provisioning scheme.

### Parameters

- Required parameters:
    - `ProvisioningSchemeName`: Name of the provisioning scheme to get
    - `MasterImage`:            Literal path to the new master image.
    - `RebootDuration`:         Maximum time of the reboot cycle in minutes.
    - `WarningRepeatInterval`:  Intervals of minutes with which the warning message is shown.
- Optional parameters
    - `WarningDuration`:        Time in minutes before a reboot when a warning message is shown to users.
    - `WarningMessage`:         Warning message to display before VMs reboot.

### Examples

1. Update a master image immediately without a warning message:

```powershell
.\Update-MasterImage.ps1 `
    -ProvisioningSchemeName "myProvScheme" `
    -MasterImage "XDHyp:\HostingUnits\myHostingUnit\Templates.folder\CitrixVda.template\win2022-vda-2411.templateversion" `
    -RebootDuration 0 `
    -WarningRepeatInterval 0 `
```

2. Update a master image with a 60 minute warning

```powershell
.\Update-MasterImage.ps1 `
    -ProvisioningSchemeName "MyCatalog" `
    -MasterImage "XDHyp:\HostingUnits\myHostingUnit\Templates.folder\CitrixVda.template\win2022-vda-2411.templateversion" `
    -RebootDuration 240 `
    -WarningDuration 60 `
    -WarningRepeatInterval 0 `
    -WarningMessage "Warning: system will reboot"
```