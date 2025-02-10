# Azure Unmanaged Disks Detection Script

## Overview

This PowerShell script helps administrators identify Azure virtual machines (VMs) that are using unmanaged disks. The script checks both the OS and data disks of VMs, determines whether they are managed or unmanaged, and provides recommendations for migration to managed disks. As Microsoft is phasing out unmanaged disks, this tool will assist in ensuring compliance and preparing for a smooth transition to managed disks.

The script can output a detailed CSV report listing all VMs with unmanaged disks, along with the necessary migration recommendations. It is designed to be used in environments with Citrix Broker and Machine Creation Service to check for unmanaged disks in Citrix-managed VMs.

## Features

- **Identify Unmanaged Disks**: The script detects VMs that have unmanaged OS or data disks.
- **Generate Recommendations**: It provides tailored recommendations for either creating a new VM with managed disks or migrating existing VMs to managed disks.
- **Compatibility with Citrix**: The script is integrated with Citrix Broker and Machine Creation Service to retrieve VM information.
- **CSV Export**: All results are exported to a CSV file, providing an easy-to-reference report for administrators.
- **Error Handling**: Includes error handling to manage missing VMs or invalid data.
- **Formatted Console Output**: Displays the results in a user-friendly table format in PowerShell for immediate visibility.

## Usage

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