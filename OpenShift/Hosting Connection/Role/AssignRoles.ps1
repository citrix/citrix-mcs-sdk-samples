<#
.SYNOPSIS
    Assigns roles to a specified service account in OpenShift, ensuring all required roles exist and binding them at either the cluster or namespace level as appropriate.

.DESCRIPTION
    The script logs into an OpenShift server, verifies the existence of a service account, ensures specified roles exist by creating them if necessary, 
    and assigns these roles to the service account. It handles both cluster-wide and namespace-bound role bindings, using YAML files for role definitions.
    Namespace-bound roles can be assigned to multiple namespaces as specified by the user. 
    The script and associated YAML files must be located in the same folder.

.INPUTS
    The script accepts the following parameters:
    -ServerUrl: The URL of the OpenShift server to log into.
    -Username: The username for logging into the OpenShift server.
    -ServiceAccount: The name of the service account to which roles will be assigned.
    -ServiceAccountNamespace: The namespace where the service account resides.
    -McsNamespaces: One or more namespaces to which the MCS role will be assigned.
    -PowerManagementOnlyNamespaces: One or more namespaces to which the Power Management only role will be assigned.

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
        -ServiceAccount "sa-mysa-default" `
        -ServiceAccountNamespace "default" `
        -McsNamespaces "mynamespace1", "mynamespace2"

    Assigns the MCS role in mynamespace1 and mynamespace2 namespaces.

.EXAMPLE
    ./AssignRoles.ps1 `
        -ServerUrl "https://api.myOpenshift.myDomain.local:6443" `
        -Username "kubeadmin" `
        -ServiceAccount "sa-mysa-default" `
        -ServiceAccountNamespace "default" `
        -PowerManagementOnlyNamespaces "mynamespace3", "mynamespace4"

    Assigns the Power Management role in the mynamespace3 and mynamespace4 namespaces.

.EXAMPLE
    ./AssignRoles.ps1 `
        -ServerUrl "https://api.myOpenshift.myDomain.local:6443" `
        -Username "kubeadmin" `
        -ServiceAccount "sa-mysa-default" `
        -ServiceAccountNamespace "default" `
        -McsNamespaces "mynamespace1", "mynamespace2" `
        -PowerManagementOnlyNamespaces "mynamespace3", "mynamespace4"

    Assigns the MCS role in mynamespace1 and mynamespace2, and the Power Management role in mynamespace3 and mynamespace4.
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
    [string[]]$McsNamespaces,
    [string[]]$PowerManagementOnlyNamespaces
)

# Validate input parameters: All except one of McsNamespaces or PowerManagementOnlyNamespaces are required
if (-not $ServerUrl -or -not $Username -or -not $ServiceAccount -or -not $ServiceAccountNamespace -or (-not $McsNamespaces -and -not $PowerManagementOnlyNamespaces)) {
    Write-Error "Missing required parameters. You must provide all connection/account parameters, and at least one of -McsNamespaces or -PowerManagementOnlyNamespaces."
    exit 1
}

# This script assumes that `oc.exe` is registered in the system's PATH environment variable.
$ocCommand = Get-Command oc -ErrorAction SilentlyContinue 
if ($null -eq $ocCommand) { 
    Write-Error "oc command must be in directory that is part of your `$env:PATH variable"  
    exit 1
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
            Write-Host "   Role Creation : " -NoNewline
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
        $account = $ServiceAccountNamespace + ":" + $ServiceAccount
        $bindingName = "rb-$RoleName-$RoleTargetNamespace-$account"

        if ($RoleTargetNamespace) {
            # Namespace-bound Role Binding using a ClusterRole
            Write-Host "   Role Binding  : " -NoNewline
            oc create rolebinding $bindingName --clusterrole=$RoleName --namespace=$RoleTargetNamespace --serviceaccount=$account
            
        } else {
            # Cluster-Wide Role Binding
            Write-Host "   Role Binding  : " -NoNewline
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

# Verify the target namespaces are specified.
if ((-not $McsNamespaces) -and (-not $PowerManagementOnlyNamespaces)) {
    throw "You must specify at least one namespace for either -McsNamespaces or -PowerManagementOnlyNamespaces."
}

# Build the role assignment list
$roles = @()

# Add cluster-wide role
$roles += ,@("cvad-watcher-clusterview", $null)

# Add namespace-bound roles for power management
foreach ($ns in $PowerManagementOnlyNamespaces) {
    if ($null -ne $ns) {
        $roles += ,@("cvad-power-management", $ns.Trim())
    }
}

# Add namespace-bound roles for MCS
foreach ($ns in $McsNamespaces) {
    if ($null -ne $ns) {
        $roles += ,@("cvad-machine-creation", $ns.Trim())
    }
}

Write-Host "Starting role assignment for service account '$ServiceAccount' in namespace '$ServiceAccountNamespace'..."
$iteration = 1

# Iterate through the list and apply functions
foreach ($role in $roles) {
    $RoleName = $role[0]
    $YamlFilePath = "$($role[0]).yaml"
    $RoleTargetNamespace = $role[1]

    if ($null -eq $RoleTargetNamespace) {
        Write-Host "$iteration. Assigning '$RoleName' at the cluster level..."
    } else {
        Write-Host "$iteration. Assigning '$RoleName' to namespace '$RoleTargetNamespace'..."
    }
    
    # Ensure the role exists
    Ensure-RoleExist -RoleName $RoleName -YamlFilePath $YamlFilePath

    # Assign the role with or without a target namespace
    Assign-ServiceAccountRole -RoleName $RoleName -RoleTargetNamespace $RoleTargetNamespace -ServiceAccount $ServiceAccount -ServiceAccountNamespace $ServiceAccountNamespace

    # Update the iteration count for better message. 
    $iteration += 1
}
