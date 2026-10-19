# JSON Custom Properties for Amazon WorkSpaces Core

## Overview
Amazon WorkSpaces Core supports a **JSON custom properties format** in addition to the legacy semicolon-delimited format (`Key,Value;Key2,Value2;`). The JSON format provides a structured way to express complex property values using nested objects and arrays, instead of pipe-and-colon-delimited strings.

The JSON format is supported **only on Amazon WorkSpaces Core**. AWS EC2 provisioning schemes continue to use the legacy format exclusively.

Existing provisioning schemes created with the legacy format remain fully functional. No migration is required.

## JSON Format Reference
Custom properties are passed as a JSON object string to the `-CustomProperties` parameter of `New-ProvScheme`, `Set-ProvScheme`, or `New-ProvSchemeVersion`.

### Supported Custom Properties

| Property | Type | Description | Example Value |
|---|---|---|---|
| `BillingMode` | string | Billing model for the workspace instances | `"Monthly"` or `"Hourly"` |
| `PersistWBC` | string | Persist Write Back Cache disk between reboots | `"True"` or `"False"` |
| `PersistOsDisk` | string | Persist the OS disk between reboots | `"True"` or `"False"` |
| `WBCDiskStorageType` | object | Storage configuration for the Write Back Cache disk | `{"StorageType":"gp3","Iops":3000,"Throughput":135}` |
| `BackupVmConfiguration` | array | Backup VM instance types | `[{"InstanceType":"t2.large"},{"InstanceType":"t3.large"}]` |

### Simple Properties
Simple key-value properties use string values:
```json
{
    "BillingMode": "Monthly",
    "PersistWBC": "false",
    "PersistOsDisk": "false"
}
```

Legacy equivalent:
```
BillingMode,Monthly;PersistWBC,false;PersistOsDisk,false;
```

### WBCDiskStorageType (Nested Object)
The `WBCDiskStorageType` property supports a nested JSON object with `StorageType`, `Iops`, and `Throughput` fields:
```json
{
    "WBCDiskStorageType": {
        "StorageType": "gp3",
        "Iops": 3000,
        "Throughput": 135
    }
}
```

Legacy equivalent:
```
WBCDiskStorageType,gp3:3000:135;
```

### BackupVmConfiguration (Array of Objects)
The `BackupVmConfiguration` property supports a JSON array of objects, each with an `InstanceType`:
```json
{
    "BackupVmConfiguration": [
        { "InstanceType": "t3.medium" },
        { "InstanceType": "t3.large" }
    ]
}
```

Legacy equivalent:
```
BackupVmConfiguration,t3.medium|t3.large;
```

> **Note:** Spot instances are not supported for Amazon WorkSpaces Core. Do not include `"MarketType": "Spot"` in BackupVmConfiguration entries for WSC catalogs.

### Complete Example
A JSON custom properties string combining multiple properties:
```json
{
    "BillingMode": "Monthly",
    "WBCDiskStorageType": {
        "StorageType": "gp3",
        "Iops": 3000,
        "Throughput": 135
    },
    "PersistWBC": "false",
    "PersistOsDisk": "false"
}
```

## Leading Practices

- **Use JSON for new catalogs.** When creating new provisioning schemes on Amazon WorkSpaces Core, prefer JSON format for clearer, more readable custom properties.
- **No migration needed for existing catalogs.** Existing provisioning schemes using the legacy format continue to work. You do not need to convert them.
- **Mix-and-match updates are supported.** You can update a catalog originally created with legacy format by passing JSON custom properties. The system merges the updated properties with the existing ones, handling format conversion automatically.
- **Only include changed properties in updates.** When using `New-ProvSchemeVersion` to update custom properties, you only need to include the properties you want to change. Unchanged properties are preserved from the existing provisioning scheme.
- **Validate JSON syntax.** Ensure your JSON string is well-formed before passing it to the cmdlet. Malformed JSON will be rejected during preflight validation.

## Scripts

### Create-ProvScheme-With-JSON-CustomProperties.ps1
Creates a new provisioning scheme with JSON-format custom properties.

User-configurable variables:
1. `$provisioningSchemeName` - Name of the provisioning scheme to create
2. `$hostingUnitName` - Name of the hosting unit
3. `$machineProfile` - Full path to the machine profile VM
4. `$imageVersionSpecUid` - UID of the image version spec (from Image Management)
5. `$customProperties` - JSON string containing the custom properties

### Update-ProvScheme-With-JSON-CustomProperties.ps1
Updates an existing provisioning scheme with JSON-format custom properties using service windows (New-ProvSchemeVersion / New-ProvSchemeHardwareUpdate). Changes can be applied to new VMs only or to all VMs.

User-configurable variables:
1. `$provisioningSchemeName` - Name of the existing provisioning scheme
2. `$customProperties` - JSON string containing the properties to update

## Common Error Scenarios

| Error | Cause | Resolution |
|---|---|---|
| `PreflightErrorJsonCustomPropertiesNotSupported` | JSON custom properties were used on an AWS EC2 provisioning scheme | JSON format is only supported on Amazon WorkSpaces Core. Use the legacy `Key,Value;` format for EC2. |
| `InvalidCustomProperties` with `aws_custom_properties_invalid_format#` | The custom properties string is not valid JSON | Verify the JSON syntax. Ensure proper quoting, comma placement, and bracket matching. |
| `InvalidCustomProperties` with `aws_custom_properties_duplicate_key#` | The JSON object contains the same key more than once | Remove the duplicate key from the JSON string. |
| `InvalidCustomProperties` with the property name | A property name in the JSON is not a supported custom property | Check the property name for typos. Refer to the supported properties list. |
