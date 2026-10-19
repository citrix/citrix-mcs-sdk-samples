<#
.SYNOPSIS
    Sets or changes the BackupVmConfiguration custom property on an existing MCS catalog.
    The updated custom properties will be applicable to new machines post operation, not to the existing machines.    
.DESCRIPTION
    Update-ProvScheme-WithBackupVmConfiguration.ps1 helps sets or change the BackupVmConfiguration custom property on an existing MCS catalog.
    The original version of this script is compatible with Citrix DaaS 130 and CVAD 2611 CR.
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

# [User Input Required] Setup the parameters for Set-ProvScheme
$provisioningSchemeName = "demo-provScheme"
$customProperties = @'
{
    "BackupVmConfiguration": [{"InstanceType": "t3.medium", "MarketType": "spot"}, {"InstanceType": "t3.large"}]
}
'@

#####################################################
# Step 1: Change the Provisioning Scheme properties #
#####################################################
# Change the provisioning scheme properties
Set-ProvScheme -ProvisioningSchemeName $provisioningSchemeName -CustomProperties $customProperties