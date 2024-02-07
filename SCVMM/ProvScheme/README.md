# Provisioning Scheme and Catalog
## Overview
A provisioning scheme is a collection of data that includes information such as the hosting unit, identity pool, master image, network mapping, CPU Count, the Memory Size, machine profile and more. You can create and configure virtual machines for Citrix Virtual Apps and Desktops by using this provisioning scheme.

## How to create Provisioning Scheme and Catalog
`New-ProvScheme` command can be used to create a Provisioning Scheme with a master image or a machine profile .
1. Using master image <br>
	- [Readme](../ProvScheme/Create%20ProvScheme/README.md##%20How%20to%20create%20Provisioning%20Scheme)

2. Using machine profile image
	- [Readme](../ProvScheme/Machine%20Profile/README.md###%20Create%20Provisioning%20scheme)

A catalog can be created using `New-BrokerCatalog` command.
- [Readme](../ProvScheme/Create%20ProvScheme/README.md##%20How%20to%20create%20a%20Broker%20catalog)

## How to retrieve Provisioning Scheme and catalog properties
1. `Get-provScheme` cmdlet can be used to retrieve information about a provisioning scheme.
	- [Readme](../ProvScheme/Get%20ProvScheme/README.md###How%20to%20get%20provisioning%20scheme)

2. `Get-BrokerCatalog` cmdlet can be used to retrieve information about a catalog.
	- [Readme](../ProvScheme/Get%20ProvScheme/README.md###%20How%20to%20get%20Catalog%20Properties)

## How to update Provisioning Scheme and Catalog
1. `Publish-ProvMasterVMImage` can be used to update master image in a provisioning scheme.
	- [Readme](../ProvScheme/Update%20ProvScheme/README.md##%20How%20to%20update%20the%20master%20image)

2. `Rename-ProvScheme` can be used to rename a provisioning scheme.
	- [Readme](../ProvScheme/Update%20ProvScheme/README.md##%20How%20to%20rename%20a%20provscheme%20name)
		
3. Few properties like CPU Count, Memory can be updated in a provisioning scheme using `Set-provScheme`.
	- [Readme](../ProvScheme/Update%20ProvScheme/README.md##%20How%20to%20update%20few%20properties%20like%20cpu%20count%20network%20mapping)
	- Updating any properties of existing machines of a provisioning scheme is not supported in SCVMM.
	- CPU count is applicable for onprem hypervisors.
		
4. `Rename-BrokerCatalog` can be used to rename a catalog.
	- [Readme](../ProvScheme/Update%20ProvScheme/README.md##%20How%20to%20rename%20a%20Broker%20Catalog)
		
5. Few properties can be updated in a broker catalog using `Set-BrokerCatalog`.
	- [Readme](../ProvScheme/Update%20ProvScheme/README.md##%20How%20to%20update%20a%20Broker%20Catalog's%20properties)
		
6. Machine profile can be updated in a provisioning scheme.
	- [Readme](../ProvScheme/Machine%20Profile/README.md###%20Update%Provisioning%scheme%with%machine%profile)
	- After running Set-ProvScheme , the new machines will get the updated machine profile , not the existing machines.
		
## How to remove Provisioning Scheme
`Remove-ProvScheme` can be used to remove a provisioning scheme.
- [Readme](../ProvScheme/Remove%20ProvScheme/README.md##Overview)

