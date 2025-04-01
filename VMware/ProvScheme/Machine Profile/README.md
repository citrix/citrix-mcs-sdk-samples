# Using Machine Profile Features of VMware for Machine Catalog Creation

This page describes the use of VMware's Machine Profile feature while creating a ProvScheme in Citrix Virtual Apps and Desktops (CVAD). The script `Create-ProvScheme-FullClone.ps1` shows an example usage of `New-ProvScheme` with the Machine Profile feature.

## 1. Understanding the Machine Profile Features

- **Machine Profile:**
    - **Desription:** Machine Profile provides a way to specify a template that will be used for provisioning machines in a provisioning scheme.
    All hardware properties (e.g., CPU Count, Memory, etc) are captured from the machine profile template. 
	- MCS creates a difference disk for each VM. Write operations are directed to this difference disk. However, the base disk is shared among all VMs, meaning that all read operations are conducted on this common base disk. 

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

## 2. How to use Machine Profile Feature

To configure Machine through PowerShell, use the `MachineProfile` parameter available with the New-ProvScheme operation. The MachineProfile parameter is a string containing a Citrix inventory item path. Currently, only one inventory type is supported for the MachineProfile source:    
**Template**: The MachineProfile points to a template that exists in the host. For example:
```powershell
$machineProfile = "XDHyp:\HostingUnits\demo-hostingunit\demo-machineprofile-template.template"
```
**MachineProfile**: Defines the inventory path to the source VM used by the provisioning scheme as a template. This profile identifies the properties for the VMs created from the scheme.

### Create Provisioning scheme
When using New-ProvScheme, specify the `MachineProfile` parameter:

```powershell
New-ProvScheme `
    -ProvisioningSchemeName "MyMachineCatalog" `
    # Additional Parameters... `
    -MachineProfile "XDHyp:\HostingUnits\Myresource\MyVM-Template.template" `
```

### Update Provisioning scheme with machine profile
You can also change the MachineProfile configuration on an existing catalog using the Set-ProvScheme command. 
```powershell
Set-ProvScheme -ProvisioningSchemeName $provisioningSchemeName -MachineProfile $machineProfile
```
**Note**: The updated machine profile will be applicable to new machines post operation, not to the existing machines. 

## 3. Example Full Scripts Utilizing Machine Profile.

1. [Creation of a Machine Catalog with Machine Profile](Create-ProvScheme-MachineProfile.ps1)
2. [Update a Machine Catalog with Machine Profile](Set-ProvScheme-MachineProfile.ps1)



## 4. Reference Documents

For comprehensive information and further reading, the following resources are recommended. These include CVAD SDK documentation and other relevant references (as applicable):

1. [CVAD SDK - About Machine Profile
](https://developer-docs.citrix.com/en-us/citrix-daas-sdk/MachineCreation/about_Prov_MachineProfile.html)

