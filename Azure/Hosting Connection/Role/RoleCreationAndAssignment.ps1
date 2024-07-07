<#
.SYNOPSIS
    Create a new Azure Role with minimum permisions to execute Citrix Virtual Apps and Desktops (CVAD) operations and assign the role to the target Service Principal.
.DESCRIPTION
    This script is to create a new Azure Role with minimum permisions to execute Citrix Virtual Apps and Desktops (CVAD) operations and assign the role to the target Service Principal
    For running this script, please ensure that Azure PowerShell is installed and that you open PowerShell as an Administrator.
.INPUTS
    1. Location: The deployment location, for example, "centralus", "eastus", etc.
    2. TemplateFilePath: The file path of the Azure Resource Management (ARM) Template.
    3. SubscriptionId: The ID of the subscription where the new Azure Role is deployed.
    4. RoleName: The name of the new Azure Role.
    5. RoleDescription: A brief description of the role.
    6. ServicePrincipalObjectId: The object Id of the Service Principal.
    7. ApplicationId: The Application Id within Azure.
.OUTPUTS
    1. A New Azure Role Object
    2. A New Role Assignment Object
.NOTES
    Version      : 1.0.0
    Author       : Citrix Systems, Inc.
.EXAMPLE
    .\RoleCreationAndAssignment.ps1 `
        -Location "eastus" `
        -TemplateFilePath ".\RoleCreationAndAssignmentTemplate.json" `
        -SubscriptionId "00000000-0000-0000-0000-000000000000" `
        -RoleName "CVAD Admin Role with Minimum Permissions" `
        -RoleDescription "The roles with minimum permissions to run Citrix Virtual Apps and Desktops (CVAD) operations on Azure" `
        -ServicePrincipalObjectId "11111111-1111-1111-1111-111111111111"
    
    .\RoleCreationAndAssignment.ps1 `
        -Location "eastus" `
        -TemplateFilePath ".\RoleCreationAndAssignmentTemplate.json" `
        -SubscriptionId "00000000-0000-0000-0000-000000000000" `
        -RoleName "CVAD Admin Role with Minimum Permissions" `
        -RoleDescription "The roles with minimum permissions to run Citrix Virtual Apps and Desktops (CVAD) operations on Azure" `
        -ApplicationId "11111111-1111-1111-1111-111111111111"
#>

# /*************************************************************************
# * Copyright © 2024. Cloud Software Group, Inc. All Rights Reserved.
# * This file is subject to the license terms contained
# * in the license file that is distributed with this file.
# *************************************************************************/

param(
    [string] $Location,
    [string] $TemplateFilePath,
    [string] $SubscriptionId,
    [string] $ServicePrincipalObjectId,
    [string] $ApplicationId,
    [string] $RoleName,
    [string] $RoleDescription
)

############################################
# Step 1: Connect to the Azure Environment #
############################################
Write-Output "Import the Azure Module."
Import-Module Az

Write-Output "Connect to the Azure Environment."
Connect-AzAccount -Subscription $SubscriptionId

##############################################
# Step 2: Azure Role Creation and Assignment #
##############################################
Write-Output "Define the parameters for Azure Role Creation and Assignment."
# Define the parameters for Azure Role Creation and Assignment.
$parameters = @{
    Location        = $Location
    TemplateFile    = $TemplateFilePath
    subscriptionId  = $SubscriptionId
}

# Define optional parameters.
if ($RoleName) { $parameters['roleName'] = $RoleName }
if ($RoleDescription) { $parameters['roleDescription'] = $RoleDescription }

# Get the Service Principal Id
if ($ServicePrincipalObjectId) { $parameters['principalId'] = $ServicePrincipalObjectId }
elseif ($ApplicationId) { $parameters['principalId'] = (Get-AzADServicePrincipal -ApplicationId $ApplicationId).Id }
else { throw "Please input the Application ID or the Service Principal Object ID." }

# Create an Azure Role and Assign the it to a Service Principal.
$roleCreationResult = & New-AzDeployment @parameters

Write-Output "Create an Azure Role and Assign the it to a Service Principal:"
$roleCreationResult
