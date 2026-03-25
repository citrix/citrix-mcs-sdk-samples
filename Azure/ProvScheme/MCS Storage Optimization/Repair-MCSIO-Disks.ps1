<#
.SYNOPSIS
    Repairs all base WBC disks for a specified catalog
.DESCRIPTION
    Repair-MCSIO-Disk.ps1 repairs all base WBC disks for a specified catalog in the event some were deleted by mistake.
    It will call Repair-ProvScheme with -WBCDisks which will reupload base WBC disks for the specified catalog for any that are missing.
#>

# /*************************************************************************
# * Copyright © 2026. Cloud Software Group, Inc. All Rights Reserved.
# * This file is subject to the license terms contained
# * in the license file that is distributed with this file.
# *************************************************************************/

# Add Citrix snap-ins
Add-PSSnapin -Name "Citrix.MachineCreation.Admin.V2"

# [User Input Required] Set parameters for Repair-ProvScheme
$provisioningSchemeName = "demo-provScheme"

# Repair the ProvisioningScheme WBC disks
Repair-ProvScheme -ProvisioningSchemeName $provisioningSchemeName -WBCDisks