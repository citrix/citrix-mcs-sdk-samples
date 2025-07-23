# Azure Unmanaged Disks Detection and Conversion Scripts

## Overview

Starting in September 2025, Azure virtual machines (VMs) using unmanaged disks (or VHDs) will no longer power on: https://learn.microsoft.com/en-us/azure/virtual-machines/unmanaged-disks-deprecation#how-does-this-affect-me


These PowerShell scripts help administrators identify & convert Azure VMs that are using unmanaged disks. 


## Unmanaged Disk Detection Script
The `DetectUnmanagedDisks.ps1` script checks both the OS and data disks of VMs, determines whether they are managed or unmanaged, and provides recommendations for migration to managed disks. As Microsoft is phasing out unmanaged disks, this tool will assist in ensuring compliance and preparing for a smooth transition to managed disks.

The script can output a detailed CSV report listing all VMs with unmanaged disks, along with the necessary migration recommendations. It is designed to be used in environments with Citrix Broker and Machine Creation Service to check for unmanaged disks in Citrix-managed VMs.

### Features

- **Identify Unmanaged Disks**: The script detects VMs that have unmanaged OS or data disks.
- **Generate Recommendations**: It provides tailored recommendations for either creating a new VM with managed disks or migrating existing VMs to managed disks.
- **Compatibility with Citrix**: The script is integrated with Citrix Broker and Machine Creation Service to retrieve VM information.
- **CSV Export**: All results are exported to a CSV file, providing an easy-to-reference report for administrators.
- **Error Handling**: Includes error handling to manage missing VMs or invalid data.
- **Formatted Console Output**: Displays the results in a user-friendly table format in PowerShell for immediate visibility.

### Usage

This section outlines how to use the Azure VM Unmanaged Disks Check Script. The script checks your Azure VMs to identify those with unmanaged disks and provides recommendations for converting to managed disks.

### Prerequisites

Before running the script, ensure the following:

- **PowerShell**: The script is compatible with PowerShell 7 or higher.
- **Azure PowerShell Module**: You must have the `Az` module installed. To install it, run:

    ```powershell
    Install-Module -Name Az -AllowClobber -Force -SkipPublisherCheck
    ```

- **Citrix PowerShell Modules**: The script uses Citrix cmdlets to retrieve machine and VM details. Ensure that you have the necessary Citrix modules installed and configured.

- **Azure Access**: You need sufficient permissions to access Azure VMs and their associated storage accounts.

### How to Run the Script

1. **Clone or Download the Script**: Obtain the script and save it locally.

2. **Authenticate to Azure**: Open PowerShell and authenticate to your Azure account by running:

    ```powershell
    Connect-AzAccount
    ```

3. **Run the Script**: Execute the script to check the VMs. The script will automatically scan Citrix Broker for VMs and check for unmanaged disks. Use the following command to run the script:

    ```powershell
    .\DetectUnmanagedDisks.ps1
    ```

4. **Check the Results**: The script will output a CSV file with the results, listing VMs that have unmanaged disks, their details, and recommended actions for conversion. The CSV will be saved in the same directory where the script is located.

    Example output message:

    ```plaintext
    The results have been exported to './AzVmWithUnmanagedDisks.csv'.
    ```

5. **Review the CSV**: Open the CSV file to view the list of VMs with unmanaged disks. The CSV includes the following columns:
    - **CatalogName**: The Citrix catalog name.
    - **VMName**: The name of the VM.
    - **ResourceGroup**: The Azure resource group containing the VM.
    - **VMType**: Type of the VM (persistent, non-persistent, etc.).
    - **Recommendation**: Action steps to convert unmanaged disks to managed disks.
	
### Example Command

Here is an example of how to run the script:

```powershell
.\DetectUnmanagedDisks.ps1
```

## Unmanaged Disk Conversion via CVAD
Starting in CVAD 2507, you can convert your MCS-provisioned VMs from unmanaged disks to managed disks using an integrated Citrix solution. The migration applies to both persistent and non-persistent machine catalogs, supporting both on-demand and legacy VMs. A new script called `DetectAndConvertUnmanagedDisks.ps1` has been added to demonstrate how to use this feature. It scans your Citrix environment for MCS-provisioned VMs using unmanaged disks and updates the appropriate provisioning schemes. Optionally, the script can also issue a restart for the affected VMs.

### Prerequisites
Before running the script, ensure the following:
- **Azure Service Principal Permissions**: If you would like to convert persistent VMs, ensure the following permission is added to your Azure Service Principal: `Microsoft.Compute/virtualMachines/convertToManagedDisks/write`

## Features
- **Automated Conversion**: Detects MCS-provisioned VMs using unmanaged disks and updates the provisioning scheme(s) accordingly.
- **Legacy and Non-Legacy Support**: Handles both legacy (no CustomVmData) and non-legacy VMs.
- **Optional Restart**: Can issue a restart for all affected VMs to apply the new configuration.
- **Optional ProvisioningSchemeName Input**: Can convert all or just a single Provisioning Scheme.
- **User Confirmation**: Lists the impacted VMs and prompts the user before making any changes.


### Usage
This script includes two optional parameters: `ProvisioningSchemeName` and `Restart`. Use -ProvisioningSchemeName to target a specific provisioning scheme and -Restart to restart affected VMs such that the disks are converted immediately:

```powershell
.\DetectAndConvertUnmanagedDisks.ps1
.\DetectAndConvertUnmanagedDisks.ps1 -ProvisioningSchemeName "MyProvScheme"
.\DetectAndConvertUnmanagedDisks.ps1 -Restart
```

The conversion is applicable to both persistent and non-persistent VMs. If `-Restart` is not used, then the disks will not be converted until the next PowerOn. If the conversion is successful, the VM will start using the managed disks, and the unmanaged disks will be cleaned up. In case of a conversion failure, the VM will still boot using VHDs, and any managed disks created during the attempt will be cleaned up. The conversion will be retried on the next Power On.

If there is a failure when converting the VMs or cleaning up the VHDs, a warning will be issued. These warnings can be viewed using the following command:

```powershell
Get-ProvOperationEvent -LinkedObjectType ProvisioningScheme -LinkedObjectUid <your-provscheme-id>
```

To learn more about Get-ProvOperationEvent, please see https://developer-docs.citrix.com/en-us/citrix-daas-sdk/MachineCreation/Get-ProvOperationEvent.html \
To learn more about this conversion feature in general, please see https://docs.citrix.com/en-us/citrix-daas/install-configure/machine-catalogs-create/create-machine-catalog-citrix-azure#migrate-from-unmanaged-to-managed-disks