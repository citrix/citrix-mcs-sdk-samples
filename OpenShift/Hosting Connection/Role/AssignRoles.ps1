<#
.SYNOPSIS
    This script assigns roles to a specified service account in OpenShift, ensuring roles exist and binding them appropriately.

.DESCRIPTION
    The script logs into an OpenShift server, verifies the existence of a service account, ensures specified roles exist by creating them if necessary, 
    and assigns these roles to the service account. It handles both cluster-wide and namespace-bound role bindings, using YAML files for role definitions.
    The script and associated YAML files must be located in the same folder.

.INPUTS
    The script accepts the following parameters:
    -ServerUrl: The URL of the OpenShift server to log into.
    -Username: The username for logging into the OpenShift server.
    -ServiceAccount: The name of the service account to which roles will be assigned.
    -ServiceAccountNamespace: The namespace where the service account resides.
    -TargetNamespace: The namespace where namespace-bound roles are applied.

.OUTPUTS
    This script does not produce direct outputs but provides console messages indicating the progress and status of operations, 
    including role creation and assignment.

.NOTES
    Version      : 1.0.0
    Author       : Citrix Systems, Inc.
    
    The script assumes that `oc.exe` is registered in the system's PATH environment variable. 

.EXAMPLE
    ./AssignRoles.ps1 `
        -ServerUrl "https://api.myOpenshift.myDomain.local:6443" `
        -Username "kubeadmin" `
        -ServiceAccount "sa-haan-default" `
        -ServiceAccountNamespace "default" `
        -TargetNamespace "serenity-mcs"
    
        This example logs into the specified OpenShift server with the given username, verifies the service account,
    ensures the roles exist, and assigns them to the service account in the specified namespaces.
#>

# /*************************************************************************
# * Copyright © 2025. Cloud Software Group, Inc. All Rights Reserved.
# * This file is subject to the license terms contained
# * in the license file that is distributed with this file.
# *************************************************************************/

param(
    [string]$ServerUrl,
    [string]$Username,
    [string]$ServiceAccount,
    [string]$ServiceAccountNamespace,
    [string]$TargetNamespace
)

# This script assumes that `oc.exe` is registered in the system's PATH environment variable.
$ocCommand = Get-Command oc -ErrorAction SilentlyContinue 
if ($null -eq $ocCommand) { 
    Write-Error "oc command must be in directory that is part of your `$env:PATH variable"  
    exit
}

# Function to verify if a service account exists
function Verify-ServiceAccountExists {
    param(
        [string]$ServiceAccount,
        [string]$ServiceAccountNamespace
    )
    
    $result = oc get sa $ServiceAccount -n $ServiceAccountNamespace 2>&1
    return ($result -notmatch "NotFound")
}

# Function to ensure a role exists, creating it if it does not
function Ensure-RoleExist {
    param(
        [string]$RoleName,
        [string]$YamlFilePath
    )
    
    try {
        # Construct the full path using the script's directory
        $fullYamlFilePath = Join-Path -Path $PSScriptRoot -ChildPath $YamlFilePath
        
        # Check if the role exists
        $result = oc get clusterrole $RoleName 2>&1
        if ($result -match "NotFound") {
            # Apply the YAML file to create the role
            Write-Host "Role '$RoleName' does not exist. Create role from file '$fullYamlFilePath'."
            oc apply -f $fullYamlFilePath
        } 
    } catch {
        throw "Error processing file '$fullYamlFilePath': $_"
    }
}

# Function to assign a role to a service account
function Assign-ServiceAccountRole {
    param(
        [string]$RoleName,
        [string]$RoleTargetNamespace,
        [string]$ServiceAccount,
        [string]$ServiceAccountNamespace
    )
    
    try {
        $bindingName = "rb-$RoleName-$ServiceAccount"
        $account = $ServiceAccountNamespace + ":" + $ServiceAccount

        if ($RoleTargetNamespace) {
            # Namespace-bound Role Binding using a ClusterRole
            Write-Host "Assign the namespace-bound role '$RoleName' to service account '$ServiceAccount' in namespace '$RoleTargetNamespace'."
            oc create rolebinding $bindingName --clusterrole=$RoleName --namespace=$RoleTargetNamespace --serviceaccount=$account
            
        } else {
            # Cluster-Wide Role Binding
            Write-Host "Assign the cluster-wide role '$RoleName' to service account '$ServiceAccount'."
            oc create clusterrolebinding $bindingName --clusterrole=$RoleName --serviceaccount=$account
            
        }
    } catch {
        Write-Host "Error assigning role '$RoleName' to service account '$account': $_"
    }
}

##############
# Main Logic #
##############

# Login to OpenShift
Write-Host "Logging in to OpenShift server at '$ServerUrl' with username '$Username'."
oc login $ServerUrl --username=$Username

# Verify the Service Account exists
$isExist = Verify-ServiceAccountExists -ServiceAccount $ServiceAccount -ServiceAccountNamespace $ServiceAccountNamespace
if (-not $isExist) {
    throw "The service account '$ServiceAccount' does not exist in namespace '$ServiceAccountNamespace'."
} 

# Define roles and target namespaces
$roles = @(
    ,@("cvad-watcher-clusterview", $null) # This role requires a Cluster-wide role binding.
    ,@("cvad-power-management", $TargetNamespace) # This role requires a Namespace bound role binding.
    ,@("cvad-machine-creation", $TargetNamespace) # This role requires a Namespace bound role binding.
)

# Iterate through the list and apply functions
foreach ($role in $roles) {
    $RoleName = $role[0]
    $YamlFilePath = "$($role[0]).yaml"
    $RoleTargetNamespace = $role[1]

    # Ensure the role exists
    Ensure-RoleExist -RoleName $RoleName -YamlFilePath $YamlFilePath

    # Assign the role with or without a target namespace
    Assign-ServiceAccountRole -RoleName $RoleName -RoleTargetNamespace $RoleTargetNamespace -ServiceAccount $ServiceAccount -ServiceAccountNamespace $ServiceAccountNamespace
}
