# Scripts for converting existing VMs identity disk in monolithic-flat format to stream-optimized VMDK format.
The objective of these PowerShell scripts is to provide administrators with sample scripts to convert identity disks with monolithic-flat VMDK format to a stream-optimized VMDK format.These scripts include functions to:

 - Convert existing virtual machines (VMs) identity disks from monolithic-flat format to stream-optimized VMDK format.
 - Remove the original flat identity disk from the VM as a distinct operation.
 - Rollback the conversion of the identity disks from a stream-optimized VMDK format to a monolithic-flat.

 Notably, the above operations allow parameters that enable the conversion or rollback of identity disks for all VMs within a machine catalog or for a specific VM designated by administrators.
 
 
## General prerequisites for running the test scripts
The scripts contained within this repository leverage Citrix PowerShell cmdlets in conjunction with VMware PowerCLI cmdlets in order to facilitate the conversion of existing virtual machines identity disks with monolithic-flat VMDK format to a stream-optimized VMDK format in a vSAN8 environment. The following prerequisites must be satisfied in order to execute the scripts:
* Installation of Windows PowerShell version 5.x or higher. It is noteworthy that version 5.x is the default installation on Windows 2016 and 2019 servers.
* Installation of the Remote PowerShell SDK for Citrix Cloud. Refer to the following documentation for further guidance: Refer to the following documentation for further guidance: https://docs.citrix.com/en-us/citrix-virtual-apps-desktops-service/sdk-api.html
* A virtual machine must be domain joined to the domain associated with the resource location utilized by the test scripts.
* Sufficient storage capacity on the virtual machine to accommodate the downloading of disks during script execution.
* Installation of the appropriate vCenter certificates on the virtual machine where the script is being executed. These certificates can be downloaded and installed by accessing the trusted root CA certificates from a client system's web browser.
* Creation of a secure client file utilizing the cloud customer specified in the test configuration file. The following steps should be followed to achieve this:
    * Login to Citrix cloud and select the cloud customer.
    * Navigate to the **Identity and Access Management** page
    * Select **API Access**
    * Create a secure client and record the api and secret key values in a secure location.
* Credentials for the VMware vCenter server on which the virtual machines are hosted are required.

## Setup
* From an administrator Posh prompt run the following:
* Import the required modules
   `Import-Module .\vSphereConnect.psm1`

   `Import-Module .\vSphereHelper.psm1`

   `Import-Module .\FlatVmdkConverter.psm1`


## Using the script
The script can be executed using the following functions:
### ConvertVmdkFiles
The "ConvertVmdkFiles" function enables the conversion of existing virtual machines identity disk from a monolithic-flat format to a streaming-optimized VMDK format. Additionally, it offers the option to specify the name of an MCS catalog, allowing for the conversion of all VMs within that catalog's identity disks from monolithic-flat format to streaming-optimized disks.

During the VMDK conversion process, the identity disk of the virtual machine is downloaded as stream-optimized files and subsequently uploaded back to the vSAN storage as a new identity disk file and attached to the virtual machine. This original disk is retained within the VM folder unless administrators specifically choose to force remove it.

The function requires the following parameters:
### Parameters
- Required parameters:
    - `vCenterServerAddress`: The address of the vCenter server.
    - `VMName`: The name of the VM to convert.
    OR 
	- `ProvisioningSchemeName`: Name of the new provisioning scheme.
    If using cloud customer, 
    - `CloudCustomerId`: The Citrix Cloud customer ID 
	- `CloudCustomerApiKey`: The Citrix Cloud customer API key.
- Optional Parameters:
    - `ForceRemoveFlatIdentity`: A boolean value to remove the original flat ID disk from the VM.
	
### Example
The function can be executed like the example below:

```powershell

   Import-Module .\FlatVmdkConverter.psm1

   ConvertVmdkFiles `
    -VMName myVM `
    -CloudCustomerId "myCloudCustomerId" `
    -CloudCustomerApiKey "myCloudCustomerApiKey" `
    -vCenterServerAddress "0.0.0.0"

     ConvertVmdkFiles `
    -ProvisioningSchemeName myProvisioningScheme `
    -CloudCustomerId "myCloudCustomerId" `
    -CloudCustomerApiKey "myCloudCustomerApiKey" `
    -vCenterServerAddress "0.0.0.0"

    ConvertVmdkFiles `
     -VMName myVM `
    -CloudCustomerId "myCloudCustomerId" `
    -CloudCustomerApiKey "myCloudCustomerApiKey" `
    -vCenterServerAddress "0.0.0.0"
    -ForceRemoveFlatIdentity $true
```
 
 ### RemoveOrphanIdentityDisks
 The RemoveOrphanIdentityDisks function is utilized to remove the original identity disks with monolithic-flat format from the virtual machine folder. The function assumes that the original identity disk is still present in the VM folder and was not removed during the VMDK file format conversion. The function requires the following parameters:

 ### Parameters
- Required parameters:
    - `vCenterServerAddress`: The address of the vCenter server.
    - `VMName`: The name of the VM to convert.
    OR 
	- `ProvisioningSchemeName`: Name of the new provisioning scheme.
    If using cloud customer 
    - `CloudCustomerId`: The Citrix Cloud customer ID 
	- `CloudCustomerApiKey`: The Citrix Cloud customer API key.

### Example
The function can be executed like the example below:

```powershell
   Import-Module .\FlatVmdkConverter.psm1
   RemoveOrphanIdentityDisks `
	-VMName myVM `
	-CloudCustomerId "myCloudCustomerId" `
	-CloudCustomerApiKey "myCloudCustomerApiKey" `
	-vCenterServerAddress "0.0.0.0"
```

### RollBackIdentityDiskConversion
The RollBackIdentityDiskConversion function is used to rollback the conversion of the identity disks from a stream-optimized VMDK format to a monolithic-flat. This operation involves detaching the stream-optimized identity disk and subsequently reattaching the original identity disk with a monolithic-flat format. The function requires the following parameters:

### Parameters
- Required parameters:
    - `vCenterServerAddress`: The address of the vCenter server.
    - `VMName`: The name of the VM to convert.
    OR 
	- `ProvisioningSchemeName`: Name of the new provisioning scheme.
    If using cloud customer 
    - `CloudCustomerId`: The Citrix Cloud customer ID 
	- `CloudCustomerApiKey`: The Citrix Cloud customer API key.

### Example
- The function can be executed like the example below:

```powershell
   Import-Module .\FlatVmdkConverter.psm1
   RollBackIdentityDiskConversion `
	-VMName myVM `
	-CloudCustomerId "myCloudCustomerId" `
	-CloudCustomerApiKey "myCloudCustomerApiKey" `
	-vCenterServerAddress "0.0.0.0"
```

## Limitations
* The above solution will not support Encrypted VM's  as it relies on ExportVM capability.
* Minimum set permission required to run this script is not evaluated. It is recommended to use an administrator rights to run this script.