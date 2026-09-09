# Image Management

## Overview
With the Image Management functionality, MCS separates the mastering phase from the overall provisioning workflow.

You can prepare various MCS-Image versions (aka Prepared Images) from a single Master image and use it across multiple, different MCS-based Machine Catalogs, bringing both version management and logical grouping to Citrix MCS.

## Requirements
- For Windows Master Images, a VDA with version 2311 or later and the Machine Creation Service (MCS) Storage Optimization feature enabled are supported. 
- You need to use Citrix WebStudio version 2402 or later.

To get the ID (Guid - ClusterId) of Prism Central Cluster, for example:
```powershell
GET-ITEM XDHyp:\HostingUnits\myHostingUnit\Clusters.folder\cluster-name.cluster | ft FullName, Id

FullName                       Id
--------                       --
cluster-name.cluster 00001111-2222-3333-4444-555556666666
```
### Setting up CustomProperties, ClusterId is required and CPUCores is optional:
```powershell
$CustomProperties = @"
    <CustomProperties xmlns="http://schemas.citrix.com/2014/xd/machinecreation">
        <StringProperty Name="ClusterId" Value="00001111-2222-3333-4444-555556666666"/>
        <StringProperty Name="CPUCores" Value="1"/>
    </CustomProperties>
"@
```

## HOWTO
### Image Definition
Image definition is a logical grouping of versions of an Image.
An Image Definition holds information about:
- The used Operating System.
- Support for Single- or Multi-Session Machine types.

```powershell
New-ProvImageDefinition -ImageDefinitionName "demo" -OsType Windows -VDASessionSupport MultiSession
```

### Image Definition Scope
Requires Citrix DaaS DDC 129 or later.

You can assign administrative scopes to an image definition at creation time using the optional `-Scope` parameter:

```powershell
New-ProvImageDefinition -ImageDefinitionName "demo" -OsType Windows -VDASessionSupport MultiSession -Scope @("ScopeA", "ScopeB")
```

Add scopes to an existing image definition:

```powershell
Add-ProvImageDefinitionScope -ImageDefinitionName "demo" -Scope @("ScopeA")
```

Remove scopes from an existing image definition:

```powershell
Remove-ProvImageDefinitionScope -ImageDefinitionName "demo" -Scope @("ScopeA")
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
Optional: You can replicate the prepared image to another cluster by providing the target clusterId in the
AdditionalStorageIds parameter.
```powershell
New-ProvImageVersionSpec `
    -NetworkMapping $networkMapping `
    -CustomProperties $imageCustomProperties `    
    -SourceImageVersionSpecUid $masterSpec.ImageVersionSpecUid `
    -AdditionalStorageIds $ClusterId
```

### Share Images to different cluster
Prepared images can be shared to clusters in the same Prism Central environment.

Share the images:
```powershell
Add-ProvImageVersionSpecInstance -ImageVersionSpecUid $prepedSpec.ImageVersionSpecUid -StorageId $ClusterId
```

### Share Images to different host connection
Share the image to hosting unit in a different hosting connection (different Prism Central):
Optional: Once the prepared image is replicated to the target Prism Central, Add-ProvImageVersionSpecInstance 
command can be used to replicate it to additional clusters in the target Prism Central.
```powershell
Add-ProvImageVersionSpecHostingUnit `
    -ImageVersionSpecUid $prepedSpec.ImageVersionSpecUid `
    -HostingUnitName "TargetHostingUnit" `
    -StorageId $ClusterId
```

Delete the shared images:
```powershell
Remove-ProvImageVersionSpecHostingUnit -ImageVersionSpecUid $prepedSpec.ImageVersionSpecUid -HostingUnitName $anotherHu
```

### Provisioning Scheme
Prepared images can be used to create provisioning scheme.

```powershell
New-ProvScheme -ImageVersionSpecUid $prepedSpec.ImageVersionSpecUid `
    -CleanOnBoot `
    -ProvisioningSchemeName 'demo' `
    -HostingUnitName $hostingUnitName `
    -IdentityPoolName $identityPoolName `
    -InitialBatchSizeHint $numberOfVms `
    -MasterImageVM $masterImagePath `
    -NetworkMapping $networkMapping `
    -MachineProfile $machineProfile
```
