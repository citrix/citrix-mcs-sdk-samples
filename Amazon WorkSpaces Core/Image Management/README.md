# Amazon WorkSpaces Core Image Management

## Overview
With the Image Management functionality, MCS separates the mastering phase from the overall provisioning workflow.
This allows you to manage the Image Versions independently of the provisioning workflow.
Creating the Image Version Specification is a necessary step prior to create a catalog or setting on new image version on an existing catalog.

You can prepare various MCS-Image versions (aka Prepared Images) from a single Master image and use it across multiple, different MCS-based Machine Catalogs, bringing both version management and logical grouping to Citrix MCS.

## Requirements
- For Windows Master Images, a VDA with version 2311 or later are supported. 

## HOWTO

### Image Definition
Image definition is a logical grouping of versions of an Image. An Image Definition holds information about the used Operating System.

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
Over time, updates, patches, or improvements to the Images can be applied.
You can use the same Image Version to provision multiple Machine Catalogs while easily tracking the associations.

```powershell
New-ProvImageVersion -ImageDefinitionName "demo"
```

### Master Image
After an Image Version created, the Master Image for this version can be chosen.

```powershell
Add-ProvImageVersionSpec `
    -ImageDefinitionName "demo" `
    -ImageVersionNumber 1 `
    -HostingUnitName "demoHU" `
    -MasterImagePath $masterImage
```

### Prepared Image
The Master Image is then used to create the prepared images. Amazon WorkSpaces Core requires a MachineProfile to be used with prepared images.

```powershell
New-ProvImageVersionSpec `
    -NetworkMapping $networkMapping `
    -CustomProperties $imageCustomProperties `
    -MachineProfile $machineProfile `
    -SourceImageVersionSpecUid $masterSpec.ImageVersionSpecUid 
```

### Provisioning Scheme
Prepared images can be used to create provisioning schemes. Amazon WorkSpaces Core only supports a CleanOnBoot provisioning scheme and requires the use of a MachineProfile.

```powershell
New-ProvScheme -ImageVersionSpecUid $prepedSpec.ImageVersionSpecUid
    -CleanOnBoot $true `
    -ProvisioningSchemeName 'demo' `
    -HostingUnitName $hostingUnitName `
    -IdentityPoolName $identityPoolName `
    -InitialBatchSizeHint $numberOfVms `
    -MachineProfile $machineProfile
```

### Image Sharing Between Hosting Units
Once an image version is created, it can be shared with other Hosting Units using this command:

```powershell
Add-ProvImageVersionSpecHostingUnit `
   -ImageVersionSpecUid $ImageVersionSpecUid `
   -HostingUnitName $HostingUnitName
```
