<#
.SYNOPSIS
    Disable Azure Arc Onboarding on an existing MCS catalog. This change is only applicable to the new machines added after the operation. The existing machines in the catalog are not affected. Applicable for Citrix DaaS and on-prem.
.DESCRIPTION
    DisableProvScheme-WithAzureArc helps in disabling the Azure Arc Onboarding on an existing MCS catalog.
    The original version of this script is compatible with Citrix Virtual Apps and Desktops 7 2511.
#>

# /*************************************************************************
# * Copyright © 2025. Cloud Software Group, Inc. All Rights Reserved.
# * This file is subject to the license terms contained
# * in the license file that is distributed with this file.
# *************************************************************************/

# Add Citrix snap-ins
Add-PSSnapin -Name "Citrix.Host.Admin.V2","Citrix.MachineCreation.Admin.V2","Citrix.Broker.Admin.V2"

#------------------------------ Disable AzureArc on existing ProvisioningScheme -------------------------------------#

# [User Input Required] Set parameters for Set-ProvScheme
$provisioningSchemeName = "demo-provScheme"
$enabledAzureArcOnboarding = $false

# Disable Azure Arc Onboarding on existing catalog
Set-ProvScheme -ProvisioningSchemeName $provisioningSchemeName -EnableAzureArcOnboarding $EnableAzureArcOnboarding 
