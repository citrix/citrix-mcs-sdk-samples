# Troubleshooting image preparation failures with the image preparation VM (VMware)

This folder shows how to use the `-KeepPreparationVMOnFailure` parameter of `New-ProvScheme` and `Publish-ProvMasterVMImage` so that, on VMware, the image preparation VM is kept on the hypervisor when image preparation fails. It also shows how to find, inspect, and remove the retained VM using `Get-ProvImagePrepVM` and `Remove-ProvImagePrepVM`.

## 1. Understanding the -KeepPreparationVMOnFailure feature

Image preparation runs on a temporary VM that MCS creates from your master image. By default this VM and its resources are removed when preparation finishes, whether it succeeds or fails. When a failure cannot be diagnosed from the returned error (for example, `No Image Preparation results found. There may be no suitable VDA installed, or some other serious failure in the Master VM. Image preparation failed`), the logs on the image preparation VM are often the only way to find the root cause.

Supplying `-KeepPreparationVMOnFailure` changes the behavior on failure only:

- If image preparation **succeeds**, the image preparation VM is removed automatically (the switch has no effect).
- If image preparation **fails**, the image preparation VM and its resources are left on the hypervisor so you can connect to it and inspect the logs.

For `New-ProvScheme`, a failed run still creates the provisioning scheme, but it is not operational. For `Publish-ProvMasterVMImage`, the provisioning scheme keeps running on the previous master image.

## 2. Using the feature

### Enable it when creating a catalog or updating an image

Add the switch to `New-ProvScheme` or `Publish-ProvMasterVMImage`:

```powershell
New-ProvScheme `
    -ProvisioningSchemeName "MyMachineCatalog" `
    # Additional parameters... `
    -KeepPreparationVMOnFailure
```

```powershell
Publish-ProvMasterVMImage `
    -ProvisioningSchemeName "MyMachineCatalog" `
    # Additional parameters... `
    -KeepPreparationVMOnFailure
```

### Find the retained image preparation VM

Use `Get-ProvImagePrepVM` to retrieve details of the retained VM. On VMware, locate the VM in vSphere using the **PreparationImageName** field, in the form `Preparation - <CatalogName>`.

### Inspect the logs

1. Power on the image preparation VM and open the vSphere console (Launch Web Console), logging in if prompted.
2. Browse to `%programdata%\Citrix\ImagePreparation`. If prompted with a security prompt, press **Continue**.
3. Open `image-prep.log`, or copy it off the VM to provide to support for troubleshooting.

### Remove it when finished

When troubleshooting is complete, remove the VM and its resources with `Remove-ProvImagePrepVM`. Deleting the machine catalog, or re-running `Publish-ProvMasterVMImage` for the same scheme, also removes it automatically.

## 3. Example Full Scripts

1. [Create a catalog that keeps the image preparation VM on failure](Create-ProvScheme-KeepPreparationVMOnFailure.ps1)
2. [Update a master image, keeping the image preparation VM on failure](Update-MasterImage-KeepPreparationVMOnFailure.ps1)
3. [Find the retained image preparation VM](Get-ProvImagePrepVM.ps1)
4. [Remove the retained image preparation VM](Remove-ProvImagePrepVM.ps1)

## 4. Reference Documents

1. Keep the image preparation VM on failure — Citrix Knowledge Base article (pending publication).
2. [CVAD SDK - Machine Creation cmdlets](https://developer-docs.citrix.com/en-us/citrix-daas-sdk/machinecreation/)

> **Compatibility:** `-KeepPreparationVMOnFailure` requires CVAD Cloud 123 or later. `Get-ProvImagePrepVM` and `Remove-ProvImagePrepVM` require CVAD Cloud 129 / CVAD 2611 CR or later.
