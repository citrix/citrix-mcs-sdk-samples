# Getting Started

This page offers base scripts for Provisioning Maintenance Cycle

## 1. Provisioning Maintenance Cycle
The Maintenance Cycle feature is to provide a capability to the admin or a user to schedule a maintenance window for a catalog/provisioningScheme/listOfMachines to do a certain operation.
Admins/Users can just schedule this operation and move away and then come back later to find that the operation is complete. 
While scheduling the operation, its important for the user to give the Scheduled Start Time in UTC, Total number of minutes allocated for the maintenance window.
Its also allowed for the user to schedule multiple operations in a single maintenance window. The user is also allowed to have overlapping maintenance windows for the same machine.
It is designed for the maintenance cycle to first complete the current list of operations for a particular machine before releasing it. If during an operation, another maintenance cycle starts on the same machine, the operations in that cycle would be queued up behind the current list of operations.
We will not have another thread spun up to have two different operations happening at the same time on the same virtual machine. In case the new operation has an earlier end time than the current ones, we will have the new operation picked up in order to honour the earlier end time.

## 2. Operations Supported
Below is an outline of CVAD operations supported by Provisioning Maintenance Cycle. 
Both the base scripts and the specialized scripts can be found in the corresponding folders.

* [HardwareSchemeUpdate](./HardwareSchemeUpdate/)
* [HardwareVmUpdate](./HardwareVmUpdate/)
* [OSDiskReset](./OSDiskReset/)
