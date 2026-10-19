<#
.SYNOPSIS
    Get the hardware view of an MCS Provisioning Scheme on SCVMM/Hyper-V.
.DESCRIPTION
    Get-ProvSchemeDetails.ps1 emulates the behavior of the Get-ProvSchemeDetails command.
    It reports the hardware configuration a catalog provisions with - compute, security, disks,
    write-back cache, networking and the master image - grouped into six sections.

    Each section is returned as a JSON string, so use ConvertFrom-Json to work with the values.
.INPUTS
    None. You cannot pipe objects to this script.
.OUTPUTS
    A ProvisioningSchemeDetailsFull object containing ProvisioningSchemeUid, ProvisioningSchemeName,
    ProvisioningSchemeVersion and the six JSON sections: SchemeInfo, SecurityInfo, DiskInfo,
    MCSIOInfo, NetworkInfo and ImageAndTemplateInfo.
.NOTES
    Unavailable fields can be absent, null or empty, and a section can be an empty JSON object.
    The view can return partial results when metadata or hypervisor reads fail.
    Always test for a section and its keys before reading them.
.EXAMPLE
    .\Get-ProvSchemeDetails.ps1
#>

# /*************************************************************************
# * Copyright © 2026. Cloud Software Group, Inc. All Rights Reserved.
# * This file is subject to the license terms contained
# * in the license file that is distributed with this file.
# *************************************************************************/

################################
# Step 0: Setup the parameters #
################################
# Add Citrix snap-ins
Add-PSSnapin -Name "Citrix.Host.Admin.V2","Citrix.MachineCreation.Admin.V2"

# [User Input Required] Setup the parameters for Get-ProvSchemeDetails
$provSchemeName = "demo-provScheme"

##############################################
# Step 1: Get the provisioning scheme detail #
##############################################
$details = Get-ProvSchemeDetails -ProvisioningSchemeName $provSchemeName
$details

# A provisioning scheme can also be identified by its Uid
# $provSchemeUid = (Get-ProvScheme -ProvisioningSchemeName $provSchemeName).ProvisioningSchemeUid
# $details = Get-ProvSchemeDetails -ProvisioningSchemeUid $provSchemeUid

###########################################
# Step 2: Read an individual section      #
###########################################
# Every section is a JSON string. Check it is present before converting it.
if ([string]::IsNullOrWhiteSpace($details.SchemeInfo)) {
    Write-Output "SchemeInfo is unavailable for '$($details.ProvisioningSchemeName)'."
} else {
    $schemeInfo = $details.SchemeInfo | ConvertFrom-Json
    $schemeInfo

    # Report the Hyper-V generation and the compute assigned to the catalog
    "Generation : {0}" -f $schemeInfo.Generation
    "CPUs       : {0}" -f $schemeInfo.CpuCount
    "Memory MB  : {0}" -f $schemeInfo.MemoryMB
}

############################################################
# Step 3: Check the security posture of the catalog        #
############################################################
if ([string]::IsNullOrWhiteSpace($details.SecurityInfo)) {
    Write-Output "SecurityInfo is unavailable for '$($details.ProvisioningSchemeName)'."
} else {
    $securityInfo = $details.SecurityInfo | ConvertFrom-Json

    # EnableSecureBoot is always false on Generation 1 VMs, where the setting has no meaning
    "Secure boot : {0}" -f $securityInfo.EnableSecureBoot
    "vTPM        : {0}" -f $securityInfo.EnablevTPM

    # Only the presence of a key protector is reported, never the protector itself
    "Key protector present : {0}" -f $securityInfo.HasKeyProtector
}

##################################################
# Step 4: Inspect storage and write-back cache   #
##################################################
if ([string]::IsNullOrWhiteSpace($details.DiskInfo)) {
    Write-Output "DiskInfo is unavailable for '$($details.ProvisioningSchemeName)'."
} else {
    $diskInfo = $details.DiskInfo | ConvertFrom-Json

    # Available OS-tier storage does not imply a base-image replica exists.
    $diskInfo.OSDiskStorageNames
}

if ([string]::IsNullOrWhiteSpace($details.MCSIOInfo)) {
    Write-Output "MCSIOInfo is unavailable for '$($details.ProvisioningSchemeName)'."
} else {
    $mcsioInfo = $details.MCSIOInfo | ConvertFrom-Json

    if ($mcsioInfo.UseWriteBackCache) {
        "WBC disk GB   : {0}" -f $mcsioInfo.WriteBackCacheDiskSize
        "WBC memory MB : {0}" -f $mcsioInfo.WriteBackCacheMemorySize

        # The drive letter key is absent unless one was assigned
        if ($null -ne $mcsioInfo.WriteBackCacheDriveLetter) {
            "WBC drive     : {0}" -f $mcsioInfo.WriteBackCacheDriveLetter
        }
    }
}

##############################################
# Step 5: List the network adapters          #
##############################################
if ([string]::IsNullOrWhiteSpace($details.NetworkInfo)) {
    Write-Output "NetworkInfo is unavailable for '$($details.ProvisioningSchemeName)'."
} else {
    $networkInfo = $details.NetworkInfo | ConvertFrom-Json
    $networkInfo.NetworkInterfaceIds
}

####################################################################
# Step 6: Report the security posture of every catalog in the site #
####################################################################
Get-ProvScheme | ForEach-Object {
    $scheme = Get-ProvSchemeDetails -ProvisioningSchemeName $_.ProvisioningSchemeName

    if ([string]::IsNullOrWhiteSpace($scheme.SecurityInfo)) {
        [PSCustomObject]@{
            Name       = $scheme.ProvisioningSchemeName
            SecureBoot = "Unavailable"
            vTPM       = "Unavailable"
        }
    } else {
        $security = $scheme.SecurityInfo | ConvertFrom-Json

        [PSCustomObject]@{
            Name       = $scheme.ProvisioningSchemeName
            SecureBoot = $security.EnableSecureBoot
            vTPM       = $security.EnablevTPM
        }
    }
} | Format-Table
