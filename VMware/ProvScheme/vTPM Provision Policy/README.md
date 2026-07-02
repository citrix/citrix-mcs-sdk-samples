# Using the vTPM Provision Policy of VMware for Machine Catalog Creation

This page describes the use of the **vTPM provision policy** when creating or updating a ProvScheme on VMware in Citrix Virtual Apps and Desktops (CVAD) / Citrix DaaS. The scripts in this folder show example usage of the `VtpmProvisionPolicy` parameter on `New-ProvScheme`, `Set-ProvScheme`, `Set-ProvVM`, `New-ProvSchemeVersion`, and `New-ProvVMConfiguration`.

## 1. Understanding the vTPM Provision Policy

A virtual Trusted Platform Module (vTPM) provides hardware-based, security-related functions to a VM, such as storing the keys used by BitLocker. On VMware, the vTPM device is attached to the VM/template, and its content cannot be imported or exported separately — it can only be cloned from one VM/template to another.

Historically the behavior of the vTPM on provisioned VMs depended on the source:

- A VMware **machine profile** template **copies** the vTPM content, so all provisioned VMs end up with the same vTPM content.
- A **master image** creates a **new** vTPM for each VM.

This was inconsistent and, for some workloads, incorrect. The `VtpmProvisionPolicy` parameter lets the administrator explicitly choose the behavior:

| Value | Behavior |
|-------|----------|
| `None` | **The default**, used when the parameter is omitted. No explicit policy is applied; the legacy behavior is used. There is no need to pass `None` explicitly — simply leave the parameter out. |
| `Clone` | The vTPM content is cloned from the source (machine profile). All provisioned VMs share the same vTPM content. Use this when machines must carry over TPM-protected secrets (for example, BitLocker keys). |
| `Clean` | A brand new (blank) vTPM device is created for each provisioned VM, so every machine has a unique vTPM. Use this to avoid sharing the same vTPM content across machines. |

> **Notes:**
> - This property is applicable only to MCS provisioning schemes.
> - `None` is the default. You do not pass it explicitly; omitting `-VtpmProvisionPolicy` on `New-ProvScheme` creates the scheme with `None`, and omitting it on `Set-ProvScheme` leaves the current policy unchanged.
> - The value does **not** take effect when the machine profile does not contain a vTPM. For that reason the create example provisions from a machine profile template (`-MachineProfile`).
> - When `Set-ProvScheme` is used to change the policy, the updated value applies to **new** machines added after the operation, not to existing machines.

## 2. How to use the vTPM Provision Policy

### Create a Provisioning Scheme

When using `New-ProvScheme`, specify the `VtpmProvisionPolicy` parameter together with a machine profile that contains a vTPM (other standard `New-ProvScheme` parameters are included so the snippet runs as-is):

```powershell
New-ProvScheme `
    -ProvisioningSchemeName "MyMachineCatalog" `
    -IdentityPoolName "MyMachineCatalog" `
    -HostingUnitName "MyHostingUnit" `
    -MasterImageVM "XDHyp:\HostingUnits\MyHostingUnit\MyVM.vm\MySnapshot.snapshot" `
    -MachineProfile "XDHyp:\HostingUnits\MyHostingUnit\MyVM-Template.template" `
    -NetworkMapping @{"0"="XDHyp:\HostingUnits\MyHostingUnit\MyNetwork.network"} `
    -CleanOnBoot:$false `
    -VtpmProvisionPolicy "Clone"
```

### Update an existing Provisioning Scheme

Yes — you can change the policy on a previously created catalog using `Set-ProvScheme`:

```powershell
Set-ProvScheme -ProvisioningSchemeName "MyMachineCatalog" -VtpmProvisionPolicy "Clean"
```

Setting a non-`None` policy on an existing catalog has the following requirements:

1. **Hypervisor support** — the catalog must be on a hypervisor that supports the vTPM provision policy (VMware).
2. **Machine profile** — the catalog must have a machine profile. If the existing catalog has **no** machine profile, you must supply one in the same call (shown below). The policy only takes effect when that machine profile contains a vTPM.

   ```powershell
   Set-ProvScheme -ProvisioningSchemeName "MyMachineCatalog" `
       -VtpmProvisionPolicy "Clone" `
       -MachineProfile "XDHyp:\HostingUnits\MyHostingUnit\MyVM-Template.template"
   ```
3. **Scope of effect** — the updated policy applies to **new** machines added after the operation, not to machines that already exist in the catalog.

**Note**: To keep the policy unchanged, simply omit `-VtpmProvisionPolicy`. Pass `None` only when you explicitly want to reset the catalog to the default behavior.

### Other cmdlets that accept the policy

The `VtpmProvisionPolicy` parameter is also available on the following cmdlets. The same accepted values and machine-profile requirement apply.

```powershell
# Override the policy for a single provisioned VM
Set-ProvVM -ProvisioningSchemeName "MyMachineCatalog" -VMName "MyMachineCatalog-VM-01" -VtpmProvisionPolicy "Clean"

# Create a new configuration version of a scheme with the policy (experimental command)
New-ProvSchemeVersion -ProvisioningSchemeName "MyMachineCatalog" -VtpmProvisionPolicy "Clone"

# Create a new configuration for a provisioned VM with the policy (experimental command)
New-ProvVMConfiguration -ProvisioningSchemeName "MyMachineCatalog" -VMName "MyMachineCatalog-VM-01" -VtpmProvisionPolicy "Clean"
```

## 3. Example Full Scripts Utilizing the vTPM Provision Policy

1. [Create a Machine Catalog with a vTPM provision policy (`New-ProvScheme`)](Create-ProvScheme-VtpmProvisionPolicy.ps1)
2. [Update a Machine Catalog with a vTPM provision policy (`Set-ProvScheme`)](Set-ProvScheme-VtpmProvisionPolicy.ps1)
3. [Update the vTPM provision policy for a single VM (`Set-ProvVM`)](Set-ProvVM-VtpmProvisionPolicy.ps1)
4. [Create a new scheme version with a vTPM provision policy (`New-ProvSchemeVersion`)](New-ProvSchemeVersion-VtpmProvisionPolicy.ps1)
5. [Create a new VM configuration with a vTPM provision policy (`New-ProvVMConfiguration`)](New-ProvVMConfiguration-VtpmProvisionPolicy.ps1)

## 4. Reference Documents

For comprehensive information and further reading, the following resources are recommended. These include CVAD SDK documentation and other relevant references (as applicable):

1. [CVAD SDK - About Machine Profile](https://developer-docs.citrix.com/en-us/citrix-daas-sdk/MachineCreation/about_Prov_MachineProfile.html)
