<#
.SYNOPSIS
    Update the master image of an existing MCS catalog.
	The updated master image will be applicable to new machines post-operation, not to the existing machines.
	For applying to existing machines, run Set-ProvVmUpdateTimeWindow.
	Applicable for Citrix DaaS and on-prem.
.DESCRIPTION
    This script helps to update the hard disk image used to create virtual machines. All new virtual machines created after this command will use this new hard disk image.
	In this example, the master image will be updated to 'master-image-snaphot' which is a snapshot of the 'master-image-vm' VM.
	If the catalog has the property "CleanOnBoot" enabled, previously created catalog VMs will be updated to the new image after the next time they are started.
    The original version of this script is compatible with Citrix Virtual Apps and Desktops 7 2203 Long Term Service Release (LTSR).
#>

# /*************************************************************************
# * Copyright © 2024. Cloud Software Group, Inc. All Rights Reserved.
# * This file is subject to the license terms contained
# * in the license file that is distributed with this file.
# *************************************************************************/

# Add Citrix snap-ins
Add-PSSnapin -Name "Citrix.Host.Admin.V2","Citrix.MachineCreation.Admin.V2"

# [User Input Required]
$provisioningSchemeName = "demo-provScheme"
$hostingUnitName = "GcpHostingUnitName"
$masterImageVmName = "master-image-vm"
$masterImageSnapshotName = "master-image-snaphot"
$imageNote = "demo snapshot"
$warningMessage = "Rebooting machine shortly. Please Save your work."
$warningDuration = 15
$warningRepeatInterval = 5
$rebootDuration = 240

# Set MasterImageVM parameter to an image source
$masterImageSnapshot = "XDHyp:\HostingUnits\$hostingUnitName\$masterImageVmName.vm\$masterImageSnapshotName.snapshot"

# Update the master image
Publish-ProvMasterVMImage -ProvisioningSchemeName $provisioningSchemeName -MasterImageVM $masterImageSnapshot -MasterImageNote $imageNote

# Reboot machines of the Provisioning Scheme
Get-BrokerCatalog -Name $provisioningSchemeName | Start-BrokerRebootCycle -WarningMessage $warningMessage -WarningDuration $warningDuration -WarningRepeatInterval $warningRepeatInterval -RebootDuration $rebootDuration