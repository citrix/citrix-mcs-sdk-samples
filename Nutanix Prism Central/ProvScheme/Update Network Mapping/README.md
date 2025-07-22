# Update Network Mapping for Provisioning Scheme

This page explains the use of the Update-NetworkMapping.ps1 script.

This script updates the Network Mapping for an existing Provisioning Scheme.

## Using the script

### Parameters

- Required parameters:
    - `ProvisioningSchemeName`: Name of the provisioning scheme to remove
    - `NetworkMapping`: Updated NetworkMapping

### Example
The script can be executed like the example below:

```powershell
.\Update-NetworkMapping.ps1 -ProvisioningSchemeName "myProvScheme" -NetworkMapping @{"0"="XDHyp:\HostingUnits\myHostingUnit\Clusters.folder\cluster01.cluster\OverLay.network"}
```

Update to use 2 Networks (network types must match, you can not use combination of VLAN and OVERLAY networks)
```powershell
$nw = @{
"0"="XDHyp:\HostingUnits\myHostingUnit\Clusters.folder\cluster01.cluster\VlanA.network"
"1"="XDHyp:\HostingUnits\myHostingUnit\Clusters.folder\cluster01.cluster\VlanB.network"
}
.\Update-NetworkMapping.ps1 -ProvisioningSchemeName "myProvScheme" -NetworkMapping $nw
```