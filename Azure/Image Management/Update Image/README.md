# Update Image

## Overview
After creating a prepared image version spec, you can update supported custom properties on that image by running `Set-ProvImageVersionSpec`.

For Azure image management, `Set-ProvImageVersionSpec` supports updating these prepared image properties:
- `SharedImageGalleryReplicaRatio`
- `SharedImageGalleryReplicaMaximum`

The image definition must use Azure Compute Gallery.

## How to update a prepared image
Locate the prepared image version spec for an existing image definition and version, then update one or both supported custom properties.

```powershell
$preparedSpec = Get-ProvImageVersionSpec `
    -ImageDefinitionName "demo" `
    -ImageVersionNumber 1 | Where-Object IsPrepared -eq $true

$customProperties = @"
<CustomProperties xmlns="http://schemas.citrix.com/2014/xd/machinecreation" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">
  <Property xsi:type="IntProperty" Name="SharedImageGalleryReplicaRatio" Value="5" />
  <Property xsi:type="IntProperty" Name="SharedImageGalleryReplicaMaximum" Value="20" />
</CustomProperties>
"@

Set-ProvImageVersionSpec `
    -ImageVersionSpecUid $preparedSpec.ImageVersionSpecUid `
    -CustomProperties $customProperties
```

You only need to include the property values that you want to change.