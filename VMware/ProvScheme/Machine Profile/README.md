# Using Machine Profile Features of VMware for Machine Catalog Creation

This page describes the use of VMware's Machine Profile feature while creating a ProvScheme in Citrix Virtual Apps and Desktops (CVAD). The script `Create-ProvScheme-FullClone.ps1` shows an example usage of `New-ProvScheme` with the Machine Profile feature.



## 1. Understanding the Machine Profile Features


- **Machine Profile:**
    - **Desription:** Machine Profile provides a way to specify a template that will be used for provisioning machines in a provisioning scheme.
    All hardware properties (e.g., CPU Count, Memory, etc) are captured from the machine profile template. 

- **Vmware Specific Information:**
    - **Desription:** When using VMware, the following resource can be used as machine profile input.
      - **VM Template:** Can be created in two ways - Converting an existing VM into a VM Template, or cloning an existing VM to a VM Template. Here are some relevant examples:
    - All hardware properties are captured from the machine profile template. Here are some relevant examples:
      - Folder ID
      - vTPM Data
      - Memory
      - CPU Count
      - Storage Policy
      - Guest OS
      - NIC Count
      - VM Tags
    - VMWare has the following properties that can be provided explicitly or through Machine Profile:
      - VMCpuCount
      - VMMemoryMB
      - NetworkMapping
      - CustomProperties
      - FolderId ([How to find the folder ID](https://docs.citrix.com/en-us/citrix-virtual-apps-desktops/install-configure/machine-catalogs-manage/manage-machine-catalog-vmware.html#find-the-folder-id-in-vsphere))
  - Note the following information around specific properties:
    - vTPM: If the master image VM is vTPM enabled, the VM template must come from the same master image VM.
    - CPU and Cores per Socket: For VMware, CPU Count must be an integral multiple of Cores per Socket. For example, 6 CPU count can have 1,2,3, or 6 Cores per Socket. 4 CPU count can have 1,2, or 4 Cores per Socket.
      - For a new Catalog, both CPU Count and Cores per Socket value are picked up from the machine profile. Unless CPU count is also provided as a parameter, in which case that value is used.
      - For an existing catalog, CPU Count by itself can be updated using the “VmCpuCount” parameter of Set-ProvScheme, but this does not change the value of Cores per Socket. To update both values, provide a new VM Template with the required changes as the Machine Profile parameter in Set-ProvScheme.
    - Storage Policy: Only captured in a vSAN Datastore.
    - NICs: Only the NIC count from the Machine Profile is used. Network mappings from the Machine Profile are not used.
      - NIC count cannot be 0 or higher than what the hosting unit can support.
      - If NIC count is 1, and no mapping is provided, default network/subnet from the Hosting Unit is used.
      - If NIC count is greater than 1, network mapping needs to be provided for each NIC.
      - Mapping has to be 1:1, that is, only one NIC can be mapped to one subnet on the Hosting Unit.

When setting up a static desktop on a dedicated virtual machine with local disk changes saved, Machine Creation Service (MCS) offers two disk types: partially cloned disk (so-called Fast Clone) and fully cloned disk (so-called Machine Profile). 

- **Machine Profile:**
    - **Desription:** MCS creates a difference disk for each VM. Write operations are directed to this difference disk. However, the base disk is shared among all VMs, meaning that all read operations are conducted on this common base disk. The figure below illustrates the architecture. 

## 2. Understanding the Concise Script using Machine Profile Feature

To enable Machine Profile, set the **MachineProfile** parameter in the **New-ProvScheme** cmdlet as shown below:

```powershell
New-ProvScheme `
    -ProvisioningSchemeName "MyMachineCatalog" `
    # Additional Parameters... `
    -MachineProfile "XDHyp:\HostingUnits\Myresource\MyVM-Template.template" `
```

**MachineProfile** Defines the inventory path to the source VM used by the provisioning scheme as a template. This profile identifies the properties for the VMs created from the scheme.


## 3. Example Full Scripts Utilizing Machine Profile.

1. [Creation of a Machine Catalog with Machine Profile](../../SampleAdminScenarios/Add%20Machine%20Catalog/Add-MachineCatalog.ps1)



## 4. Reference Documents

For comprehensive information and further reading, the following resources are recommended. These include CVAD SDK documentation and other relevant references (as applicable):

1. [CVAD SDK - About Machine Profile
](https://developer-docs.citrix.com/en-us/citrix-daas-sdk/MachineCreation/about_Prov_MachineProfile.html)

