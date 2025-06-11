# OpenShift Roles with Minimum Permissions for CVAD Operations.

This document provides tools to help you create and assign minimum-permission roles for Citrix Virtual Apps and Desktops (CVAD) operations on OpenShift, reducing security risks and manual errors.


<br> 

## 1. Overview

The OpenShift plugin uses a Service Account to perform CVAD operations such as power management and machine catalog creation. 

Granting excessive permissions (e.g., Cluster Admin) increases security risks, so it’s important to assign only the permissions required for CVAD tasks.

Manually defining and assigning these roles can be time-consuming and error-prone. This document offers scripts to automate the process.

<br> 

## 2. Solution: A PowerShell Script with Role Definitions.


### Key Features

- Automates creation of roles with minimum required permissions for CVAD operations.
- Automates assignment of these roles to a specified Service Account.


### Role Definitions

The following YAML files define the required roles:

- **cvad-watcher-clusterview.yaml**  
  *Cluster-wide role to watch events, VMs, networks, etc.*

- **cvad-power-management.yaml**  
  *Namespace-scoped role to manage the power states of existing VMs.*

- **cvad-machine-creation.yaml**  
  *Namespace-scoped role to support MCS functionalities such as provisioning VMs.*



### Role Assignment Script

Use the `AssignRoles.ps1` script to create and assign the roles. The script requires:

- `ServerUrl`: The OpenShift API server address (e.g., `https://api.myOpenshift.myDomain.local:6443`)
- `Username`: OpenShift console username (e.g., `kubeadmin`)
- `ServiceAccount`: The target service account (e.g., `sa-citrix`)
- `ServiceAccountNamespace`: Namespace of the service account
- `TargetNamespace`: Namespace where resources will be managed (e.g., VM creation)



**Example usage:**

```powershell
./AssignRoles.ps1 `
    -ServerUrl "https://api.myOpenshift.myDomain.local:6443" `
    -Username "kubeadmin" `
    -ServiceAccount "sa-citrix" `
    -ServiceAccountNamespace "citrix" `
    -TargetNamespace "citrix"
```

You will be prompted for the user password during execution.

<br> 


## 3. Reference Documents

For comprehensive information and further reading, the following resources are recommended.

1. [OpenShift - Using RBAC to define and apply permissions](https://docs.redhat.com/en/documentation/openshift_container_platform/4.8/html/authentication_and_authorization/using-rbac)