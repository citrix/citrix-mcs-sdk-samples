# Update Master Image
## Overview
After a MCS catalog is created, you can update the master image using `Publish-ProvMasterVMImage` Powershell cmdlet to propagate hard disk changes to the catalog machines associated with the provisioning scheme. If the provisioning scheme is a `CleanOnBoot` type (non-persistent), then the next time that virtual machines are started, their hard disks are updated to this new image. Regardless of the `CleanOnBoot` type, all new virtual machines created after this command will use this new hard disk image. The previous hard disk image path is stored into the history. You can view the image update history with the Powershell cmdlet `Get-ProvSchemeMasterVMImageHistory`. The data stored in the history allows you to do a rollback to revert to the previous hard disk image if required.

## How to update the master image
Master image of a provisioning scheme can be set directly through `-MasterImageVM` parameter when running powershell command `Publish-ProvMasterVMImage`. Here is an example to change the master image directly:
```powershell
Publish-ProvMasterVMImage -ProvisioningSchemeName demo-catalog -MasterImageVM XDHyp:\HostingUnits\azure\image.folder\demorg.resourcegroup\masterimage1.snapshot
```
**Note**: After image update is completed, you need to restart the existing catalog machines so their hard disks will be updated. You can use Start-BrokerRebootCycle to create and start a reboot cycle which ensure that all machines in the catalog are running the most recent image for the catalog.