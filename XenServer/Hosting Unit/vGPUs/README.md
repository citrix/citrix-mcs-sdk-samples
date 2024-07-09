# Using the Virtual Graphics Processing Feature of XenServer for Hosting Unit Creation

This page details the use of XenServer's Virtual Graphics Processing (vGPU) feature for creating a Hosting Unit in Citrix Virtual Apps and Desktops (CVAD). The script `Add-HostingUnit-vGPUs.ps1` shows an example usage of `New-Item` with the IntelliCache feature.



## 1. Understanding the vGPUs Feature of XenServer

The vGPUs is a technology that allows multiple virtual machines (VMs) to share a physical GPU, providing enhanced graphics and computing performance. XenServer (formerly Citrix Hypervisor)/ESX hypervisor supports NVIDIA vGPUs solutions that consist of NVIDIA data center GPUs and vGPUs software licensing components. The underlying data center GPUs in the XenServer host is unknown to Citrix Provisioning. Citrix Provisioning only uses the vGPUs software settings in the template and propagates it to the VMs provisioned by the Citrix Virtual Apps and Desktops Setup Wizard.

The figure below illustrates a layer architecture related to the vGPU:

<div align="center">
    <img src="https://citrixready.citrix.com/content/dam/ready/partners/nv/nvidia/nvidia-grid/nvidia-virtual-gpu-pimage-images.png" width="500" height="300"> 
</div>

Below is a summary of the trade-offs when using vGPU:

- **Advantages of Using vGPU:** 
    - Improved Graphics and GPU Computing Performance: Allows VMs to handle graphics-intensive applications efficiently.
    - Scalability: Facilitates easy scaling of graphics resources.
    - Resource Sharing: Efficient utilization of physical GPU resources among multiple VMs.

- **Disadvantages of Using vGPU:** 
    - Hardware Dependency: Performance is limited by the physical GPU's capabilities.
    - Complex Management: Requires specialized knowledge for setup and maintenance.
    - Cost Factors: High-end GPUs and potential additional software licensing can be expensive.



## 2. Understanding the PowerShell Cmdlet for using the vGPUs Feature

To enable the vGPUs feature, set **GpuTypePath** parameter of the **New-Item** cmdlet in the Step 3, Creating a Network Resource, as shown below.

```powershell
New-Item `
    -GpuTypePath $GpuTypePath `
    -HypervisorConnectionName $ConnectionName `
    # Additional  Parameters...
```



## 3. Example Full Scripts Utilizing vGPUs.

1. [Creation of a Hosting Connection and associated resources with vGPUs](../../Hosting%20Connection/Add%20Hosting%20Connection/Add-HostingConnection-vGPUs.ps1)
2. [Creation of a Hosting Unit with vGPUs](../Add%20Hosting%20Unit/Add-HostingUnit-vGPUs.ps1)



## 4. Reference Documents

For more detailed information on XenServer's virtual GPU (vGPU) features, please refer the pages below.
1. [Provisioning vGPU-enabled CVAD machines.](https://docs.citrix.com/en-us/provisioning/current-release/configure/xendesktop-setup-wizard-vgpu.html)
2. [NVIDIA Virtual GPU.](https://citrixready.citrix.com/partners/nv/nvidia/nvidia-grid.html)


