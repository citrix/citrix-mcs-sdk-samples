# Getting Started

This page offers base scripts for vm level operations supported by Provisioning Maintenance Cycle

## 1. Provisioning Maintenance Cycle

The Maintenance Cycle feature allows scheduling and automating maintenance operations on MCS‑provisioned VMs. Instead of performing updates manually, you can define when tasks such as OS disk resets and hardware configuration changes should run, and then return later to confirm their completion.
Maintenance Cycles can be configured for a specific set of VMs or for an entire machine catalog, giving flexibility in how broadly changes are applied. Each scheduled operation runs at its configured time, and multiple operations can be queued for the same VM, with the exception that only a single hardware update can be scheduled per VM at any given time.
In addition to scheduling operations, Maintenance Cycles provide several options to improve communication and control. You can add a description to document the purpose of the Maintenance Cycle, making it easier for administrators and operators to understand what is planned. 
You can also configure a custom message that is displayed to users who are logged on when the operation is triggered, and define a grace period (buffer minutes) that gives those users time to save their work before the operation is forcibly executed. This approach delivers several benefits. It improves user experience and continuity by enabling graceful session handling: users are notified in advance and given time to save their work before the VM is restarted or powered down, avoiding abrupt disconnections.
It also supports planned downtime by allowing maintenance tasks to be scheduled during off‑peak hours (for example, 2:00 AM), so administrators do not need to perform these actions manually at inconvenient times. Finally, it enables cost‑efficient hardware updates. Maintenance Cycles automatically determine whether a VM actually requires a reboot to apply hardware changes, and by avoiding unnecessary reboots across large environments, they help reduce operational costs and maintenance overhead.

## 2. Operations Supported
Below is an outline of CVAD operations supported by Provisioning Maintenance Cycle. 
Both the base scripts and the specialized scripts can be found in the corresponding folders.

* [HardwareVmUpdate](./HardwareVmUpdate/)
