# Bring Your Own Resource Groups
## Overview
By default, MCS creates a new Resource Group on Azure while provisioning a catalog. The naming convention for this resource group is 'citrix-xd-{ProvisioningSchemeId}-{unique 5 digit string}'. However, did you know you can bring your own previously created Resource Groups for MCS provisioning?  
When using a narrow scope service principal to create a machine catalog, you must supply an empty, pre-created Azure Resource Group for the catalog.

To learn more about Azure Resource Groups, please see Azure's documentation: https://learn.microsoft.com/en-us/azure/azure-resource-manager/management/manage-resource-groups-portal

## How to start using your own ResourceGroups
You can use your own ResourceGroups by setting the `ResourceGroups` custom property. For example:
```powershell
$customProperties = @"
<CustomProperties xmlns="http://schemas.citrix.com/2014/xd/machinecreation" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">
<Property xsi:type="StringProperty" Name="ResourceGroups" Value="MyResourceGroup" />
</CustomProperties>
"@
```

**Note**: Make sure that the value of the ResourceGroup specified in the Custom Property is a valid one on Azure.

Documentation: https://docs.citrix.com/en-us/citrix-virtual-apps-desktops/2305/install-configure/machine-catalogs-create/create-machine-catalog-citrix-azure#azure-resource-groups