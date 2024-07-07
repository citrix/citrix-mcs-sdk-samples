# Update Master Image
## Overview
After an MCS catalog is created, you can update the master image using `Publish-ProvMasterVMImage` powershell cmdlet to propagate hard disk changes to the catalog machines. If the provisioning scheme is a `CleanOnBoot` type (non-persistent), hard disks are updated to the new image on their next power-on. Regardless of the `CleanOnBoot` type, all new virtual machines created after this command will use the new hard disk image. The previous hard disk image path is stored into the history. You can view the image update history with the Powershell cmdlet `Get-ProvSchemeMasterVMImageHistory`. The data stored in the history allows you to rollback to the previous image if required.
To know more about this cmdlet, please refer to the [Citrix Documentation](https://developer-docs.citrix.com/en-us/citrix-virtual-apps-desktops-sdk/2311/MachineCreation/Publish-ProvMasterVMImage.html).

## How to update the master image
Master image of a provisioning scheme can be set directly through the `-MasterImageVM` parameter of `Publish-ProvMasterVMImage` cmdlet. `-MasterImageVM` should be a Citrix inventory path for a VM or a snapshot. Here is an example to change the master image directly:
```powershell
Publish-ProvMasterVMImage -ProvisioningSchemeName $provisioningSchemeName -MasterImageVM $masterImageSnapshot
```

**Note**: After the image update is completed, you need to restart the existing catalog machines for the change to take effect. You can use Start-BrokerRebootCycle to start a reboot cycle which ensures that all machines in the catalog are running the most recent image for the catalog.

## Troubleshooting Publish-ProvMasterVMImage -
* If the master image vm or snapshot is invalid, the task will fail with TerminatingError: "Master image was not found" and the TaskState: "VirtualMachineSnapshotNotFound".