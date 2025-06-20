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
- Supports assignment of different roles to different namespaces as needed.


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
- `McsNamespaces`: One or more namespaces where MCS (machine creation) operations are required
- `PowerManagementOnlyNamespaces`: One or more namespaces where only power management operations are required


**Example usage:**

Assigns the MCS role in `mynamespace1` and `mynamespace2`:

```powershell
./AssignRoles.ps1 `
    -ServerUrl "https://api.myOpenshift.myDomain.local:6443" `
    -Username "kubeadmin" `
    -ServiceAccount "sa-mysa-default" `
    -ServiceAccountNamespace "default" `
    -McsNamespaces "mynamespace1", "mynamespace2"
```

Assigns the Power Management role in `mynamespace3` and `mynamespace4`:

```powershell
./AssignRoles.ps1 `
    -ServerUrl "https://api.myOpenshift.myDomain.local:6443" `
    -Username "kubeadmin" `
    -ServiceAccount "sa-mysa-default" `
    -ServiceAccountNamespace "default" `
    -PowerManagementOnlyNamespaces "mynamespace3", "mynamespace4"
```

Assigns MCS role in `mynamespace1`, `mynamespace2` and Power Management role in `mynamespace3`, `mynamespace4`:

```powershell
./AssignRoles.ps1 `
    -ServerUrl "https://api.myOpenshift.myDomain.local:6443" `
    -Username "kubeadmin" `
    -ServiceAccount "sa-mysa-default" `
    -ServiceAccountNamespace "default" `
    -McsNamespaces "mynamespace1", "mynamespace2" `
    -PowerManagementOnlyNamespaces "mynamespace3", "mynamespace4"
```

You will be prompted for the user password during execution.

<br> 


## 3. Reference Documents

For comprehensive information and further reading, the following resources are recommended.

1. [OpenShift - Using RBAC to define and apply permissions](https://docs.redhat.com/en/documentation/openshift_container_platform/4.8/html/authentication_and_authorization/using-rbac)