<#
.SYNOPSIS
    Update the master image on an existing MCS catalog. Applicable for Citrix DaaS and on-prem.
.DESCRIPTION
    Update-MasterImage.ps1 helps to update the hard disk image used to create virtual machines.
    All new virtual machines created after this command will use this new hard disk image.
	If the existing catalog has a "CleanOnBoot" type, previously created catalog VMs will be updated to the new image after the next time they are started.
    The original version of this script is compatible with Citrix Virtual Apps and Desktops 7 2203 Long Term Service Release (LTSR).
#>

# /*************************************************************************
# * Copyright © 2024. Cloud Software Group, Inc. All Rights Reserved.
# * This file is subject to the license terms contained
# * in the license file that is distributed with this file.
# *************************************************************************/

# Add Citrix snap-ins
Add-PSSnapin -Name "Citrix.Host.Admin.V2","Citrix.MachineCreation.Admin.V2"

# [User Input Required] Setup the parameters for Publish-ProvMasterVMImage
$provisioningSchemeName = "demo-provScheme"
$hostingUnitName = "demo-hostingunit"
$masterVmName= "demo-master"
$masterVmSnapshot= "demo-snapshot"
$masterImage = "XDHyp:\HostingUnits\$hostingUnitName\$masterVmName.vm\$masterVmSnapshot.snapshot"
$warningMessage = "Rebooting machine shortly. Save your work"
$warningDuration = 15
$warningRepeatInterval = 5
$rebootDuration = 240

# Update the provisioining scheme's Master Image
Publish-ProvMasterVMImage -MasterImageVM $masterImage -ProvisioningSchemeName $provisioningSchemeName

# Reboot machines of the Provisioning Scheme
Get-BrokerCatalog -Name $provisioningSchemeName | Start-BrokerRebootCycle -WarningMessage $warningMessage -WarningDuration $warningDuration
-WarningRepeatInterval $warningRepeatInterval -RebootDuration $rebootDuration