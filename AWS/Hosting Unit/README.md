# Hosting Unit
## Overview
Hosting units are used by the Machine Creation Service to provide the information required to create and manage virtual machines that can be used by other services. The resources that are available in a Hosting unit are resources that were created in the same availability zone from the Hosting unit. <br>
To learn more about AWS Availability Zones, refer to the [AWS Documentation](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/using-regions-availability-zones.html). 

**Note**: hosting unit is called resource in Studio 

## How to use Hosting Unit

### Creating Hosting Unit
To create a hosting connection, you first need the following resources: hosting connection name, availability zone, VPC name, Network path, and the name of the hosting unit you want to create. <br>
To get the following resources mentioned above using powershell:
```powershell
# To get a list of hosting connections' full path
Get-ChildItem -Path "XDHyp:\Connections" | Select FullPath
# To get a list of VPC Names' full path
Get-ChildItem -Path "XDHyp:\Connections\[connection name]" | Where-Object ObjectTypeName -eq "virtualprivatecloud" | Select FullPath
# To get a list of availability zones' full path
Get-ChildItem -Path "XDHyp:\Connections\[connection name]\[VPC name]" | Where-Object ObjectTypeName -eq "availabilityzone" | Select FullPath
# To get a list of networks' full path
Get-ChildItem -Path "XDHyp:\Connections\[connection name]\[availability zone name]\[VPC name]" | Where-Object ObjectTypeName -eq "network" | Select FullPath
```

First, set up the parameters needed to create the Hosting Unit.
```powershell
$connectionName = "demo-hostingconnection"
$hostingUnitName = "demo-hostingunit"
$availabilityzone = "us-east-1a"
$vpcName = "Default VPC"
$rootPath = $connectionPath + "\" + $vpcName + ".virtualprivatecloud\"

# We will select all the networks in the availability zone 
$availabilityZonePath = $rootPath + $availabilityzone + ".availabilityzone"
$networkPaths = (Get-ChildItem $availabilityZonePath | Where ObjectTypeName -eq "network") | Select-Object -ExpandProperty FullPath

$jobGroup = [Guid]::NewGuid()
$connectionPath = "XDHyp:\Connections\" + $connectionName
$hostingUnitPath = "XDHyp:\HostingUnits\" + $HostingUnitName
```
After you have the parameters setup, create the Hosting Unit using `New-Item`.
```powershell
# Create a new Hosting Unit
New-Item -Path $hostingUnitPath -AvailabilityZonePath $availabilityZonePath -HypervisorConnectionName $connectionName -JobGroup $jobGroup -PersonalvDiskStoragePath @() -RootPath $rootPath -NetworkPath $networkPaths
```

**Note**: You can create more than one Hosting Unit in a Hosting Connection

## Getting Hosting Unit Properties
To get the properties of the Hosting Unit, you need to use `Get-Item` and pass in the full path.
```powershell
$hostingUnitName = "demo-hostingUnit"
$hostingUnitPath = "XDHyp:\HostingUnits\" + $hostingUnitName
Get-Item -Path $hostingUnitPath
```
If you want to get a list of all the Hosting Unit in a Connection, you can use `Get-ChildItem`
```powershell
$connectionName = "demo-hostingconnection"
$hostingUnits = Get-ChildItem "XDHyp:\HostingUnits\" | Where-Object { $_.HypervisorConnection.HypervisorConnectionName -eq $connectionName }
```

## Updating Hosting Unit Properties
You can rename and change the network configuration for a hosting unit. To set the hosting unit properties, you need the 

To change the network configuration of a hosting connection you need the full path of the hosting connection
```powershell
$hostingUnitName = "demo-hostingunit"
$hostingUnitPath = "XDHyp:\HostingUnits\" + $HostingUnitName
$networkPath = "XDHyp:\Connections\demo-hostingconnection\us-east-1a.availabilityzone\00.0.0.0``/00 (vpc-00000000000000000).network"

Set-Item -NetworkPath $networkPath -Path $hostingUnitPath
```
To rename the network configuration of a hosting unit:
```powershell
$hostingUnitName = "demo-hostingunit"
$hostingUnitPath = "XDHyp:\HostingUnits\" + $HostingUnitName
$renameHostingUnitName = "demo-renamehostingunit"

Rename-Item -NewName $renameHostingUnitName -Path $hostingUnitPath
```
**Note**: after renaming the hosting unit, the hosting unit path will change. In this case, "XDHyp:\HostingUnits\demo-renamehostingunit"

## Deleting Hosting Unit
To remove the hosting unit, use `Remove-Item` and pass in the hosting unit path
```powershell
$hostingUnitName = "demo-hostingunit"
$hostingUnitPath = "XDHyp:\HostingUnits\" + $hostingUnitName 

# Remove the hosting unit.
Remove-Item -LiteralPath $hostingUnitPath
```

## Misc
[How to create and manage hosting unit on Studio](https://docs.citrix.com/en-us/citrix-virtual-apps-desktops/install-configure/connections) 
**Note**: hosting unit is called resource in Studio 