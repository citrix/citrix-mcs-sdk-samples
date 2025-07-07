<#
.SYNOPSIS
    Update the image version spec on an existing MCS catalog.
    The updated image will be applicable to new machines post operation, not to the existing machines.
    Applicable for Citrix DaaS and on-prem.
.DESCRIPTION
    Update-MasterImage.ps1 helps to update the hard disk image used to create virtual machines.
    All new virtual machines created after this command will use this new hard disk image.
	If the existing catalog has a "CleanOnBoot" type, previously created catalog VMs will be updated to the new image after the next time they are started.
    The original version of this script is compatible with Citrix DaaS July 2025 Release (DDC 125).
#>

# /*************************************************************************
# * Copyright © 2025. Cloud Software Group, Inc. All Rights Reserved.
# * This file is subject to the license terms contained
# * in the license file that is distributed with this file.
# *************************************************************************/

################################
# Step 0: Setup the parameters #
################################
# Add Citrix snap-ins
Add-PSSnapin -Name "Citrix.Host.Admin.V2","Citrix.MachineCreation.Admin.V2"

# [User Input Required] Setup the parameters for Set-ProvScheme
$provisioningSchemeName = "demo-provScheme"

# [User Input Required] Setup the parameters for Publish-ProvMasterVMImage
# The ImageVersionSpecUid is returned when creating a prepared image (See 'Image Management')
$imageVersionSpecUid = "00000000-0000-0000-0000-000000000000"

#######################################################
# Step 1: Change the Provisioning Scheme Image Version#
#######################################################
# Update the provisioining scheme's Master Image
Set-ProvSchemeImage -ImageVersionSpecUid $imageVersionSpecUid -ProvisioningSchemeName $provisioningSchemeName