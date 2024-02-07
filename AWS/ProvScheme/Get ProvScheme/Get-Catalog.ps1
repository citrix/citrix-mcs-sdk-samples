<#
.SYNOPSIS
    Get information about MCS catalog. Applicable for Citrix DaaS and on-prem.
.DESCRIPTION
    Get-Catalog.ps1 emulates the behavior of the Get-BrokerCatalog command.
    It provides information about provisioning schemes, allowing administrators to manage virtual machines.
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

# [User Input Required] Setup the parameters for Get-BrokerCatalog
$catalogName = "demo-provScheme"
$filter = "{AllocationType -eq 'Random' -and PersistUserChanges -eq 'OnLocal' }"
$sortBy = "-AvailableCount"
$maxRecord = 5

##################################
# Step 1: Get the Broker Catalog #
##################################
# Get the specific Catalog
Get-BrokerCatalog -Name $catalogName

# Get a filtered list of Catalogs
Get-BrokerCatalog -Filter $filter -SortBy $sortBy -MaxRecordCount $maxRecord