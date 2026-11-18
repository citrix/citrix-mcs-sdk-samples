<#
.SYNOPSIS
    Read the hardware details of an MCS virtual machine on SCVMM/Hyper-V.
.DESCRIPTION
    Queries Get-ProvVMDetails and displays its six JSON sections alongside the
    top-level VM properties. Empty sections are reported as unavailable.
.NOTES
    Requires an SDK and deployment that support the SCVMM VM-view fields.
    See the README for availability and the limits of fallback data.
.EXAMPLE
    .\Get-ProvVMDetails.ps1
#>

# /*************************************************************************
# * Copyright © 2026. Cloud Software Group, Inc. All Rights Reserved.
# * This file is subject to the license terms contained
# * in the license file that is distributed with this file.
# *************************************************************************/

# [User Input Required]
$provisioningSchemeName = "demo-provScheme"
$vmName = "demo-vm"

#######################################
# Step 1: Query the MCS virtual machine
#######################################
Add-PSSnapin -Name "Citrix.MachineCreation.Admin.V2" -ErrorAction Stop

$details = @(Get-ProvVMDetails -ProvisioningSchemeName $provisioningSchemeName `
    -VMName $vmName -ErrorAction Stop)

if ($details.Count -eq 0) {
    throw "No VM details were returned for '$vmName' in '$provisioningSchemeName'."
}

######################################
# Step 2: Read the hardware sections
######################################
$sectionNames = @("VMInfo", "SecurityInfo", "DiskInfo", "MCSIOInfo", "NetworkInfo", "ImageAndTemplateInfo")

foreach ($vmDetails in $details) {
    $vmDetails | Select-Object Name, ProvisioningSchemeName, ProvisioningSchemeVersion, `
        CpuCount, MemoryMB, Persistent, UseWriteBackCache, WriteBackCacheDiskSize, `
        WriteBackCacheMemorySize, ImageOutOfDate | Format-List

    foreach ($sectionName in $sectionNames) {
        $sectionJson = $vmDetails.$sectionName
        if ([string]::IsNullOrWhiteSpace($sectionJson)) {
            Write-Output "$sectionName is unavailable for '$($vmDetails.Name)'."
            continue
        }

        $section = $sectionJson | ConvertFrom-Json -ErrorAction Stop
        if ($null -eq $section -or @($section.PSObject.Properties).Count -eq 0) {
            Write-Output "$sectionName has no reported fields for '$($vmDetails.Name)'."
            continue
        }

        Write-Output "$sectionName for '$($vmDetails.Name)':"
        $section | Format-List
    }
}
