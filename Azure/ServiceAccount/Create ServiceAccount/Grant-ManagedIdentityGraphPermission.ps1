<#
.SYNOPSIS
    Grants Microsoft Graph application permissions to a managed identity, for use by a managed identity backed service account. Applicable for Citrix DaaS.
.DESCRIPTION
    Grant-ManagedIdentityGraphPermission.ps1 grants the Microsoft Graph application permissions that the service account capabilities need
    to a system-assigned or user-assigned managed identity. A managed identity has no API permissions page in the Azure portal, so the
    permissions are granted as app role assignments with the Microsoft Graph PowerShell SDK.
    Run it once for each managed identity: a system-assigned managed identity is a separate service principal on every Cloud Connector VM.
    Granting application permissions requires the Privileged Role Administrator or Global Administrator role.
    The original version of this script is compatible with Citrix DaaS DDC 131.
#>

# /*************************************************************************
# * Copyright © 2026. Cloud Software Group, Inc. All Rights Reserved.
# * This file is subject to the license terms contained
# * in the license file that is distributed with this file.
# *************************************************************************/

################################
# Step 1: Setup the parameters #
################################
# Requires the Microsoft Graph PowerShell SDK: Install-Module Microsoft.Graph.Applications -Scope CurrentUser
Import-Module Microsoft.Graph.Applications

# [User Input Required] Set parameters
$tenantId = "TenantId"                                              # Microsoft Entra tenant id
# Object (principal) id of the managed identity. In the Azure portal, a system-assigned managed identity shows it on the
# Identity page of the Cloud Connector VM, and a user-assigned managed identity on its own Overview page.
$managedIdentityObjectId = "ManagedIdentityObjectId"
# Microsoft Graph application permissions for the capabilities the service account uses:
#   AzureADDeviceManagement        - Device.ReadWrite.All
#   AzureADSecurityGroupManagement - Group.ReadWrite.All, GroupMember.ReadWrite.All
#   IntuneDeviceManagement         - DeviceManagementManagedDevices.ReadWrite.All
$permissions = @("Device.ReadWrite.All", "DeviceManagementManagedDevices.ReadWrite.All")

######################################
# Step 2: Sign in to Microsoft Graph #
######################################
Connect-MgGraph -TenantId $tenantId -Scopes "Application.Read.All", "AppRoleAssignment.ReadWrite.All"

#########################################################
# Step 3: Grant the permissions to the managed identity #
#########################################################
# The Microsoft Graph service principal defines the app roles, one for each application permission.
$graphServicePrincipal = Get-MgServicePrincipal -Filter "appId eq '00000003-0000-0000-c000-000000000000'"

# Granting a permission that is already held fails, so skip the ones the managed identity already has.
$grantedAppRoleIds = (Get-MgServicePrincipalAppRoleAssignment -ServicePrincipalId $managedIdentityObjectId -All).AppRoleId

foreach ($permission in $permissions)
{
    $appRole = $graphServicePrincipal.AppRoles | Where-Object { $_.Value -eq $permission }
    if ($null -eq $appRole)
    {
        throw "$($permission) is not a Microsoft Graph application permission. Verify the permission name."
    }

    if ($grantedAppRoleIds -contains $appRole.Id)
    {
        Write-Output "$($permission) is already granted."
        continue
    }

    New-MgServicePrincipalAppRoleAssignment -ServicePrincipalId $managedIdentityObjectId `
        -PrincipalId $managedIdentityObjectId `
        -ResourceId $graphServicePrincipal.Id `
        -AppRoleId $appRole.Id | Out-Null
    Write-Output "$($permission) is granted."
}

# A newly granted permission can take several minutes to appear in the tokens issued for the managed identity.
