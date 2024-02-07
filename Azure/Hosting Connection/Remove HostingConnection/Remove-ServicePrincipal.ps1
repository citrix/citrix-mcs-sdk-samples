<#
.SYNOPSIS
    Removes the Service Principal.
.DESCRIPTION
    Remove-ServicePrincipal.ps1 removes the service principal when ApplicationName is provided.
    The original version of this script is compatible with Citrix Virtual Apps and Desktops 7 2203 Long Term Service Release (LTSR).
#>

# /*************************************************************************
# * Copyright © 2024. Cloud Software Group, Inc.
# * This file is subject to the license terms contained
# * in the license file that is distributed with this file.
# *************************************************************************/

# [User Input Required]
$SubscriptionId = "subscriptionId"  #should be Guid
$TenantId = "TenantId" #should be Guid
$objectId = "objectId" #should be Guid

# Note - Open Powershell as Administrator
# Install the Az modules before importing. Refer to the README file in the "Remove HostingConnection" folder.
Import-Module Az

###############################################################
# Step 1: Connect to your Azure Resource Manager subscription #
###############################################################

Connect-AzAccount

########################################
# Step 2: Delete the service principal #
########################################

Set-AzContext -Tenant $TenantId -Subscription $SubscriptionId
Remove-AzADApplication -ObjectId $objectId