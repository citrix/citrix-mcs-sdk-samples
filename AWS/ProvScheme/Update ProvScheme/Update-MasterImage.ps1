<#
.SYNOPSIS
    Update the master image on an existing MCS catalog.
    The updated master image will be applicable to new machines post operation, not to the existing machines.
    Applicable for Citrix DaaS and on-prem.
.DESCRIPTION
    Update-MasterImage.ps1 helps to update the hard disk image used to create virtual machines.
    All new virtual machines created after this command will use this new hard disk image.
	If the existing catalog has a "CleanOnBoot" type, previously created catalog VMs will be updated to the new image after the next time they are started.
    The original version of this script is compatible with Citrix Virtual Apps and Desktops 7 2203 Long Term Service Release (LTSR).
#>

# /*************************************************************************
# * Copyright © 2024. Cloud Software Group, Inc.
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
$hostingUnitName = "demo-hostingunit"

# [User Input Required] Setup the parameters for Publish-ProvMasterVMImage
$masterImageVm = "XDHyp:\HostingUnits\$hostingUnitName\demo-master-image (ami-12345678910).template"

#######################################################
# Step 1: Change the Provisioning Scheme Master Image #
#######################################################
# Update the provisioining scheme's Master Image
Publish-ProvMasterVMImage -MasterImageVM $masterImageVm -ProvisioningSchemeName $provisioningSchemeName