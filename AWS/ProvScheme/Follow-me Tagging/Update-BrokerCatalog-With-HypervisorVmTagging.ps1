<#
.SYNOPSIS
    Enables or disables tagging on an existing Broker catalog. Applicable for Citrix DaaS.
.DESCRIPTION
    Update-BrokerCatalog-With-HypervisorVmTagging helps to update an existing Broker catalog's properties such as HypervisorVMTagging.
    The original version of this script is compatible with Citrix DaaS January 2026 Release (DDC 127).
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

# [User Input Required] 
# Setup the parameters for Set-BrokerCatalog
# hypervisorVMTagging can also be set to false for disabling tagging
$provisioningSchemeName = "demo-provScheme"
$description = "This is a new description"
$hypervisorVMTagging = $true

##########################################
# Step 1: Change HypervisorVMTagging #
##########################################
# Update the description of the Catalog
Set-BrokerCatalog -Name $provisioningSchemeName -Description $description -HypervisorVMTagging:$hypervisorVMTagging