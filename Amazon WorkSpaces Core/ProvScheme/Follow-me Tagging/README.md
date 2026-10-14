# Follow-me Tagging
## Overview
Follow-me tagging enables tracking of individual end-user VM usage by applying hypervisor-level tags. These tags, labeled with the specific user and/or organization (using `citrix-user-upn` as the key and the User Principal Name (UPN) as the value), are added when a user is assigned to a VM and removed when the user is unassigned.

This feature offers several advantages:

- IT chargeback: Facilitates filtering resource usage (Azure: NICs, OS, ID, WBC, Data disks, and VMs) (AWS: EC2 instance, EBS volumes (OS, ID, WBC, and Data disks), Network Interfaces) by tags, allowing for accurate chargeback to individual users or business units.
- Efficient user management: Automates the removal of tags from resources when end-users are unassigned due to employment changes like termination or reorganization.
- Enhanced security monitoring: Helps identify VMs assigned to specific end-users for targeted security scans.

Currently, follow-me tagging is applicable to:

- AWS and Azure environments
- Statically assigned machines running single-session OS
- Persistent and non-Persistent catalogs
- All supported machine identity joined catalogs
- Only MCS provisioned VMs
- Managed disks only

## How to use Follow-me Tagging
You can enable the feature by setting the `HypervisorVMTagging` parameter while creating or updating a Broker Catalog. It can be set to true or false depending on whether the tagging needs to be enabled or disabled respectively.

[Create-ProvScheme-With-HypervisorVmTagging.ps1](Create-ProvScheme-With-HypervisorVmTagging.ps1) gives a simple example on how to enable follow-me tagging on your catalog.

For example:
```powershell
New-BrokerCatalog -Name $provisioningSchemeName `
    -ProvisioningSchemeId $createdProvScheme.ProvisioningSchemeUid `
    ...
	-HypervisorVMTagging $True `
```

[Update-BrokerCatalog-With-HypervisorVmTagging.ps1](Update-BrokerCatalog-With-HypervisorVmTagging.ps1) has an example script on how to enable follow-me tagging on an existing catalog. The parameter can also be set to false for disabling the tagging.

For example:
```powershell
$hypervisorVMTagging = $true
Set-BrokerCatalog -Name $provisioningSchemeName -Description $description -HypervisorVMTagging:$hypervisorVMTagging
```

Documentation: https://docs.citrix.com/en-us/citrix-daas/install-configure/machine-catalogs-create#follow-me-tagging