<#
.SYNOPSIS
    Creates a ProvisionedVmConfiguration for Provisioned Vm Hardware Update. Applicable for Citrix DaaS and on-prem.
.DESCRIPTION
    Create-VmConfiguration creates a ProvisionedVmConfiguration for Provisioned Vm Hardware Update
#>

# /*************************************************************************
# * Copyright © 2025. Cloud Software Group, Inc. All Rights Reserved.
# * This file is subject to the license terms contained
# * in the license file that is distributed with this file.
# *************************************************************************/

Add-PSSnapin -Name "Citrix.Host.Admin.V2","Citrix.MachineCreation.Admin.V2"

#####################
# Prepare Parameters
#####################
$provisioningSchemeName = "test"
$VMName = "vm01"
#Please add custom properties here
$CustomProperties = "<CustomProperties xmlns=`"http://schemas.citrix.com/2014/xd/machinecreation`" xmlns:xsi=`"http://www.w3.org/2001/XMLSchema-instance`"><Property xsi:type=`"StringProperty`" Name=`"StorageTypeAtShutdown`" Value=`"StandardSSD_LRS`" /></CustomProperties>"
#Please add service offering here
$ServiceOffering = "XDHyp:\HostingUnits\azure\serviceoffering.folder\00000000-0000-0000-0000-000000000000.serviceoffering"
#Please add machine profile here
$MachineProfile = "XDHyp:\HostingUnits\azure\machineprofile.folder\test.resourcegroup\test.vm"
#Please add network mapping here
$NetworkMapping = @{"0" = "XDHyp:\HostingUnits\azure\virtualprivatecloud.folder\test.resourcegroup\test.virtualprivatecloud\00000000-0000-0000-0000-000000000000.network"}
$ConfigurationInfo = "ProvisionedVm is being updated with the requirement of customers"
  
#####################################################################
# Create ProvisionedVmConfiguration with CustomProperties modified
#####################################################################
New-ProvVmConfiguration
  -ProvisioningSchemeName $provisioningSchemeName `
  -ConfigurationInfo $ConfigurationInfo `
  -CustomProperties $CustomProperties `
  -VMName $VMName
  
#####################################################################
# Create ProvisionedVmConfiguration with MachineProfile modified
#####################################################################
New-ProvVmConfiguration
  -ProvisioningSchemeName $provisioningSchemeName `
  -ConfigurationInfo $ConfigurationInfo `
  -MachineProfile $MachineProfile `
  -VMName $VMName
  
#####################################################################
# Create ProvisionedVmConfiguration with ServiceOffering modified
#####################################################################
New-ProvVmConfiguration
  -ProvisioningSchemeName $provisioningSchemeName `
  -ConfigurationInfo $ConfigurationInfo `
  -ServiceOffering $ServiceOffering `
  -VMName $VMName
  
#####################################################################
# Create ProvisionedVmConfiguration with NetworkMapping modified
#####################################################################
New-ProvVmConfiguration
  -ProvisioningSchemeName $provisioningSchemeName `
  -ConfigurationInfo $ConfigurationInfo `
  -NetworkMapping $NetworkMapping `
  -VMName $VMName
  
#####################################################################
# Create ProvisionedVmConfiguration with no customizations modified
#####################################################################
New-ProvVmConfiguration
  -ProvisioningSchemeName $provisioningSchemeName `
  -RemoveCustomizations `
  -VMName $VMName