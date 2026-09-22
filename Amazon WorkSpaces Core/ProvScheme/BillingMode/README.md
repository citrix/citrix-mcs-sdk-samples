# AWS Workspaces billing service/model
## Overview
WSCoreMI has been switched to new WorkSpaces billing service/model with monthly flat-rate and hourly pay-as-you-go billing options for workspaces instances.
When using MCS to provision AWS Workspace machines in a catalog, you can set the BillingMode to Monthly or Hourly.  
When not specified, it'll default to Hourly. For more information, see these blog articles:

<TODO: Add doc link>

## Key points to consider
All instance types supported by EC2 will also be supported by Amazon WSCoreMI billing service.

The new billing option is supported only by WorkSpaces billing service, which is set at account level by default.

There’s no action required from customer side to use WorkSpaces billing service. With WorkSpaces billing service, all EC2 compute charges will be converted to WSCoreMI charges under WorkSpaces.

Customer can ask for allowlisting to stay with existing EC2 billing service, where CMI’s EC2 instance charge will be separate from WorkSpaces CMI premium fee. And “MONTHLY” billing mode will not be allowed with EC2 billing service.

Spot instance will not be allowed with WORKSPACES billing service. It’s still allowed with EC2 billing service.

## How to set BillingMode on a ProvScheme
You can use the `BillingMode` custom property when creating or updating a ProvScheme.
For example:
```powershell
$customProperties = "BillingMode,Monthly;"
```

[Create-ProvScheme-With-BillingMode.ps1](Create-ProvScheme-With-BillingMode.ps1) has an example on how to create a catalog with specified BillingMode.

[Update-ProvScheme-With-BillingMode-Using-HardwareUpdate.ps1](Update-ProvScheme-With-BillingMode-Using-HardwareUpdate.ps1) has an example on how to update an existing catalog with a specific BillingMode using service windows.

Documentation: <TODO: Add doc link>