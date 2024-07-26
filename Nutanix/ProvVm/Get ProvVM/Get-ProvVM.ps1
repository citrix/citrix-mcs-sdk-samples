<#
.SYNOPSIS
    Get provisioned VMs from a Provisioning Scheme
.DESCRIPTION
    `Get-ProvVM.ps1` script gets a specific VM, or all the VMs from a Provisioning Scheme.
    The original version of this script is compatible with Citrix Virtual Apps and Desktops 7 2402 Long Term Service Release (LTSR).
.INPUTS
    1. ProvisioningSchemeName: The name of the provisioning scheme
    2. VMName: Name of the VM to get
.EXAMPLE
    # Get all VMs from a Provisioning Scheme
    .\Get-ProvVM.ps1 -ProvisioningSchemeName "myProvScheme"

    # Get a specific VM from a Provisioning Scheme
    .\Get-ProvVM.ps1 -ProvisioningSchemeName "myProvScheme" -VMName "myVM-1"
#>

# /*************************************************************************
# * Copyright © 2024. Cloud Software Group, Inc. All Rights Reserved.
# * This file is subject to the license terms contained
# * in the license file that is distributed with this file.
# *************************************************************************/

param(
    [Parameter(mandatory=$true)]
    [string] $ProvisioningSchemeName,
    [string] $VMName
)

# Enable Citrix PowerShell Cmdlets
Add-PSSnapin -Name "Citrix.Host.Admin.V2","Citrix.MachineCreation.Admin.V2" 

$params = @{
    "ProvisioningSchemeName"= $ProvisioningSchemeName
}

if($PSBoundParameters.ContainsKey("VMName")){
    $params.Add("VMName", $VMName)
}

try{
    & Get-ProvVM @params -ErrorAction Stop
} catch {
    Write-Error $_
    exit
}
