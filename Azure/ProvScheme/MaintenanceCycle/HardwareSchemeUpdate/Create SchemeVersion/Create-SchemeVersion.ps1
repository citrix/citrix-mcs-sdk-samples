<#
.SYNOPSIS
    Creates a Provisioning Scheme Version for Provisioning Scheme Hardware Update. Applicable for Citrix DaaS and on-prem.
.DESCRIPTION
    Create-SchemeVersion creates a Provisioning Scheme Version for Provisioning Scheme Hardware Update
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
#Please add custom properties here
$CustomProperties = "<CustomProperties xmlns=`"http://schemas.citrix.com/2014/xd/machinecreation`" xmlns:xsi=`"http://www.w3.org/2001/XMLSchema-instance`"><Property xsi:type=`"StringProperty`" Name=`"StorageTypeAtShutdown`" Value=`"StandardSSD_LRS`" /></CustomProperties>"
#Please add service offering here
$ServiceOffering = "XDHyp:\HostingUnits\azure\serviceoffering.folder\00000000-0000-0000-0000-000000000000.serviceoffering"
#Please add machine profile here
$MachineProfile = "XDHyp:\HostingUnits\azure\machineprofile.folder\test.resourcegroup\test.vm"
#Please add network mapping here
$NetworkMapping = @{"0" = "XDHyp:\HostingUnits\azure\virtualprivatecloud.folder\test.resourcegroup\test.virtualprivatecloud\00000000-0000-0000-0000-000000000000.network"}
#Please add security group here
$SecurityGroup = "XDHyp:\HostingUnits\azure\securitygroup.folder\00000000-0000-0000-0000-000000000000.securitygroup"
$WriteBackCacheDiskSize = 50
$WriteBackCacheMemorySize = 2048
$ConfigurationInfo = "Provisioning Scheme is being updated with the requirement of customers"
  
#####################################################################
# Create Provisioning Scheme Version with CustomProperties modified
#####################################################################
New-ProvSchemeVersion
  -ProvisioningSchemeName $provisioningSchemeName `
  -ConfigurationInfo $ConfigurationInfo `
  -CustomProperties $CustomProperties
  
#####################################################################
# Create Provisioning Scheme Version with MachineProfile modified
#####################################################################
New-ProvSchemeVersion
  -ProvisioningSchemeName $provisioningSchemeName `
  -ConfigurationInfo $ConfigurationInfo `
  -MachineProfile $MachineProfile
  
#####################################################################
# Create Provisioning Scheme Version with ServiceOffering modified
#####################################################################
New-ProvSchemeVersion
  -ProvisioningSchemeName $provisioningSchemeName `
  -ConfigurationInfo $ConfigurationInfo `
  -ServiceOffering $ServiceOffering
  
#####################################################################
# Create Provisioning Scheme Version with NetworkMapping modified
#####################################################################
New-ProvSchemeVersion
  -ProvisioningSchemeName $provisioningSchemeName `
  -ConfigurationInfo $ConfigurationInfo `
  -NetworkMapping $NetworkMapping
  
#####################################################################
# Create Provisioning Scheme Version with SecurityGroup modified
#####################################################################
New-ProvSchemeVersion
  -ProvisioningSchemeName $provisioningSchemeName `
  -ConfigurationInfo $ConfigurationInfo `
  -SecurityGroup $SecurityGroup
  
##########################################################################
# Create Provisioning Scheme Version with WriteBackCacheDiskSize modified
##########################################################################
New-ProvSchemeVersion
  -ProvisioningSchemeName $provisioningSchemeName `
  -ConfigurationInfo $ConfigurationInfo `
  -WriteBackCacheDiskSize $WriteBackCacheDiskSize
  
#############################################################################
# Create Provisioning Scheme Version with WriteBackCacheMemorySize modified
#############################################################################
New-ProvSchemeVersion
  -ProvisioningSchemeName $provisioningSchemeName `
  -ConfigurationInfo $ConfigurationInfo `
  -WriteBackCacheMemorySize $WriteBackCacheMemorySize