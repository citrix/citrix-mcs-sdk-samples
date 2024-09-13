# Scripts to convert flat ID disk of existing VMs to streaming optimized disks
The goal of this scripts is to provide a way for administrators to convert existing VMs identity disk to stream optimized disks. This repository contains sample PowerShell scripts to migrate identity disks created in FLAT format. These scripts include:

 - Admin scripts to convert existing VMs identity disks in flat format to streaming optimized disks.
 - The original flat ID disks will remain in the VMs and the new streaming optimized disks will be added to the VMs.However, administrators can provide a parameter to remove the original flat ID disks.
 - PowerShell module  vSphereHelper provides the functions necessary to interact with VMware vCenter server.
 - PowerShell module  vSphereConnect provides the functions necessary to connect to Vmware vCenter server.
 - Powershell module FlatVmdkConverter  provides the functions necessary to convert flat ID disks for a VM or VMs to streaming optimized disks.

## General prerequisites for running the test scripts
The scripts in this repository utilize Citrix PowerShell cmdlets and VMware PowerCLI cmdlets to perform the conversion of existing VMs to streaming optimized disks.  The following prerequisites must be met to run the scripts:
* You must install Windows Powershell 5.x or greater. 5.x is installed by default on Windows 2016 and 2019 servers. 
* Install the Remote Powershell SDK for Citrix Cloud.   See: https://docs.citrix.com/en-us/citrix-virtual-apps-desktops-service/sdk-api.html
* The VM must be domain joined to the domain associated with the resource location used  by the test scripts.
* Virtual machine should have enough storage to download disks during the script execution
* Make sure that the appropriate vCenter certificates are installed on the virtial machine where the script is being executed. From a client system Web browser, download and install trusted root CA certificates.
* A secure client file must be created using the cloud customer specified in the test configuration file.   To do this:
    * Login to Citrix cloud and select the cloud customer.
    * Navigate to the **Identity and Access Managment** page
    * Select **API Access**
    * Create a secure client and record the api and secret key values in a secure location.
    * Requires credentials for the VMware vCenter server that the VMs are hosted on.  

## Setup
* From an administrator Posh prompt run the following:
* Import the required modules
   `Import-Module .\vSphereConnect.psm1`

   `Import-Module .\vSphereHelper.psm1`

   `Import-Module .\FlatVmdkConverter.psm1`


## Using the script
The script can be executed using the following functions:
### ConvertVmdkFiles
The ConvertVmdkFiles function is used to convert the flat ID disk of the VM to streaming optimized disk. The name of a MCS catalog can be provided to convert all VMs in the catalog to streaming optimized disks. Function requires the following parameters:

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
 The RemoveOrphanIdentityDisks function is used to remove the original flat ID disk from the VM and requires the following parameters:

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

The RollBackIdentityDiskConversion function is used to roll back the conversion of the flat ID disk to streaming optimized disk and requires the following parameters:
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