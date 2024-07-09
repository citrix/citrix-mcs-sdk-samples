<#
.SYNOPSIS
    Sets or changes MCSIO settings on an existing MCS catalog. Applicable for Citrix DaaS and on-prem.
.DESCRIPTION
    Set-MCSIO-Size.ps1 helps change wite back cache disk size and memory size configuration on an existing MCS catalog with Write-back cache enabled.
    The original version of this script is compatible with Citrix Virtual Apps and Desktops 7 2402 Long Term Service Release (LTSR).
#>

# /*************************************************************************
# * Copyright © 2024. Cloud Software Group, Inc. All Rights Reserved.
# * This file is subject to the license terms contained
# * in the license file that is distributed with this file.
# *************************************************************************/

# Add Citrix snap-ins
Add-PSSnapin -Name "Citrix.MachineCreation.Admin.V2"

#------------------------------------------------- Create a ProvisioningScheme -----------------------------------------------------#
# [User Input Required] Set parameters for New-ProvScheme
$provisioningSchemeName = "demo-provScheme"
# WriteBackCacheDiskSize specifies the size in Gigabytes of the disk to use as a Write Back Cache.
$writeBackCacheDiskSize = 256
# WriteBackCacheMemorySize specifies the size in Megabytes of the memory to use as a Write Back Cache. Setting this parameter to 0 disables the use of memory for Write Back Cache.
$writeBackCacheMemorySize = 320

# Modify the Provisioning Scheme
# WriteBackCacheDiskSize & WriteBackCacheMemorySize can only be set or modified if the Provisioning Scheme was previously created with UseWriteBackCache.
# WriteBackCacheDiskSize & WriteBackCacheMemorySize only applies to newly created VMs and does not affect VMs which have already been created from the Provisioning Scheme.
Set-ProvScheme -ProvisioningSchemeName $provisioningSchemeName -WriteBackCacheDiskSize $writeBackCacheDiskSize -WriteBackCacheMemorySize $writeBackCacheMemorySize