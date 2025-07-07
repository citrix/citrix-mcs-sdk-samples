# Image Management

## Overview
With the Image Management functionality, MCS separates the mastering phase from the overall provisioning workflow.

You can prepare various MCS-Image versions (aka Prepared Images) from a single Master image and use it across multiple, different MCS-based Machine Catalogs, bringing both version management and logical grouping to Citrix MCS.

## Requirements
- For Windows Master Images, a VDA with version 2311 or later and the Machine Creation Service (MCS) Storage Optimization feature enabled are supported. 
- You need to use Citrix WebStudio version 2402 or later.

## HOWTO
### Image Definition
Image definition is a logical grouping of versions of an Image.
An Image Definition holds information about:
- The used Operating System.
- Support for Single- or Multi-Session Machine types.

```powershell
New-ProvImageDefinition -ImageDefinitionName "demo" -OsType Windows -VDASessionSupport MultiSession
```

### Image Definition Connection
Image definition connection is the hypervisor connection which holds master images.

```powershell
Add-ProvImageDefinitionConnection -ImageDefinitionName "demo" -HypervisorConnectionName "demo"
```

### Image Version
Image Versions manage the versions of the Image Definitions. An Image Definition can have multiple Image Versions. 
Over time, somebody can apply updates, patches, or improvements to the Images. 
You can use the same Image Version to provision multiple Machine Catalogs while easily tracking the associations.

```powershell
New-ProvImageVersion -ImageDefinitionName "demo"
```

### Master Image
After an Image Version created, you can choose the Master Image for this version.

```powershell
Add-ProvImageVersionSpec `
    -ImageDefinitionName "demo" `
    -ImageVersionNumber 1 `
    -HostingUnitName "demoHU" `
    -MasterImagePath $masterImage
```

### Prepared Image
You can prepare an image by the master image.

```powershell
New-ProvImageVersionSpec `
    -NetworkMapping $networkMapping `
    -CustomProperties $imageCustomProperties `
    -MachineProfile $machineProfile `
    -SourceImageVersionSpecUid $masterSpec.ImageVersionSpecUid 
```

### Provisioning Scheme
Prepared images can be used to create provisioning scheme.

```powershell
New-ProvScheme -ImageVersionSpecUid $prepedSpec.ImageVersionSpecUid
    -CleanOnBoot $true `
    -ProvisioningSchemeName 'demo' `
    -HostingUnitName $hostingUnitName `
    -IdentityPoolName $identityPoolName `
    -InitialBatchSizeHint $numberOfVms `
    -MachineProfile $machineProfile
```
