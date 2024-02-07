<#
.SYNOPSIS
    Update the master image on an existing MCS catalog.
	The updated master image will be applicable to new machines post operation, not to the existing machines.
	For applying to existing machines, run Set-ProvVmUpdateTimeWindow.
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

# Add Citrix snap-ins
Add-PSSnapin -Name "Citrix.Host.Admin.V2","Citrix.MachineCreation.Admin.V2"

#------------------------------------------------- Update the master image of a ProvisioningScheme -----------------------------------------------------#
# [User Input Required]
$provisioningSchemeName = "demo-provScheme"
$hostingUnitName = "demo-hostingUnit"
$resourceGroupName = "demo-resourceGroup"
$masterImageSnapshotName = "demo-snapshot"
$imageNote = "demo snapshot"
$warningMessage = "Rebooting machine shortly. Save your work"
$warningDuration = 15
$warningRepeatInterval = 5
$rebootDuration = 240

# Set MasterImageVM parameter to an image source
$masterImageVm = "XDHyp:\HostingUnits\$hostingUnitName\image.folder\$resourceGroupName.resourcegroup\$masterImageSnapshotName.snapshot"

# Update the master image
Publish-ProvMasterVMImage -ProvisioningSchemeName $provisioningSchemeName -MasterImageVM $masterImageVm -MasterImageNote $imageNote

# Reboot machines of the Provisioning Scheme
Get-BrokerCatalog -Name $provisioningSchemeName | Start-BrokerRebootCycle -WarningMessage $warningMessage -WarningDuration $warningDuration -WarningRepeatInterval $warningRepeatInterval -RebootDuration $rebootDuration